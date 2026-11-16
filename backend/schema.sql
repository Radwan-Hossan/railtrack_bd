-- ==============================================================================
-- RailTrack BD - PostgreSQL + PostGIS Production Schema
-- Designed for Bangladesh Railway Real-Time Spatial Tracking & Analytics
-- ==============================================================================

-- 1. Enable PostGIS Spatial Extensions
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;

-- 2. Stations Spatial Table
CREATE TABLE IF NOT EXISTS stations (
    id VARCHAR(10) PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    name_en VARCHAR(100) NOT NULL,
    name_bn VARCHAR(100) NOT NULL,
    division VARCHAR(50) NOT NULL,
    platforms INT DEFAULT 2,
    location GEOMETRY(Point, 4326) NOT NULL, -- WGS84 Geographic Coordinate System
    has_wifi BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Spatial GiST Index for sub-millisecond proximity queries
CREATE INDEX IF NOT EXISTS idx_stations_location ON stations USING GIST(location);

-- 3. Railway Corridor Route Geometry Table
CREATE TABLE IF NOT EXISTS railway_corridors (
    id VARCHAR(50) PRIMARY KEY,
    route_name VARCHAR(150) NOT NULL,
    total_distance_km NUMERIC(6, 2) NOT NULL,
    track_geom GEOMETRY(LineString, 4326) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_railway_corridors_track ON railway_corridors USING GIST(track_geom);

-- 4. Trains Master Table
CREATE TABLE IF NOT EXISTS trains (
    id VARCHAR(20) PRIMARY KEY,
    train_number VARCHAR(10) NOT NULL UNIQUE,
    name_en VARCHAR(100) NOT NULL,
    name_bn VARCHAR(100) NOT NULL,
    train_type VARCHAR(30) DEFAULT 'INTERCITY',
    origin_station_id VARCHAR(10) REFERENCES stations(id),
    destination_station_id VARCHAR(10) REFERENCES stations(id),
    departure_time TIME NOT NULL,
    arrival_time TIME NOT NULL,
    off_day VARCHAR(20) DEFAULT 'None',
    total_coaches INT DEFAULT 16,
    is_active BOOLEAN DEFAULT TRUE
);

-- 5. Real-Time GPS Telemetry & Validation Logs Table
CREATE TABLE IF NOT EXISTS gps_telemetry_logs (
    id BIGSERIAL PRIMARY KEY,
    train_id VARCHAR(20) REFERENCES trains(id),
    location GEOMETRY(Point, 4326) NOT NULL,
    speed_kmh NUMERIC(5, 2) NOT NULL,
    bearing NUMERIC(5, 2) NOT NULL,
    altitude_m NUMERIC(5, 1) DEFAULT 12.0,
    tracking_status VARCHAR(20) NOT NULL, -- 'LIVE', 'DEMO', 'STALE', 'OFFLINE'
    validation_status VARCHAR(30) DEFAULT 'VALID', -- 'VALID', 'SPEED_VIOLATION', 'GEOFENCE_DEVIATION'
    recorded_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gps_telemetry_train_time ON gps_telemetry_logs(train_id, recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_gps_telemetry_location ON gps_telemetry_logs USING GIST(location);

-- 6. Spatial Proximity Trigger / Function for Station Arrival Detection
-- Checks if a train is within X kilometers of any station
CREATE OR REPLACE FUNCTION check_station_proximity(
    train_lon DOUBLE PRECISION,
    train_lat DOUBLE PRECISION,
    threshold_km DOUBLE PRECISION DEFAULT 5.0
)
RETURNS TABLE (
    station_id VARCHAR,
    station_name VARCHAR,
    distance_km DOUBLE PRECISION
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id,
        s.name_en,
        ROUND((ST_Distance(s.location::geography, ST_SetSRID(ST_MakePoint(train_lon, train_lat), 4326)::geography) / 1000.0)::numeric, 2)::DOUBLE PRECISION AS distance_km
    FROM stations s
    WHERE ST_DWithin(s.location::geography, ST_SetSRID(ST_MakePoint(train_lon, train_lat), 4326)::geography, threshold_km * 1000.0)
    ORDER BY distance_km ASC;
END;
$$ LANGUAGE plpgsql;

-- 7. Geofence Validation Function (Corridor Buffer Check)
CREATE OR REPLACE FUNCTION validate_train_corridor(
    p_train_lon DOUBLE PRECISION,
    p_train_lat DOUBLE PRECISION,
    p_corridor_id VARCHAR(50),
    p_tolerance_meters DOUBLE PRECISION DEFAULT 1500.0
)
RETURNS BOOLEAN AS $$
DECLARE
    is_inside BOOLEAN;
BEGIN
    SELECT ST_DWithin(
        track_geom::geography,
        ST_SetSRID(ST_MakePoint(p_train_lon, p_train_lat), 4326)::geography,
        p_tolerance_meters
    ) INTO is_inside
    FROM railway_corridors
    WHERE id = p_corridor_id;

    RETURN COALESCE(is_inside, FALSE);
END;
$$ LANGUAGE plpgsql;
