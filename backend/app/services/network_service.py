"""Network scanning service - orchestrates nmap and related tools"""

import subprocess
import json
import re
from typing import Optional, Dict, Any, List
from datetime import datetime


class NetworkScanner:
    """Service for network scanning operations"""
    
    def __init__(self):
        self.tools = {
            "nmap": self._check_tool("nmap"),
            "nikto": self._check_tool("nikto")
        }
    
    def _check_tool(self, tool_name: str) -> bool:
        """Check if a tool is installed"""
        result = subprocess.run(["which", tool_name], capture_output=True)
        return result.returncode == 0
    
    def validate_ip(self, ip: str) -> bool:
        """Validate IP address or CIDR format"""
        pattern = r'^(\d{1,3}\.){3}\d{1,3}(\/\d{1,2})?$'
        return bool(re.match(pattern, ip))
    
    def scan(
        self,
        ip: str,
        scan_type: str = "-sV",
        ports: Optional[str] = None,
        aggressive: bool = False,
        os_detection: bool = False,
        script_scan: bool = False,
        traceroute: bool = False
    ) -> Dict[str, Any]:
        """
        Execute comprehensive nmap scan
        
        Returns:
            Dictionary containing scan results and metadata
        """
        if not self.validate_ip(ip):
            raise ValueError(f"Invalid IP address format: {ip}")
        
        # Build command
        cmd = ["nmap", scan_type]
        
        if aggressive:
            cmd.append("-T4")
        
        if os_detection:
            cmd.append("-O")
        
        if script_scan:
            cmd.extend(["--script", "default,vuln"])
        
        if traceroute:
            cmd.append("--traceroute")
        
        if ports:
            cmd.extend(["-p", ports])
        
        cmd.append(ip)
        
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=600  # 10 minutes
            )
            
            # Parse results
            scan_data = self._parse_scan_results(result, cmd, ip, scan_type, ports)
            
            return {
                "success": result.returncode == 0,
                "data": scan_data,
                "errors": result.stderr
            }
            
        except subprocess.TimeoutExpired:
            raise TimeoutError("Scan timeout exceeded (10 minutes)")
        except FileNotFoundError:
            raise RuntimeError("Nmap is not installed or not in PATH")
    
    def _parse_scan_results(
        self,
        result: subprocess.CompletedProcess,
        cmd: List[str],
        ip: str,
        scan_type: str,
        ports: Optional[str]
    ) -> Dict[str, Any]:
        """Parse nmap output and extract structured data"""
        
        scan_data = {
            "command": " ".join(cmd),
            "exit_code": result.returncode,
            "stdout": result.stdout,
            "stderr": result.stderr,
            "target": ip,
            "scan_type": scan_type,
            "ports_scanned": ports or "default",
            "timestamp": datetime.now().isoformat()
        }
        
        # Extract port information
        open_ports = []
        closed_ports = []
        filtered_ports = []
        
        for line in result.stdout.split('\n'):
            if 'open' in line and '/' in line:
                parts = line.split()
                if len(parts) >= 3:
                    open_ports.append({
                        "port": parts[0],
                        "state": parts[1],
                        "service": parts[2] if len(parts) > 2 else "unknown"
                    })
            elif 'closed' in line and '/' in line:
                closed_ports.append(line.split()[0])
            elif 'filtered' in line and '/' in line:
                filtered_ports.append(line.split()[0])
        
        scan_data["summary"] = {
            "open_ports_count": len(open_ports),
            "closed_ports_count": len(closed_ports),
            "filtered_ports_count": len(filtered_ports),
            "open_ports": open_ports
        }
        
        return scan_data
    
    def vulnerability_scan(self, ip: str, ports: Optional[str] = None) -> Dict[str, Any]:
        """Execute vulnerability-focused scan using NSE scripts"""
        
        cmd = [
            "nmap",
            "--script", "vuln,exploit",
            "-sV",
            "-O",
            ip
        ]
        
        if ports:
            cmd.extend(["-p", ports])
        
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=900  # 15 minutes
            )
            
            # Extract vulnerabilities
            vulnerabilities = []
            for line in result.stdout.split('\n'):
                if any(keyword in line.lower() for keyword in ['vuln', 'cve', 'exploit']):
                    vulnerabilities.append(line.strip())
            
            return {
                "success": result.returncode == 0,
                "output": result.stdout,
                "vulnerabilities_found": len(vulnerabilities),
                "vulnerability_details": vulnerabilities[:50],
                "errors": result.stderr
            }
            
        except subprocess.TimeoutExpired:
            raise TimeoutError("Vulnerability scan timeout")
        except Exception as e:
            raise RuntimeError(f"Vulnerability scan failed: {str(e)}")
