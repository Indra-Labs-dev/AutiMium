"""
Wireless Attacks Module
WiFi and wireless network security testing tools
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import Optional
import subprocess

router = APIRouter()


class WirelessRequest(BaseModel):
    interface: str = Field(..., description="Wireless interface (e.g., wlan0, wlan0mon)")
    tool: str = Field(default="airodump-ng", description="Wireless tool: airodump-ng, aireplay-ng, aircrack-ng, reaver")
    target_bssid: Optional[str] = Field(None, description="Target BSSID (MAC address)")
    channel: Optional[int] = Field(None, description="WiFi channel")


@router.post("/", tags=["Kali Tools - Wireless Attacks"])
async def wireless_attack(request: WirelessRequest):
    """
    Wireless Network Attacks
    
    Available tools:
    - airodump-ng: Packet capture
    - aireplay-ng: Packet injection
    - aircrack-ng: WEP/WPA cracking
    - reaver: WPS attacks
    """
    try:
        if request.tool == "airodump-ng":
            cmd = ["airodump-ng", "--write", "/tmp/capture", request.interface]
            if request.channel:
                cmd.extend(["--channel", str(request.channel)])
            # Run for 10 seconds only for safety
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
            
        elif request.tool == "aireplay-ng":
            if not request.target_bssid:
                raise HTTPException(status_code=400, detail="BSSID required for aireplay-ng")
            cmd = ["aireplay-ng", "--deauth", "10", "-a", request.target_bssid, request.interface]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            
        elif request.tool == "aircrack-ng":
            cmd = ["aircrack-ng", "/tmp/capture*.cap"]
            if request.target_bssid:
                cmd.extend(["-b", request.target_bssid])
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
            
        elif request.tool == "reaver":
            cmd = ["reaver", "-i", request.interface, "-c", str(request.channel or 1)]
            if request.target_bssid:
                cmd.extend(["-b", request.target_bssid])
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            
        else:
            raise HTTPException(status_code=400, detail=f"Unknown wireless tool: {request.tool}")
        
        return {
            "success": True,
            "tool": request.tool,
            "interface": request.interface,
            "output": result.stdout,
            "errors": result.stderr,
            "returncode": result.returncode
        }
        
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="Wireless attack timed out")
    except FileNotFoundError:
        raise HTTPException(
            status_code=503, 
            detail=f"Tool '{request.tool}' not found. Please ensure Kali tools are installed."
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")


@router.get("/tools", tags=["Kali Tools - Wireless Attacks"])
async def get_wireless_tools():
    """Get list of available wireless tools"""
    return {
        "category": "Wireless Attacks",
        "tools": [
            {
                "name": "airodump-ng",
                "description": "802.11 packet capture",
                "command": "airodump-ng [interface]"
            },
            {
                "name": "aireplay-ng",
                "description": "Packet injection and deauthentication",
                "command": "aireplay-ng --deauth [count] -a [BSSID] [interface]"
            },
            {
                "name": "aircrack-ng",
                "description": "WEP/WPA key recovery",
                "command": "aircrack-ng [capture file]"
            },
            {
                "name": "reaver",
                "description": "WPS brute force attack",
                "command": "reaver -i [interface] -b [BSSID]"
            }
        ]
    }
