"""
WebSocket Terminal Client Example
Test the real-time terminal output feature
"""

import asyncio
import websockets


async def test_terminal():
    """Test WebSocket terminal connection"""
    
    uri = "ws://localhost:8000/ws/terminal"
    
    async with websockets.connect(uri) as websocket:
        print(f"✅ Connected to WebSocket server")
        print(f"📡 Sending command: 'nmap -sV 127.0.0.1'\n")
        
        # Send command
        await websocket.send('{"command": "nmap -sV 127.0.0.1"}')
        
        # Receive and display output in real-time
        while True:
            try:
                response = await websocket.recv()
                data = response if isinstance(response, dict) else eval(response)
                
                msg_type = data.get("type", "unknown")
                
                if msg_type == "start":
                    print(f"🚀 Command started: {data.get('command')}")
                
                elif msg_type == "output":
                    # Print output line by line
                    print(data.get("data"), end="")
                
                elif msg_type == "complete":
                    print(f"\n✅ Command completed with return code: {data.get('returncode')}")
                    break
                
                elif msg_type == "error":
                    print(f"❌ Error: {data.get('error')}")
                    break
                
            except Exception as e:
                print(f"Error receiving message: {e}")
                break


if __name__ == "__main__":
    print("=" * 60)
    print("AutoMium WebSocket Terminal Test")
    print("=" * 60)
    print()
    
    try:
        asyncio.run(test_terminal())
    except KeyboardInterrupt:
        print("\n\n⚠️  Interrupted by user")
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        print("\nMake sure the backend server is running:")
        print("  cd backend && ./start.sh")
