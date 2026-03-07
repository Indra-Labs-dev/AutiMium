from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import subprocess
import sqlite3
import os
from datetime import datetime
from typing import Optional
import uuid

app = FastAPI(title="AutoMium API", version="1.0")

# CORS configuration for Flutter frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Local only - no security risk
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Database setup
DB_PATH = "data/reports.db"

def init_database():
    """Initialize SQLite database with required tables"""
    os.makedirs("data", exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Reports table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS reports (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            target TEXT,
            results TEXT,
            status TEXT DEFAULT 'completed',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    # Configurations table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS configurations (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    conn.commit()
    conn.close()

# Initialize database on startup
init_database()


@app.get("/")
def read_root():
    """Root endpoint - API status"""
    return {
        "status": "online",
        "service": "AutoMium Backend API",
        "version": "1.0",
        "timestamp": datetime.now().isoformat()
    }


@app.get("/status")
def get_status():
    """Check the status of Kali Linux tools"""
    tools = {
        "nmap": False,
        "yara": False,
        "hydra": False,
        "metasploit": False,
        "nikto": False,
        "peframe": False,
        "strings": False,
        "clamav": False
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
        "database": "connected" if os.path.exists(DB_PATH) else "not_initialized"
    }


@app.get("/scan")
def network_scan(
    ip: str,
    scan_type: str = "-sV",
    ports: Optional[str] = None
):
    """
    Launch nmap network scan
    
    Args:
        ip: Target IP address or CIDR
        scan_type: Nmap scan type (default: -sV)
        ports: Specific ports to scan (optional)
    """
    # Input validation - IP format
    import re
    ip_pattern = r'^(\d{1,3}\.){3}\d{1,3}(\/\d{1,2})?$'
    if not re.match(ip_pattern, ip):
        raise HTTPException(status_code=400, detail="Invalid IP address format")
    
    # Build command
    cmd = ["nmap", scan_type, ip]
    if ports:
        cmd.extend(["-p", ports])
    
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=300  # 5 minutes timeout
        )
        
        # Save report
        report_id = save_report(
            report_type="network_scan",
            target=ip,
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
        raise HTTPException(status_code=408, detail="Scan timeout exceeded")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/analyze/malware")
def analyze_malware(file_path: str, analysis_type: str = "static"):
    """
    Analyze suspicious file with YARA and other tools
    
    Args:
        file_path: Path to the file to analyze
        analysis_type: 'static' or 'dynamic'
    """
    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="File not found")
    
    results = {
        "file": file_path,
        "type": analysis_type,
        "yara_rules": [],
        "strings": [],
        "pe_info": {},
        "threats": []
    }
    
    try:
        # YARA analysis
        yara_cmd = ["yara", "-r", "/usr/share/yara/rules/", file_path]
        yara_result = subprocess.run(yara_cmd, capture_output=True, text=True)
        if yara_result.stdout:
            results["yara_rules"] = yara_result.stdout.strip().split('\n')
            results["threats"].extend(yara_result.stdout.strip().split('\n'))
        
        # Strings extraction
        strings_cmd = ["strings", file_path]
        strings_result = subprocess.run(strings_cmd, capture_output=True, text=True, timeout=30)
        results["strings"] = strings_result.stdout.split('\n')[:100]  # Limit to first 100
        
        # PE analysis if Windows executable
        if file_path.lower().endswith('.exe') or analysis_type == "peframe":
            peframe_cmd = ["peframe", file_path]
            peframe_result = subprocess.run(peframe_cmd, capture_output=True, text=True, timeout=60)
            results["pe_info"] = {"output": peframe_result.stdout}
        
        # Save report
        report_id = save_report(
            report_type="malware_analysis",
            target=file_path,
            results=str(results),
            status="completed"
        )
        
        return {
            "report_id": report_id,
            "status": "success",
            "results": results,
            "threat_detected": len(results["threats"]) > 0
        }
        
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="Analysis timeout")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/bruteforce")
def bruteforce_attack(
    service: str,
    target_ip: str,
    username_list: str,
    password_list: str,
    port: Optional[int] = None
):
    """
    Launch Hydra brute-force attack
    
    Args:
        service: Service to attack (ssh, ftp, http, etc.)
        target_ip: Target IP address
        username_list: Path to username wordlist
        password_list: Path to password wordlist
        port: Specific port (optional)
    """
    import re
    # Validate inputs
    ip_pattern = r'^(\d{1,3}\.){3}\d{1,3}$'
    if not re.match(ip_pattern, target_ip):
        raise HTTPException(status_code=400, detail="Invalid IP address")
    
    if not os.path.exists(username_list) or not os.path.exists(password_list):
        raise HTTPException(status_code=404, detail="Wordlist files not found")
    
    # Build Hydra command
    cmd = [
        "hydra",
        "-L", username_list,
        "-P", password_list,
        target_ip,
        service
    ]
    
    if port:
        cmd.extend(["-s", str(port)])
    
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=600  # 10 minutes timeout
        )
        
        report_id = save_report(
            report_type="bruteforce",
            target=f"{service}://{target_ip}",
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
        raise HTTPException(status_code=408, detail="Bruteforce timeout")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/report/{report_id}")
def get_report(report_id: str):
    """Retrieve a specific report by ID"""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    cursor.execute(
        "SELECT * FROM reports WHERE id = ?",
        (report_id,)
    )
    row = cursor.fetchone()
    conn.close()
    
    if not row:
        raise HTTPException(status_code=404, detail="Report not found")
    
    return {
        "id": row[0],
        "type": row[1],
        "target": row[2],
        "results": row[3],
        "status": row[4],
        "created_at": row[5]
    }


@app.get("/reports")
def get_all_reports(limit: int = 50):
    """Get all reports with optional limit"""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    cursor.execute(
        "SELECT * FROM reports ORDER BY created_at DESC LIMIT ?",
        (limit,)
    )
    rows = cursor.fetchall()
    conn.close()
    
    reports = []
    for row in rows:
        reports.append({
            "id": row[0],
            "type": row[1],
            "target": row[2],
            "results": row[3],
            "status": row[4],
            "created_at": row[5]
        })
    
    return {"reports": reports, "count": len(reports)}


@app.delete("/report/{report_id}")
def delete_report(report_id: str):
    """Delete a specific report"""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    cursor.execute(
        "DELETE FROM reports WHERE id = ?",
        (report_id,)
    )
    deleted = cursor.rowcount
    conn.commit()
    conn.close()
    
    if deleted == 0:
        raise HTTPException(status_code=404, detail="Report not found")
    
    return {"status": "success", "message": "Report deleted"}


def save_report(report_type: str, target: str, results: str, status: str = "completed") -> str:
    """Save report to database"""
    report_id = str(uuid.uuid4())
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    cursor.execute(
        """INSERT INTO reports (id, type, target, results, status) 
           VALUES (?, ?, ?, ?, ?)""",
        (report_id, report_type, target, results, status)
    )
    conn.commit()
    conn.close()
    
    return report_id


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
