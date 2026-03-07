"""Network monitoring service - Real-time network analysis and statistics"""

import subprocess
import json
import re
from typing import Dict, Any, List
from datetime import datetime


class NetworkMonitor:
    """Service for real-time network monitoring and analysis"""
    
    def __init__(self):
        self.tools = {
            "netstat": self._check_tool("netstat"),
            "ss": self._check_tool("ss"),
            "iftop": self._check_tool("iftop"),
            "nethogs": self._check_tool("nethogs"),
            "arpwatch": self._check_tool("arpwatch")
        }
    
    def _check_tool(self, tool_name: str) -> bool:
        """Check if a tool is installed"""
        result = subprocess.run(["which", tool_name], capture_output=True)
        return result.returncode == 0
    
    def get_active_connections(self) -> Dict[str, Any]:
        """Get all active network connections"""
        try:
            # Using ss command (modern replacement for netstat)
            cmd = ["ss", "-tunapl"]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            
            connections = []
            listening_ports = []
            
            for line in result.stdout.split('\n')[1:]:  # Skip header
                if not line.strip():
                    continue
                    
                parts = line.split()
                if len(parts) >= 6:
                    conn_type = parts[0]
                    state = parts[1] if 'LISTEN' not in parts[0] else 'LISTEN'
                    local_addr = parts[4] if conn_type.startswith('tcp') else parts[4]
                    peer_addr = parts[5] if len(parts) > 5 else '-'
                    process = parts[-1] if len(parts) > 6 else 'unknown'
                    
                    connection_info = {
                        "type": conn_type,
                        "state": state,
                        "local_address": local_addr,
                        "peer_address": peer_addr,
                        "process": process
                    }
                    
                    connections.append(connection_info)
                    
                    if 'LISTEN' in state:
                        listening_ports.append({
                            "address": local_addr,
                            "process": process
                        })
            
            return {
                "success": True,
                "total_connections": len(connections),
                "listening_ports": len(listening_ports),
                "connections": connections[:50],  # Limit to 50
                "listening_services": listening_ports,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "connections": [],
                "listening_ports": []
            }
    
    def get_network_interfaces(self) -> Dict[str, Any]:
        """Get information about network interfaces"""
        try:
            cmd = ["ip", "-j", "addr"]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0:
                interfaces = json.loads(result.stdout)
                
                interface_info = []
                for iface in interfaces:
                    info = {
                        "name": iface.get("ifname"),
                        "state": iface.get("operstate", "UNKNOWN"),
                        "mac_address": None,
                        "ipv4_addresses": [],
                        "ipv6_addresses": []
                    }
                    
                    # Get MAC address
                    if "address" in iface:
                        info["mac_address"] = iface["address"]
                    
                    # Get IP addresses
                    for addr_info in iface.get("addr_info", []):
                        family = addr_info.get("family")
                        address = addr_info.get("local")
                        
                        if family == "inet":
                            info["ipv4_addresses"].append(address)
                        elif family == "inet6":
                            info["ipv6_addresses"].append(address)
                    
                    interface_info.append(info)
                
                return {
                    "success": True,
                    "interfaces": interface_info,
                    "timestamp": datetime.now().isoformat()
                }
            else:
                # Fallback to ifconfig
                return self._get_interfaces_ifconfig()
                
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "interfaces": []
            }
    
    def _get_interfaces_ifconfig(self) -> Dict[str, Any]:
        """Fallback method using ifconfig"""
        try:
            cmd = ["ifconfig", "-a"]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            
            interfaces = []
            current_iface = None
            
            for line in result.stdout.split('\n'):
                if line and not line.startswith(' '):
                    # New interface
                    if current_iface:
                        interfaces.append(current_iface)
                    
                    parts = line.split()
                    current_iface = {
                        "name": parts[0].rstrip(':'),
                        "state": "UP" if "UP" in line else "DOWN",
                        "mac_address": None,
                        "ipv4_addresses": [],
                        "ipv6_addresses": []
                    }
                elif current_iface:
                    # Parse address lines
                    if 'inet ' in line:
                        match = re.search(r'inet (\d+\.\d+\.\d+\.\d+)', line)
                        if match:
                            current_iface["ipv4_addresses"].append(match.group(1))
                    elif 'inet6' in line:
                        match = re.search(r'inet6 ([\w:]+)', line)
                        if match:
                            current_iface["ipv6_addresses"].append(match.group(1))
                    elif 'ether' in line:
                        match = re.search(r'ether ([\w:]+)', line)
                        if match:
                            current_iface["mac_address"] = match.group(1)
            
            if current_iface:
                interfaces.append(current_iface)
            
            return {
                "success": True,
                "interfaces": interfaces,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "interfaces": []
            }
    
    def get_network_statistics(self) -> Dict[str, Any]:
        """Get network traffic statistics"""
        try:
            # Read /proc/net/dev for interface statistics
            with open('/proc/net/dev', 'r') as f:
                lines = f.readlines()[2:]  # Skip headers
            
            stats = {}
            for line in lines:
                parts = line.split(':')
                if len(parts) != 2:
                    continue
                
                iface = parts[0].strip()
                values = parts[1].split()
                
                if len(values) >= 9:
                    stats[iface] = {
                        "rx_bytes": int(values[0]),
                        "rx_packets": int(values[1]),
                        "rx_errors": int(values[2]),
                        "tx_bytes": int(values[8]),
                        "tx_packets": int(values[9]),
                        "tx_errors": int(values[10])
                    }
            
            return {
                "success": True,
                "statistics": stats,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "statistics": {}
            }
    
    def get_arp_table(self) -> Dict[str, Any]:
        """Get ARP table (IP to MAC address mappings)"""
        try:
            cmd = ["arp", "-an"]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            
            arp_entries = []
            
            for line in result.stdout.split('\n'):
                if not line.strip():
                    continue
                
                # Parse arp output
                match = re.match(r'(\S+)\s+\((\S+)\)\s+at\s+([A-Fa-f0-9:]+)', line)
                if match:
                    arp_entries.append({
                        "interface": match.group(1),
                        "ip_address": match.group(2),
                        "mac_address": match.group(3).upper()
                    })
            
            return {
                "success": True,
                "entries_count": len(arp_entries),
                "arp_table": arp_entries,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "arp_table": []
            }
    
    def detect_new_devices(self, known_macs: List[str] = None) -> Dict[str, Any]:
        """Detect new devices on the network"""
        try:
            arp_result = self.get_arp_table()
            
            if not arp_result["success"]:
                return arp_result
            
            current_macs = set()
            new_devices = []
            
            for entry in arp_result["arp_table"]:
                mac = entry["mac_address"]
                current_macs.add(mac)
                
                if known_macs and mac not in known_macs:
                    new_devices.append({
                        "ip_address": entry["ip_address"],
                        "mac_address": mac,
                        "interface": entry["interface"]
                    })
            
            return {
                "success": True,
                "total_devices": len(current_macs),
                "new_devices": new_devices,
                "all_devices": arp_result["arp_table"],
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "new_devices": []
            }
