"""Database models and schemas"""

from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime
import uuid


class ScanRequest(BaseModel):
    """Network scan request model"""
    ip: str = Field(..., description="Target IP address or CIDR")
    scan_type: str = Field(default="-sV", description="Nmap scan type")
    ports: Optional[str] = None
    aggressive: bool = False
    os_detection: bool = False
    script_scan: bool = False
    traceroute: bool = False


class VulnerabilityScanRequest(BaseModel):
    """Vulnerability scan request model"""
    ip: str = Field(..., description="Target IP address")
    ports: Optional[str] = None


class MalwareAnalysisRequest(BaseModel):
    """Malware analysis request model"""
    file_path: str = Field(..., description="Path to the file to analyze")
    analysis_type: str = Field(default="static", description="Analysis type: static, dynamic, or full")


class BruteforceRequest(BaseModel):
    """Bruteforce attack request model"""
    service: str = Field(..., description="Service to attack (ssh, ftp, http, etc.)")
    target_ip: str = Field(..., description="Target IP address")
    username_list: str = Field(..., description="Path to username wordlist")
    password_list: str = Field(..., description="Path to password wordlist")
    port: Optional[int] = None


class ReportResponse(BaseModel):
    """Report response model"""
    report_id: str
    status: str
    type: str
    target: str
    results: Optional[Any] = None
    created_at: datetime


class ScanSummary(BaseModel):
    """Scan results summary"""
    open_ports_count: int
    closed_ports_count: int
    filtered_ports_count: int
    open_ports: List[Dict[str, str]]


class ThreatAssessment(BaseModel):
    """Malware threat assessment"""
    level: str  # clean, suspicious, high, critical
    total_threats: int
    critical: int
    high: int


class IOC(BaseModel):
    """Indicator of Compromise"""
    type: str
    value: str
