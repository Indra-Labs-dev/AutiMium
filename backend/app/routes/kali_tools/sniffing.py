"""
Sniffing & Spoofing Module
Network packet capture and MITM attack tools
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import Optional
import subprocess

router = APIRouter()


class SniffingRequest(BaseModel):
    interface: str = Field(..., description="Network interface (e.g., eth0, wlan0)")
    tool: str = Field(default="tcpdump", description="Sniffing tool: tcpdump, arpspoof, bettercap")
    target: Optional[str] = Field(None, description="Target IP for MITM attacks")
    duration: int = Field(default=30, description="Capture duration in seconds")


@router.post("/", tags=["Kali Tools - Sniffing & Spoofing"])
async def sniffing_spoofing(request: SniffingRequest):
    """
    Network Sniffing and Spoofing Attacks
    
    Available tools:
    - tcpdump: Packet capture and analysis
    - arpspoof: ARP cache poisoning
    - bettercap: Advanced MITM framework
    - wireshark: GUI packet analyzer (requires display)
    """
    try:
        if request.tool == "tcpdump":
            cmd = [
                "tcpdump",
                "-i", request.interface,
                "-c", "100",  # Capture 100 packets
                "-w", "/tmp/capture.pcap"
            ]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=request.duration)
            
        elif request.tool == "arpspoof":
            if not request.target:
                raise HTTPException(status_code=400, detail="Target IP required for ARP spoofing")
            
            cmd = ["arpspoof", "-i", request.interface, "-t", request.target]
            # Run for specified duration then stop
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=request.duration)
            
        elif request.tool == "bettercap":
            # Bettercap requires interactive session, provide basic command
            raise HTTPException(
                status_code=400,
                detail="Bettercap requires manual setup via CLI. Use tcpdump or arpspoof for automated operations."
            )
            
        else:
            raise HTTPException(status_code=400, detail=f"Unknown sniffing tool: {request.tool}")
        
        return {
            "success": True,
            "tool": request.tool,
            "interface": request.interface,
            "output": result.stdout,
            "errors": result.stderr,
            "returncode": result.returncode
        }
        
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="Sniffing operation timed out")
    except FileNotFoundError:
        raise HTTPException(
            status_code=503, 
            detail=f"Tool '{request.tool}' not found. Please ensure Kali tools are installed."
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")


@router.get("/tools", tags=["Kali Tools - Sniffing & Spoofing"])
async def get_sniffing_tools():
    """Get list of available sniffing tools"""
    return {
        "category": "Sniffing & Spoofing",
        "tools": [
            {
                "name": "tcpdump",
                "description": "Command-line packet analyzer",
                "command": "tcpdump -i [interface] -c [count]"
            },
            {
                "name": "arpspoof",
                "description": "ARP cache poisoning",
                "command": "arpspoof -i [interface] -t [target]"
            },
            {
                "name": "bettercap",
                "description": "Advanced MITM framework",
                "command": "bettercap (interactive)"
            },
            {
                "name": "wireshark",
                "description": "GUI network protocol analyzer",
                "command": "wireshark (GUI required)"
            }
        ]
    }
