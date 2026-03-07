"""Utility functions and helpers"""

import re
from typing import Optional


def validate_ip(ip: str) -> bool:
    """Validate IP address or CIDR format"""
    # IPv4 with optional CIDR
    pattern = r'^(\d{1,3}\.){3}\d{1,3}(\/\d{1,2})?$'
    return bool(re.match(pattern, ip))


def validate_ipv4(ip: str) -> bool:
    """Validate IPv4 address format"""
    pattern = r'^(\d{1,3}\.){3}\d{1,3}$'
    if not re.match(pattern, ip):
        return False
    
    # Check each octet is 0-255
    octets = ip.split('.')
    return all(0 <= int(octet) <= 255 for octet in octets)


def sanitize_input(text: str, max_length: int = 1000) -> str:
    """Sanitize user input to prevent injection attacks"""
    # Remove dangerous characters
    dangerous_chars = [';', '|', '&', '$', '`', '(', ')', '{', '}', '[', ']', '<', '>']
    sanitized = text
    for char in dangerous_chars:
        sanitized = sanitized.replace(char, '')
    
    # Truncate to max length
    return sanitized[:max_length]


def format_bytes(size: int) -> str:
    """Format bytes into human-readable format"""
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if size < 1024.0:
            return f"{size:.2f} {unit}"
        size /= 1024.0
    return f"{size:.2f} PB"


def parse_nmap_output(output: str) -> dict:
    """Parse nmap output into structured data"""
    result = {
        "open_ports": [],
        "closed_ports": [],
        "filtered_ports": [],
        "services": [],
        "os_info": None
    }
    
    for line in output.split('\n'):
        if 'open' in line and '/' in line:
            parts = line.split()
            if len(parts) >= 3:
                result["open_ports"].append({
                    "port": parts[0],
                    "state": parts[1],
                    "service": parts[2] if len(parts) > 2 else "unknown"
                })
        elif 'closed' in line and '/' in line:
            result["closed_ports"].append(line.split()[0])
        elif 'filtered' in line and '/' in line:
            result["filtered_ports"].append(line.split()[0])
    
    return result
