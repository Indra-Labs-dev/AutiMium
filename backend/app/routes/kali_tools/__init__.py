"""
Kali Linux Tools - Modular Implementation
Comprehensive security tools orchestration platform
"""

from .recon import router as recon_router
from .scanning import router as scanning_router
from .exploitation import router as exploitation_router
from .malware import router as malware_router
from .forensics import router as forensics_router
from .wireless import router as wireless_router
from .password_attacks import router as password_router
from .web_attacks import router as web_router
from .sniffing import router as sniffing_router

__all__ = [
    "recon_router",
    "scanning_router", 
    "exploitation_router",
    "malware_router",
    "forensics_router",
    "wireless_router",
    "password_router",
    "web_router",
    "sniffing_router",
]
