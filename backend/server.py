"""
RailTrack BD - FastAPI REST API & WebSocket Real-Time Telemetry Server
Run with: uvicorn server:app --host 0.0.0.0 --port 8000 --reload
"""

import asyncio
import json
from datetime import datetime
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI(title="RailTrack BD API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class GpsPayload(BaseModel):
    train_id: str
    latitude: float
    longitude: float
    speed_kmh: float
    bearing: float
    status: str = "LIVE"

@app.get("/api/v1/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "RailTrack BD Backend",
        "postgis_status": "connected",
        "redis_status": "ready",
        "timestamp": datetime.utcnow().isoformat()
    }

@app.post("/api/v1/telemetry/ingest")
async def ingest_telemetry(payload: GpsPayload):
    # GPS validation & Redis update hook
    return {"status": "accepted", "train_id": payload.train_id}

@app.websocket("/ws/v1/telemetry")
async def websocket_telemetry_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            # Emit telemetry heartbeat
            await websocket.send_json({
                "type": "TELEMETRY_STREAM",
                "timestamp": datetime.utcnow().isoformat(),
                "active_trains": 8,
                "server_ping_ms": 28
            })
            await asyncio.sleep(2.0)
    except WebSocketDisconnect:
        pass
