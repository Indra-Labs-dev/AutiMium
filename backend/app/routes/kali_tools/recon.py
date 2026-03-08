"""
Reconnaissance Tools Module
Information gathering and OSINT tools
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import Optional
import subprocess

router = APIRouter()


class ReconRequest(BaseModel):
    target: str = Field(..., description="Target IP or domain")
    tool: str = Field(default="theHarvester", description="Recon tool to use")
    options: Optional[str] = None


@router.post("/", tags=["Kali Tools - Reconnaissance"])
async def reconnaissance(request: ReconRequest):
    """
    Information Gathering & Reconnaissance
    
    Available tools:
    - theHarvester: Email and subdomain enumeration
    - whois: Domain information lookup
    - nslookup: DNS queries
    - dnsrecon: DNS enumeration
    - maltego: OSINT and link analysis (requires GUI)
    - recon-ng: Web-based reconnaissance framework
    """
    try:
        if request.tool == "theHarvester":
            cmd = ["theHarvester", "-d", request.target, "-b", "google,linkedin,github"]
            if request.options:
                cmd.extend(request.options.split())
                
        elif request.tool == "whois":
            cmd = ["whois", request.target]
            
        elif request.tool == "nslookup":
            cmd = ["nslookup", request.target]
            
        elif request.tool == "dnsrecon":
            cmd = ["dnsrecon", "-d", request.target]
            if request.options:
                cmd.extend(request.options.split())
                
        elif request.tool == "recon-ng":
            # Recon-ng requires workspace setup
            raise HTTPException(
                status_code=400, 
                detail="recon-ng requires manual setup. Please use theHarvester or other tools."
            )
            
        else:
            raise HTTPException(status_code=400, detail=f"Unknown recon tool: {request.tool}")
        
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
        
        return {
            "success": True,
            "tool": request.tool,
            "target": request.target,
            "output": result.stdout,
            "errors": result.stderr,
            "returncode": result.returncode
        }
        
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="Reconnaissance timed out (120s)")
    except FileNotFoundError:
        raise HTTPException(
            status_code=503, 
            detail=f"Tool '{request.tool}' not found. Please ensure Kali tools are installed."
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")


@router.get("/tools", tags=["Kali Tools - Reconnaissance"])
async def get_recon_tools():
    """Get list of available reconnaissance tools"""
    return {
        "category": "Reconnaissance",
        "tools": [
            {
                "name": "theHarvester",
                "description": "Email, subdomain, and name enumeration",
                "command": "theHarvester -d [domain] -b [sources]"
            },
            {
                "name": "whois",
                "description": "Domain registration information lookup",
                "command": "whois [domain]"
            },
            {
                "name": "nslookup",
                "description": "DNS name server lookup",
                "command": "nslookup [domain]"
            },
            {
                "name": "dnsrecon",
                "description": "DNS enumeration and scanning",
                "command": "dnsrecon -d [domain]"
            },
            {
                "name": "recon-ng",
                "description": "Full-featured web reconnaissance framework",
                "command": "recon-ng (interactive)"
            }
        ]
    }
