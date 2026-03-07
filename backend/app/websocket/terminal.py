"""WebSocket connection manager for real-time terminal output"""

from fastapi import WebSocket
from typing import Dict


class ConnectionManager:
    """Manages active WebSocket connections"""
    
    def __init__(self):
        self.active_connections: Dict[str, WebSocket] = {}
    
    async def connect(self, websocket: WebSocket, session_id: str):
        """Accept and store new connection"""
        await websocket.accept()
        self.active_connections[session_id] = websocket
        print(f"🔌 WebSocket connected: {session_id}")
    
    def disconnect(self, session_id: str):
        """Remove disconnected client"""
        if session_id in self.active_connections:
            del self.active_connections[session_id]
            print(f"🔌 WebSocket disconnected: {session_id}")
    
    async def send_personal_message(self, message: dict, session_id: str):
        """Send message to specific client"""
        if session_id in self.active_connections:
            try:
                await self.active_connections[session_id].send_json(message)
            except Exception as e:
                print(f"Error sending message to {session_id}: {e}")
                self.disconnect(session_id)
    
    async def broadcast(self, message: dict):
        """Broadcast message to all connected clients"""
        disconnected = []
        for session_id, connection in self.active_connections.items():
            try:
                await connection.send_json(message)
            except Exception as e:
                print(f"Error broadcasting to {session_id}: {e}")
                disconnected.append(session_id)
        
        # Clean up disconnected clients
        for session_id in disconnected:
            self.disconnect(session_id)
    
    def get_connection_count(self) -> int:
        """Get number of active connections"""
        return len(self.active_connections)
