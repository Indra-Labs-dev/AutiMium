#!/usr/bin/env python3
"""
AutoMium Automation Scripts Framework
Allows chaining multiple security tools and operations together
"""

import subprocess
import json
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional


class AutomationScript:
    """Base class for automation scripts"""
    
    def __init__(self, name: str, description: str):
        self.name = name
        self.description = description
        self.steps: List[Dict] = []
        self.results: List[Dict] = []
    
    def add_step(self, command: str, description: str = "", timeout: int = 300):
        """Add a step to the automation script"""
        self.steps.append({
            "command": command,
            "description": description,
            "timeout": timeout
        })
    
    def execute_step(self, step: Dict) -> Dict:
        """Execute a single step"""
        print(f"\n{'='*60}")
        print(f"Executing: {step.get('description', 'Step')}")
        print(f"Command: {step['command']}")
        print(f"{'='*60}\n")
        
        try:
            result = subprocess.run(
                step['command'],
                shell=True,
                capture_output=True,
                text=True,
                timeout=step.get('timeout', 300)
            )
            
            return {
                "success": True,
                "returncode": result.returncode,
                "stdout": result.stdout,
                "stderr": result.stderr,
                "description": step.get('description', '')
            }
        
        except subprocess.TimeoutExpired:
            return {
                "success": False,
                "error": f"Command timed out after {step.get('timeout', 300)} seconds",
                "description": step.get('description', '')
            }
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "description": step.get('description', '')
            }
    
    def run(self) -> bool:
        """Execute all steps in sequence"""
        print(f"\n🚀 Starting Automation Script: {self.name}")
        print(f"Description: {self.description}")
        print(f"Total steps: {len(self.steps)}")
        print(f"Started at: {datetime.now().isoformat()}")
        
        self.results = []
        
        for i, step in enumerate(self.steps, 1):
            print(f"\n[{i}/{len(self.steps)}]")
            result = self.execute_step(step)
            self.results.append(result)
            
            if not result['success']:
                print(f"\n❌ Step failed: {result.get('error', 'Unknown error')}")
                # Continue execution even if a step fails
        
        print(f"\n✅ Automation script completed!")
        print(f"Finished at: {datetime.now().isoformat()}")
        print(f"Results: {sum(1 for r in self.results if r['success'])}/{len(self.results)} steps successful")
        
        return all(r['success'] for r in self.results)
    
    def save_report(self, output_dir: str = "data/reports"):
        """Save execution report to file"""
        output_path = Path(output_dir)
        output_path.mkdir(parents=True, exist_ok=True)
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{self.name}_{timestamp}.json"
        filepath = output_path / filename
        
        report = {
            "script_name": self.name,
            "description": self.description,
            "started_at": timestamp,
            "steps_executed": len(self.steps),
            "results": self.results
        }
        
        with open(filepath, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"\n📄 Report saved to: {filepath}")
        return filepath


# Example automation scripts
class NetworkReconScript(AutomationScript):
    """Complete network reconnaissance automation"""
    
    def __init__(self, target_ip: str, output_dir: str = "data/reports"):
        super().__init__(
            name="Network Reconnaissance",
            description=f"Complete network scan and vulnerability assessment for {target_ip}"
        )
        
        self.target_ip = target_ip
        self.output_dir = output_dir
        
        # Define the automation steps
        self.add_step(
            f"nmap -sV -sC {target_ip}",
            description="Service version detection and default scripts",
            timeout=300
        )
        
        self.add_step(
            f"nmap --script vuln {target_ip}",
            description="Vulnerability scanning",
            timeout=600
        )
        
        self.add_step(
            f"nikto -h http://{target_ip}",
            description="Web server vulnerability scan",
            timeout=300
        )


class MalwareAnalysisScript(AutomationScript):
    """Automated malware analysis workflow"""
    
    def __init__(self, file_path: str):
        super().__init__(
            name="Malware Analysis",
            description=f"Static and dynamic analysis of {file_path}"
        )
        
        self.file_path = file_path
        
        # Define the automation steps
        self.add_step(
            f"strings {file_path} | head -100",
            description="Extract strings from file",
            timeout=60
        )
        
        self.add_step(
            f"yara -r /usr/share/yara/rules/malware_rules/ {file_path}",
            description="YARA rule matching",
            timeout=120
        )
        
        self.add_step(
            f"peframe {file_path}",
            description="PE file analysis",
            timeout=60
        )


def main():
    """Main entry point for automation scripts"""
    if len(sys.argv) < 2:
        print("Usage: python automation.py <script_type> <target>")
        print("\nAvailable script types:")
        print("  network <ip>     - Network reconnaissance")
        print("  malware <file>   - Malware analysis")
        print("  custom <json>    - Custom script from JSON file")
        sys.exit(1)
    
    script_type = sys.argv[1]
    
    if script_type == "network":
        if len(sys.argv) < 3:
            print("Error: Please provide target IP")
            sys.exit(1)
        
        script = NetworkReconScript(sys.argv[2])
        success = script.run()
        script.save_report()
        
    elif script_type == "malware":
        if len(sys.argv) < 3:
            print("Error: Please provide file path")
            sys.exit(1)
        
        script = MalwareAnalysisScript(sys.argv[2])
        success = script.run()
        script.save_report()
    
    elif script_type == "custom":
        if len(sys.argv) < 3:
            print("Error: Please provide JSON config file")
            sys.exit(1)
        
        with open(sys.argv[2], 'r') as f:
            config = json.load(f)
        
        script = AutomationScript(
            name=config.get('name', 'Custom Script'),
            description=config.get('description', 'Custom automation script')
        )
        
        for step in config.get('steps', []):
            script.add_step(
                step['command'],
                description=step.get('description', ''),
                timeout=step.get('timeout', 300)
            )
        
        success = script.run()
        script.save_report()
    
    else:
        print(f"Unknown script type: {script_type}")
        sys.exit(1)
    
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
