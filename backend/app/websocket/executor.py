"""WebSocket terminal execution service"""

import asyncio
import subprocess
from typing import Optional


class TerminalExecutor:
    """Execute shell commands and stream output via WebSocket"""
    
    def __init__(self):
        self.processes = {}
    
    async def execute_command(
        self,
        command: str,
        session_id: str,
        ws_manager
    ):
        """
        Execute command and stream output in real-time
        
        Args:
            command: Shell command to execute
            session_id: Unique session identifier
            ws_manager: WebSocket manager instance
        """
        try:
            # Send start message
            await ws_manager.send_personal_message({
                "type": "start",
                "command": command,
                "session_id": session_id
            }, session_id)
            
            # Execute command
            process = await asyncio.create_subprocess_shell(
                command,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            
            self.processes[session_id] = process
            
            # Stream stdout
            while True:
                line = await process.stdout.readline()
                if not line:
                    break
                
                decoded_line = line.decode('utf-8', errors='replace')
                
                # Send line to client
                await ws_manager.send_personal_message({
                    "type": "output",
                    "data": decoded_line,
                    "session_id": session_id
                }, session_id)
                
                # Small delay to prevent flooding
                await asyncio.sleep(0.01)
            
            # Wait for process to complete
            returncode = await process.wait()
            
            # Send completion message
            await ws_manager.send_personal_message({
                "type": "complete",
                "returncode": returncode,
                "session_id": session_id
            }, session_id)
            
        except Exception as e:
            await ws_manager.send_personal_message({
                "type": "error",
                "error": str(e),
                "session_id": session_id
            }, session_id)
        finally:
            if session_id in self.processes:
                del self.processes[session_id]
    
    def kill_process(self, session_id: str) -> bool:
        """Kill running process for a session"""
        if session_id in self.processes:
            process = self.processes[session_id]
            process.kill()
            del self.processes[session_id]
            return True
        return False
    
    def is_running(self, session_id: str) -> bool:
        """Check if process is still running"""
        return session_id in self.processes
