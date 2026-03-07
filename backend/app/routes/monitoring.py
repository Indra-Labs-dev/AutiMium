"""Network monitoring API routes"""

from fastapi import APIRouter, HTTPException
from typing import Optional, List
from app.services.monitoring_service import NetworkMonitor

router = APIRouter()
monitor = NetworkMonitor()


@router.get("/")
async def monitoring_status():
    """Get network monitoring service status"""
    return {
        "service": "Network Monitoring",
        "status": "online",
        "tools_available": monitor.tools
    }


@router.get("/connections")
async def get_active_connections():
    """
    Get all active network connections
    
    Returns:
        - Total connections count
        - Listening ports
        - Connection details with process info
    """
    try:
        result = monitor.get_active_connections()
        
        if not result["success"]:
            raise HTTPException(status_code=500, detail=result.get("error", "Failed to get connections"))
        
        return result
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/interfaces")
async def get_network_interfaces():
    """
    Get information about network interfaces
    
    Returns:
        - Interface names and states
        - MAC addresses
        - IPv4 and IPv6 addresses
    """
    try:
        result = monitor.get_network_interfaces()
        
        if not result["success"]:
            raise HTTPException(status_code=500, detail=result.get("error", "Failed to get interfaces"))
        
        return result
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/statistics")
async def get_network_statistics():
    """
    Get network traffic statistics
    
    Returns:
        - RX/TX bytes per interface
        - Packet counts
        - Error counts
    """
    try:
        result = monitor.get_network_statistics()
        
        if not result["success"]:
            raise HTTPException(status_code=500, detail=result.get("error", "Failed to get statistics"))
        
        return result
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/arp")
async def get_arp_table():
    """
    Get ARP table (IP to MAC address mappings)
    
    Returns:
        - All ARP entries
        - Device count
    """
    try:
        result = monitor.get_arp_table()
        
        if not result["success"]:
            raise HTTPException(status_code=500, detail=result.get("error", "Failed to get ARP table"))
        
        return result
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/detect-devices")
async def detect_new_devices(known_macs: Optional[List[str]] = None):
    """
    Detect new devices on the network
    
    Args:
        known_macs: Optional list of known MAC addresses to exclude
    
    Returns:
        - New devices detected
        - Total device count
        - All devices list
    """
    try:
        result = monitor.detect_new_devices(known_macs or [])
        
        if not result["success"]:
            raise HTTPException(status_code=500, detail=result.get("error", "Failed to detect devices"))
        
        return result
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/listening-ports")
async def get_listening_ports():
    """
    Get all listening ports (simplified view)
    
    Returns:
        - List of ports accepting connections
        - Associated processes
    """
    try:
        result = monitor.get_active_connections()
        
        if not result["success"]:
            raise HTTPException(status_code=500, detail=result.get("error", "Failed to get listening ports"))
        
        # Return only listening services
        return {
            "listening_ports": result["listening_services"],
            "count": len(result["listening_services"]),
            "timestamp": result["timestamp"]
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
