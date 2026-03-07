"""WebSocket API routes"""

from fastapi import APIRouter, WebSocket, WebSocketDisconnect, HTTPException
from app.websocket.terminal import ConnectionManager
from app.websocket.executor import TerminalExecutor
import uuid

router = APIRouter()
ws_manager = ConnectionManager()
executor = TerminalExecutor()


@router.websocket("/ws/terminal")
async def terminal_websocket(websocket: WebSocket):
    """
    WebSocket endpoint for real-time terminal output
    
    Client sends: {"command": "nmap -sV 127.0.0.1"}
    Server responds:
        - type: "start" - Command started
        - type: "output" - Terminal output line
        - type: "complete" - Command finished
        - type: "error" - Error occurred
    """
    await ws_manager.connect(websocket, "global")
    
    try:
        while True:
            data = await websocket.receive_json()
            command = data.get("command")
            
            if not command:
                await ws_manager.send_personal_message({
                    "type": "error",
                    "error": "No command provided"
                }, "global")
                continue
            
            # Validate command (basic security)
            dangerous_commands = ["rm -rf /", "mkfs", ":(){:|:&}", "chmod -R 777 /"]
            if any(dc in command for dc in dangerous_commands):
                await ws_manager.send_personal_message({
                    "type": "error",
                    "error": "Command not allowed for security reasons"
                }, "global")
                continue
            
            # Execute command in background
            session_id = str(uuid.uuid4())
            asyncio.create_task(
                executor.execute_command(command, session_id, ws_manager)
            )
            
    except WebSocketDisconnect:
        ws_manager.disconnect("global")
    except Exception as e:
        print(f"WebSocket error: {e}")
        try:
            await ws_manager.send_personal_message({
                "type": "error",
                "error": str(e)
            }, "global")
        except:
            pass


@router.post("/terminal/execute")
async def execute_terminal_command(command: str, timeout: int = 60):
    """
    REST endpoint for executing terminal commands (synchronous)
    
    Args:
        command: Shell command to execute
        timeout: Maximum execution time in seconds
    
    Returns:
        Dictionary with stdout, stderr, returncode
    """
    try:
        import subprocess
        
        result = subprocess.run(
            command,
            shell=True,
            capture_output=True,
            text=True,
            timeout=timeout
        )
        
        return {
            "success": result.returncode == 0,
            "stdout": result.stdout,
            "stderr": result.stderr,
            "returncode": result.returncode,
            "command": command
        }
        
    except subprocess.TimeoutExpired:
        raise HTTPException(
            status_code=408,
            detail=f"Command timeout after {timeout} seconds"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Command execution failed: {str(e)}"
        )


@router.get("/terminal/sessions")
async def list_active_sessions():
    """Get number of active WebSocket connections"""
    return {
        "active_connections": ws_manager.get_connection_count(),
        "running_processes": len(executor.processes)
    }
