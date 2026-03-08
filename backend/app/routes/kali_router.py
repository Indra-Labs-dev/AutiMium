"""
Kali Linux Tools - Main Router
Aggregates all modular Kali tool routers
"""

from fastapi import APIRouter

# Import all routers from the kali_tools package
from app.routes.kali_tools import (
    recon_router,
    scanning_router,
    exploitation_router,
    malware_router,
    forensics_router,
    wireless_router,
    password_router,
    web_router,
    sniffing_router
)

router = APIRouter()

# Include all routers with appropriate prefixes
router.include_router(recon_router, prefix="/recon")
router.include_router(scanning_router, prefix="/scan")
router.include_router(exploitation_router, prefix="/exploit")
router.include_router(malware_router, prefix="/malware")
router.include_router(forensics_router, prefix="/forensics")
router.include_router(wireless_router, prefix="/wireless")
router.include_router(password_router, prefix="/password")
router.include_router(web_router, prefix="/web")
router.include_router(sniffing_router, prefix="/sniffing")


@router.get("/", tags=["Kali Tools"])
async def kali_tools_index():
    """Index endpoint for Kali Tools API"""
    return {
        "message": "AutoMium Kali Linux Tools API",
        "version": "2.5",
        "categories": [
            {"name": "Reconnaissance", "endpoint": "/kali/recon"},
            {"name": "Scanning & Enumeration", "endpoint": "/kali/scan"},
            {"name": "Exploitation", "endpoint": "/kali/exploit"},
            {"name": "Malware Analysis", "endpoint": "/kali/malware"},
            {"name": "Forensics", "endpoint": "/kali/forensics"},
            {"name": "Wireless Attacks", "endpoint": "/kali/wireless"},
            {"name": "Password Attacks", "endpoint": "/kali/password"},
            {"name": "Web Application Attacks", "endpoint": "/kali/web"},
            {"name": "Sniffing & Spoofing", "endpoint": "/kali/sniffing"}
        ],
        "documentation": "/docs"
    }
