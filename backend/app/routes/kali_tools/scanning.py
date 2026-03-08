"""
Scanning & Enumeration Module
Network scanning and service enumeration tools
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import Optional
import subprocess

router = APIRouter()


class ScanRequest(BaseModel):
    target: str = Field(..., description="Target IP or network (e.g., 192.168.1.1 or 192.168.1.0/24)")
    tool: str = Field(default="nmap", description="Scanning tool: nmap, masscan, enum4linux, nikto, gobuster")
    ports: Optional[str] = Field(None, description="Ports to scan (e.g., '22,80,443' or '1-1000')")
    aggressive: bool = Field(False, description="Enable aggressive scan mode")
    options: Optional[str] = Field(None, description="Additional command-line options")


@router.post("/", tags=["Kali Tools - Scanning"])
async def scan_enumeration(request: ScanRequest):
    """
    Advanced Scanning & Enumeration
    
    Available tools:
    - nmap: Network mapper and port scanner
    - masscan: Fast TCP port scanner
    - enum4linux: SMB/CIFS enumeration
    - nikto: Web server scanner
    - gobuster: Directory and DNS brute-forcer
    """
    try:
        if request.tool == "nmap":
            cmd = ["nmap"]
            if request.ports:
                cmd.extend(["-p", request.ports])
            else:
                cmd.extend(["-p", "1-1000"])  # Default top 1000 ports
            
            cmd.extend(["-sV", "-sC", request.target])  # Version detection + default scripts
            
            if request.aggressive:
                cmd.append("-A")  # Aggressive mode: OS detection, version detection, script scanning, traceroute
                
            if request.options:
                cmd.extend(request.options.split())
                
        elif request.tool == "masscan":
            cmd = ["masscan"]
            if request.ports:
                cmd.extend(["-p", request.ports])
            else:
                cmd.extend(["-p", "1-65535"])  # Default all ports
            
            cmd.extend(["--rate=1000", request.target])  # 1000 packets per second
            
        elif request.tool == "enum4linux":
            cmd = ["enum4linux"]
            if request.aggressive:
                cmd.append("-a")  # All options
            cmd.append(request.target)
            
        elif request.tool == "nikto":
            cmd = ["nikto", "-h", request.target]
            if request.options:
                cmd.extend(request.options.split())
                
        elif request.tool == "gobuster":
            if "dir" in (request.options or ""):
                cmd = ["gobuster", "dir", "-u", f"http://{request.target}", "-w", "/usr/share/wordlists/dirb/common.txt"]
            else:
                cmd = ["gobuster", "dns", "-d", request.target]
        else:
            raise HTTPException(status_code=400, detail=f"Unknown scanning tool: {request.tool}")
        
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
        
        return {
            "success": True,
            "tool": request.tool,
            "target": request.target,
            "scan_type": request.tool,
            "output": result.stdout,
            "errors": result.stderr,
            "returncode": result.returncode
        }
        
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="Scan timed out (300s)")
    except FileNotFoundError:
        raise HTTPException(
            status_code=503, 
            detail=f"Tool '{request.tool}' not found. Please ensure Kali tools are installed."
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")


@router.get("/tools", tags=["Kali Tools - Scanning"])
async def get_scanning_tools():
    """Get list of available scanning tools"""
    return {
        "category": "Scanning & Enumeration",
        "tools": [
            {
                "name": "nmap",
                "description": "Network exploration and security auditing",
                "command": "nmap -sV -sC [target]"
            },
            {
                "name": "masscan",
                "description": "Fastest Internet-scale port scanner",
                "command": "masscan -p 1-65535 [target]"
            },
            {
                "name": "enum4linux",
                "description": "Windows/SMB enumeration tool",
                "command": "enum4linux -a [target]"
            },
            {
                "name": "nikto",
                "description": "Web server scanner",
                "command": "nikto -h [url]"
            },
            {
                "name": "gobuster",
                "description": "Directory/file brute-forcer",
                "command": "gobuster dir -u [url] -w [wordlist]"
            }
        ]
    }
