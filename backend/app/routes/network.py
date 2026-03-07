"""Network scanning API routes"""

from fastapi import APIRouter, HTTPException
from typing import Optional
from app.models.schemas import ScanRequest, VulnerabilityScanRequest
from app.services.network_service import NetworkScanner
from app.models.database import save_report
import json

router = APIRouter()
scanner = NetworkScanner()


@router.get("/")
async def scan_status():
    """Get network scanning service status"""
    return {
        "service": "Network Scanning",
        "status": "online",
        "tools_available": scanner.tools
    }


@router.post("/scan")
async def network_scan(request: ScanRequest):
    """
    Launch comprehensive nmap network scan
    
    - **ip**: Target IP address or CIDR
    - **scan_type**: Nmap scan type (default: -sV)
    - **ports**: Specific ports to scan (optional)
    - **aggressive**: Enable aggressive mode (-T4)
    - **os_detection**: Enable OS detection (-O)
    - **script_scan**: Enable NSE scripts (--script=default)
    - **traceroute**: Enable traceroute (--traceroute)
    """
    try:
        # Execute scan
        result = scanner.scan(
            ip=request.ip,
            scan_type=request.scan_type,
            ports=request.ports,
            aggressive=request.aggressive,
            os_detection=request.os_detection,
            script_scan=request.script_scan,
            traceroute=request.traceroute
        )
        
        # Save report
        report_id = save_report(
            report_type="network_scan",
            target=request.ip,
            results=json.dumps(result["data"], indent=2),
            status="completed" if result["success"] else "failed"
        )
        
        return {
            "report_id": report_id,
            "status": "success" if result["success"] else "error",
            "scan_summary": result["data"]["summary"],
            "full_output": result["data"]["stdout"],
            "errors": result["errors"],
            "metadata": result["data"]
        }
        
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except TimeoutError as e:
        raise HTTPException(status_code=408, detail=str(e))
    except RuntimeError as e:
        raise HTTPException(status_code=503, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/vulnerabilities")
async def vulnerability_scan(request: VulnerabilityScanRequest):
    """
    Launch vulnerability-focused scan using nmap NSE scripts
    
    - **ip**: Target IP address
    - **ports**: Specific ports to scan (optional)
    """
    try:
        result = scanner.vulnerability_scan(
            ip=request.ip,
            ports=request.ports
        )
        
        # Save report
        report_id = save_report(
            report_type="vulnerability_scan",
            target=request.ip,
            results=result["output"],
            status="completed" if result["success"] else "failed"
        )
        
        return {
            "report_id": report_id,
            "status": "success" if result["success"] else "error",
            "output": result["output"],
            "vulnerabilities_found": result["vulnerabilities_found"],
            "vulnerability_details": result["vulnerability_details"],
            "errors": result["errors"]
        }
        
    except TimeoutError as e:
        raise HTTPException(status_code=408, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
