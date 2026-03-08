"""
Digital Forensics Module
File system analysis and forensic investigation tools
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import Optional
import subprocess

router = APIRouter()


class ForensicRequest(BaseModel):
    target: str = Field(..., description="Target file, image, or device")
    tool: str = Field(default="binwalk", description="Forensic tool: binwalk, foremost, exiftool, strings")
    output_dir: Optional[str] = Field(None, description="Output directory for extracted files")


@router.post("/", tags=["Kali Tools - Forensics"])
async def forensics(request: ForensicRequest):
    """
    Digital Forensics and File Analysis
    
    Available tools:
    - binwalk: Firmware analysis and extraction
    - foremost: File carving and recovery
    - exiftool: Metadata extraction
    - strings: Extract strings from files
    - autopsy: Full forensic platform (GUI required)
    """
    try:
        if request.tool == "binwalk":
            cmd = ["binwalk", "-e", request.target]
            if request.output_dir:
                cmd.extend(["--directory", request.output_dir])
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            
        elif request.tool == "foremost":
            cmd = ["foremost", "-i", request.target]
            if request.output_dir:
                cmd.extend(["-o", request.output_dir])
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            
        elif request.tool == "exiftool":
            cmd = ["exiftool", request.target]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
            
        elif request.tool == "strings":
            cmd = ["strings", request.target]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
            
        else:
            raise HTTPException(status_code=400, detail=f"Unknown forensic tool: {request.tool}")
        
        return {
            "success": True,
            "tool": request.tool,
            "target": request.target,
            "output": result.stdout,
            "errors": result.stderr,
            "returncode": result.returncode
        }
        
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="Forensic analysis timed out")
    except FileNotFoundError:
        raise HTTPException(
            status_code=503, 
            detail=f"Tool '{request.tool}' not found. Please ensure Kali tools are installed."
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")


@router.get("/tools", tags=["Kali Tools - Forensics"])
async def get_forensic_tools():
    """Get list of available forensic tools"""
    return {
        "category": "Digital Forensics",
        "tools": [
            {
                "name": "binwalk",
                "description": "Firmware analysis tool",
                "command": "binwalk -e [firmware]"
            },
            {
                "name": "foremost",
                "description": "File carving tool",
                "command": "foremost -i [image]"
            },
            {
                "name": "exiftool",
                "description": "Metadata extractor",
                "command": "exiftool [file]"
            },
            {
                "name": "autopsy",
                "description": "Digital forensics platform",
                "command": "autopsy (GUI required)"
            }
        ]
    }
