"""Bruteforce API routes"""

from fastapi import APIRouter, HTTPException
from app.models.schemas import BruteforceRequest
import subprocess
import re
from app.models.database import save_report

router = APIRouter()


@router.post("/")
async def bruteforce_attack(request: BruteforceRequest):
    """
    Launch Hydra brute-force attack
    
    - **service**: Service to attack (ssh, ftp, http, etc.)
    - **target_ip**: Target IP address
    - **username_list**: Path to username wordlist
    - **password_list**: Path to password wordlist
    - **port**: Specific port (optional)
    """
    try:
        # Validate IP
        ip_pattern = r'^(\d{1,3}\.){3}\d{1,3}$'
        if not re.match(ip_pattern, request.target_ip):
            raise HTTPException(status_code=400, detail="Invalid IP address")
        
        # Check wordlists exist
        if not all([
            request.username_list and request.password_list
        ]):
            raise HTTPException(status_code=400, detail="Wordlist paths required")
        
        # Build Hydra command
        cmd = [
            "hydra",
            "-L", request.username_list,
            "-P", request.password_list,
            request.target_ip,
            request.service
        ]
        
        if request.port:
            cmd.extend(["-s", str(request.port)])
        
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=600  # 10 minutes
        )
        
        # Save report
        report_id = save_report(
            report_type="bruteforce",
            target=f"{request.service}://{request.target_ip}",
            results=result.stdout,
            status="completed" if result.returncode == 0 else "failed"
        )
        
        return {
            "report_id": report_id,
            "status": "success" if result.returncode == 0 else "error",
            "output": result.stdout,
            "errors": result.stderr
        }
        
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="Bruteforce timeout exceeded")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
