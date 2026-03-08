"""
AutoMium Backend API
Modular architecture for cybersecurity tools orchestration
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes import network, malware, bruteforce, reports, tools, websocket_routes, monitoring, auth, kali_tools
from app.models.database import init_database
from app.websocket.terminal import ConnectionManager

# Initialize FastAPI app
app = FastAPI(
    title="AutoMium API",
    description="Personal Pentesting & Malware Analysis Platform",
    version="1.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Local only - no security risk
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/auth", tags=["Authentication"])
app.include_router(network.router, prefix="/scan", tags=["Network Scanning"])
app.include_router(malware.router, prefix="/analyze", tags=["Malware Analysis"])
app.include_router(bruteforce.router, prefix="/bruteforce", tags=["Bruteforce"])
app.include_router(reports.router, prefix="/reports", tags=["Reports"])
app.include_router(tools.router, prefix="/tools", tags=["Tools"])
app.include_router(kali_tools.router, prefix="/kali", tags=["Kali Linux Tools"])
app.include_router(websocket_routes.router, prefix="", tags=["WebSocket"])
app.include_router(monitoring.router, prefix="/monitoring", tags=["Network Monitoring"])

# WebSocket manager
ws_manager = ConnectionManager()

@app.on_event("startup")
async def startup_event():
    """Initialize database on startup"""
    init_database()
    print("🚀 AutoMium Backend API started successfully!")
    print("📡 API Documentation: http://localhost:8000/docs")

@app.get("/")
async def root():
    """Root endpoint - API status"""
    return {
        "status": "online",
        "service": "AutoMium Backend API",
        "version": "1.0",
        "documentation": "/docs"
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "database": "connected"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
