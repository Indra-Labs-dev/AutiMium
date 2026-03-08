"""
Web Application Attacks Module
SQL injection, XSS, and web vulnerability scanning tools
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import Optional
import subprocess

router = APIRouter()


class WebAttackRequest(BaseModel):
    target: str = Field(..., description="Target URL (e.g., http://example.com/vuln.php?id=1)")
    tool: str = Field(default="sqlmap", description="Web attack tool: sqlmap, nikto, wpscan, dalfox")
    options: Optional[str] = Field(None, description="Additional command-line options")


@router.post("/", tags=["Kali Tools - Web Application Attacks"])
async def web_attack(request: WebAttackRequest):
    """
    Web Application Security Testing
    
    Available tools:
    - sqlmap: SQL injection testing
    - nikto: Web server scanner
    - wpscan: WordPress security scanner
    - dalfox: XSS scanner
    """
    try:
        if request.tool == "sqlmap":
            cmd = [
                "sqlmap",
                "-u", request.target,
                "--batch",
                "--random-agent"
            ]
            if request.options:
                cmd.extend(request.options.split())
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
            
        elif request.tool == "nikto":
            cmd = ["nikto", "-h", request.target]
            if request.options:
                cmd.extend(request.options.split())
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            
        elif request.tool == "wpscan":
            cmd = ["wpscan", "--url", request.target, "--no-update"]
            if request.options:
                cmd.extend(request.options.split())
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            
        elif request.tool == "dalfox":
            cmd = ["dalfox", "url", request.target]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
            
        else:
            raise HTTPException(status_code=400, detail=f"Unknown web attack tool: {request.tool}")
        
        return {
            "success": True,
            "tool": request.tool,
            "target": request.target,
            "output": result.stdout,
            "errors": result.stderr,
            "returncode": result.returncode
        }
        
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="Web attack timed out")
    except FileNotFoundError:
        raise HTTPException(
            status_code=503, 
            detail=f"Tool '{request.tool}' not found. Please ensure Kali tools are installed."
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")


@router.get("/tools", tags=["Kali Tools - Web Application Attacks"])
async def get_web_tools():
    """Get list of available web attack tools"""
    return {
        "category": "Web Application Attacks",
        "tools": [
            {
                "name": "sqlmap",
                "description": "SQL injection and database takeover",
                "command": "sqlmap -u [URL]"
            },
            {
                "name": "nikto",
                "description": "Web server scanner",
                "command": "nikto -h [URL]"
            },
            {
                "name": "wpscan",
                "description": "WordPress security scanner",
                "command": "wpscan --url [URL]"
            },
            {
                "name": "dalfox",
                "description": "XSS vulnerability scanner",
                "command": "dalfox url [URL]"
            }
        ]
    }
