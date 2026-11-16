"""
RailTrack BD - Redis Geospatial Caching & Pub/Sub Architecture
Handles real-time GPS ingest, spatial indexing (GEOADD), and broadcast fan-out.
"""

import json
import redis
from typing import Dict, Any, List

class RedisRailTrackService:
    def __init__(self, host: str = 'localhost', port: int = 6379, db: int = 0):
        self.r = redis.Redis(host=host, port=port, db=db, decode_responses=True)
        self.GEO_KEY = "railtrack:trains:geo"
        self.META_KEY_PREFIX = "railtrack:train:"
        self.CHANNEL_PREFIX = "railtrack:channel:"

    def update_train_telemetry(self, train_id: str, lat: float, lng: float, metadata: Dict[str, Any]):
        """
        1. Updates spatial coordinates in Redis Geospatial Index (GEOADD)
        2. Sets TTL cached metadata JSON
        3. Publishes telemetry payload to Pub/Sub subscribers
        """
        pipe = self.r.pipeline()
        # 1. Geospatial index
        pipe.geoadd(self.GEO_KEY, (lng, lat, train_id))
        
        # 2. Metadata cache with 60s TTL
        meta_key = f"{self.META_KEY_PREFIX}{train_id}"
        payload = {
            "lat": lat,
            "lng": lng,
            **metadata
        }
        pipe.setex(meta_key, 60, json.dumps(payload))
        
        # 3. Publish to train's specific live subscriber channel & global radar
        pipe.publish(f"{self.CHANNEL_PREFIX}{train_id}", json.dumps(payload))
        pipe.publish(f"{self.CHANNEL_PREFIX}global", json.dumps(payload))
        pipe.execute()

    def get_trains_within_radius(self, lat: float, lng: float, radius_km: float = 50.0) -> List[Dict[str, Any]]:
        """
        Query trains within radius using Redis GEORADIUS / GEOSEARCH
        """
        nearby_train_ids = self.r.georadius(
            name=self.GEO_KEY,
            longitude=lng,
            latitude=lat,
            radius=radius_km,
            unit='km',
            withdist=True,
            withcoord=True,
            sort='ASC'
        )
        results = []
        for item in nearby_train_ids:
            train_id, dist, coords = item[0], item[1], item[2]
            meta = self.r.get(f"{self.META_KEY_PREFIX}{train_id}")
            data = json.loads(meta) if meta else {}
            data['distance_km'] = dist
            results.append(data)
        return results
