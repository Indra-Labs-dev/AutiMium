"""
Password Attacks Module
Brute-force and password cracking tools
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import Optional
import subprocess

router = APIRouter()


class PasswordAttackRequest(BaseModel):
    service: str = Field(..., description="Target service: ssh, ftp, http, smb, etc.")
    target: str = Field(..., description="Target IP or hostname")
    tool: str = Field(default="hydra", description="Password attack tool: hydra, john, hashcat")
    username_list: Optional[str] = Field(None, description="Path to username wordlist")
    password_list: Optional[str] = Field(None, description="Path to password wordlist")
    port: Optional[int] = Field(None, description="Target port")


@router.post("/", tags=["Kali Tools - Password Attacks"])
async def password_attack(request: PasswordAttackRequest):
    """
    Password Attacks and Brute-forcing
    
    Available tools:
    - hydra: Online brute-force attacker
    - john: John the Ripper password cracker
    - hashcat: Advanced password recovery
    """
    try:
        if request.tool == "hydra":
            cmd = ["hydra"]
            
            if request.username_list:
                cmd.extend(["-L", request.username_list])
            else:
                cmd.extend(["-l", "admin"])  # Default username
            
            if request.password_list:
                cmd.extend(["-P", request.password_list])
            else:
                cmd.extend(["-p", "password"])  # Default password
            
            if request.port:
                cmd.extend(["-s", str(request.port)])
            
            cmd.extend([request.target, request.service])
            
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            
        elif request.tool == "john":
            if not request.password_list:
                raise HTTPException(status_code=400, detail="Hash file required for john")
            
            cmd = ["john", request.password_list]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
            
        elif request.tool == "hashcat":
            if not request.password_list:
                raise HTTPException(status_code=400, detail="Hash file required for hashcat")
            
            cmd = ["hashcat", "-m", "0", request.password_list, "/usr/share/wordlists/rockyou.txt"]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
            
        else:
            raise HTTPException(status_code=400, detail=f"Unknown password attack tool: {request.tool}")
        
        return {
            "success": True,
            "tool": request.tool,
            "target": f"{request.service}://{request.target}",
            "output": result.stdout,
            "errors": result.stderr,
            "returncode": result.returncode
        }
        
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="Password attack timed out")
    except FileNotFoundError:
        raise HTTPException(
            status_code=503, 
            detail=f"Tool '{request.tool}' not found. Please ensure Kali tools are installed."
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")


@router.get("/tools", tags=["Kali Tools - Password Attacks"])
async def get_password_tools():
    """Get list of available password attack tools"""
    return {
        "category": "Password Attacks",
        "tools": [
            {
                "name": "hydra",
                "description": "Online brute-force attacker",
                "command": "hydra -L [users] -P [passwords] [target] [service]"
            },
            {
                "name": "john",
                "description": "Offline password cracker",
                "command": "john [hash file]"
            },
            {
                "name": "hashcat",
                "description": "GPU-accelerated password recovery",
                "command": "hashcat -m [mode] [hashes] [wordlist]"
            }
        ]
    }
