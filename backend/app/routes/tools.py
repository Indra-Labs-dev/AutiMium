"""Tools management API routes"""

from fastapi import APIRouter, HTTPException
import subprocess

router = APIRouter()


@router.get("/status")
async def tools_status():
    """Check status of all Kali Linux tools"""
    tools = {
        "nmap": False,
        "yara": False,
        "hydra": False,
        "metasploit": False,
        "nikto": False,
        "peframe": False,
        "strings": False,
        "clamav": False,
        "firejail": False
    }
    
    for tool in tools.keys():
        result = subprocess.run(
            ["which", tool],
            capture_output=True,
            text=True
        )
        tools[tool] = result.returncode == 0
    
    return {
        "backend": "running",
        "tools_available": tools,
        "database": "connected"
    }


@router.get("/install/{tool_name}")
async def install_tool(tool_name: str):
    """Get installation instructions for a missing tool"""
    tool_map = {
        "nmap": "nmap",
        "yara": "yara",
        "hydra": "hydra",
        "nikto": "nikto",
        "peframe": "peframe",
        "clamav": "clamav",
        "firejail": "firejail",
        "metasploit": "metasploit-framework"
    }
    
    if tool_name not in tool_map:
        raise HTTPException(
            status_code=400,
            detail=f"Unknown tool: {tool_name}. Available: {list(tool_map.keys())}"
        )
    
    package_name = tool_map[tool_name]
    
    return {
        "status": "info",
        "message": f"To install {tool_name}, run:",
        "command": f"sudo apt-get install -y {package_name}",
        "package": package_name
    }
