# AutoMium Backend API - Complete Documentation

## 🎯 Overview

AutoMium Backend is a **modular, production-ready FastAPI application** designed for cybersecurity operations orchestration. It provides REST APIs and WebSocket endpoints for:

- 🔍 Network scanning (Nmap integration)
- 🦠 Malware analysis (YARA, PEFrame, ClamAV)
- 💥 Bruteforce attacks (Hydra)
- 📊 Report generation (PDF, JSON)
- 💬 Real-time terminal output (WebSocket)

---

## 📁 Modular Architecture

```
backend/
├── app/                      # Main application package
│   ├── __main__.py          # ⭐ Application entry point
│   │
│   ├── routes/              # 🌐 API endpoints
│   │   ├── network.py       # /scan/* endpoints
│   │   ├── malware.py       # /analyze/* endpoints
│   │   ├── bruteforce.py    # /bruteforce/* endpoints
│   │   ├── reports.py       # /reports/* endpoints
│   │   ├── tools.py         # /tools/* endpoints
│   │   └── websocket_routes.py  # WebSocket endpoints
│   │
│   ├── services/            # ⚙️ Business logic
│   │   ├── network_service.py    # Nmap orchestration
│   │   └── malware_service.py    # Malware analysis
│   │
│   ├── models/              # 🗄️ Data layer
│   │   ├── schemas.py       # Pydantic validation
│   │   └── database.py      # SQLite operations
│   │
│   ├── websocket/           # 🔌 Real-time features
│   │   ├── terminal.py      # Connection manager
│   │   └── executor.py      # Command executor
│   │
│   └── utils/               # 🛠️ Helpers
│       └── helpers.py       # Validation, sanitization
│
├── data/                    # Database & reports (auto-generated)
├── requirements.txt
└── start.sh                # Startup script
```

### Why This Structure?

✅ **Separation of Concerns**: Each layer has a specific responsibility  
✅ **Maintainability**: Easy to find and modify code  
✅ **Testability**: Services can be tested independently  
✅ **Scalability**: Easy to add new features  
✅ **Professional**: Industry-standard architecture  

---

## 🚀 Quick Start

### Prerequisites

- Python 3.8+
- Kali Linux tools (optional): nmap, yara, hydra, nikto

### Installation

```bash
cd backend

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate  # Linux/Mac
# or
venv\Scripts\activate     # Windows

# Install dependencies
pip install -r requirements.txt
```

### Start the Server

```bash
# Using the startup script
./start.sh

# Or manually
python -m uvicorn app.__main__:app --host 0.0.0.0 --port 8000 --reload
```

### Access API Documentation

Open your browser:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

---

## 📡 API Endpoints

### 1. Network Scanning (`/scan`)

#### Scan Network
```bash
POST /scan/scan
Content-Type: application/json

{
  "ip": "192.168.1.1",
  "scan_type": "-sV",
  "ports": "22,80,443",
  "aggressive": true,
  "os_detection": false,
  "script_scan": true,
  "traceroute": false
}
```

#### Vulnerability Scan
```bash
POST /scan/vulnerabilities
Content-Type: application/json

{
  "ip": "192.168.1.1",
  "ports": "80"
}
```

### 2. Malware Analysis (`/analyze`)

#### Analyze File
```bash
POST /analyze/malware
Content-Type: application/json

{
  "file_path": "/path/to/suspicious.exe",
  "analysis_type": "static"  # static, dynamic, or full
}
```

### 3. Bruteforce (`/bruteforce`)

#### Hydra Attack
```bash
POST /bruteforce
Content-Type: application/json

{
  "service": "ssh",
  "target_ip": "192.168.1.1",
  "username_list": "/usr/share/wordlists/usernames.txt",
  "password_list": "/usr/share/wordlists/passwords.txt",
  "port": 22
}
```

### 4. Reports (`/reports`)

#### List All Reports
```bash
GET /reports/?limit=50
```

#### Get Specific Report
```bash
GET /reports/{report_id}
```

#### Export Report
```bash
POST /reports/export/{report_id}?format=pdf
# or
POST /reports/export/{report_id}?format=json
```

#### Delete Report
```bash
DELETE /reports/{report_id}
```

### 5. Tools (`/tools`)

#### Check Tool Status
```bash
GET /tools/status
```

#### Get Installation Instructions
```bash
GET /tools/install/nmap
```

### 6. WebSocket Terminal (`/ws/terminal`)

Real-time command execution with streaming output:

```javascript
// Connect to WebSocket
const ws = new WebSocket('ws://localhost:8000/ws/terminal');

// Send command
ws.send(JSON.stringify({
  command: 'nmap -sV 127.0.0.1'
}));

// Receive streaming output
ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  
  switch(data.type) {
    case 'start':
      console.log('Command started:', data.command);
      break;
    case 'output':
      console.log(data.data);  // Terminal output line
      break;
    case 'complete':
      console.log('Return code:', data.returncode);
      break;
    case 'error':
      console.error('Error:', data.error);
      break;
  }
};
```

---

## 🗄️ Database

AutoMium uses **SQLite** for lightweight report storage.

### Schema

```sql
CREATE TABLE reports (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL,        -- 'network_scan', 'malware_analysis', etc.
    target TEXT,               -- Target IP or file path
    results TEXT,              -- JSON-formatted results
    status TEXT DEFAULT 'completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

### Location

Database file: `backend/data/reports.db`

---

## 🔒 Security Features

### Input Validation
- ✅ IP address format validation
- ✅ Path sanitization
- ✅ Command injection prevention

### Timeout Protection
- ✅ All subprocess calls have timeouts
- ✅ Prevents resource exhaustion

### Error Handling
- ✅ Comprehensive try-catch blocks
- ✅ User-friendly error messages
- ✅ Detailed server logging

### Dangerous Commands Blocked
```python
dangerous_commands = [
    "rm -rf /",
    "mkfs",
    ":(){:|:&}",
    "chmod -R 777 /"
]
```

---

## 🧪 Testing Examples

### Test Network Scan
```bash
curl -X POST "http://localhost:8000/scan/scan" \
  -H "Content-Type: application/json" \
  -d '{
    "ip": "127.0.0.1",
    "ports": "22,80",
    "aggressive": false
  }'
```

### Test Malware Analysis
```bash
curl -X POST "http://localhost:8000/analyze/malware" \
  -H "Content-Type: application/json" \
  -d '{
    "file_path": "/tmp/test.exe",
    "analysis_type": "static"
  }'
```

### Test WebSocket Client
```bash
# Install websockets library
pip install websockets

# Run test client
python test_websocket.py
```

---

## 🛠️ Development

### Adding New Endpoints

1. **Create Service** (`app/services/my_service.py`):
```python
class MyService:
    def execute(self, params: str) -> dict:
        # Business logic here
        return {"result": "success"}
```

2. **Create Route** (`app/routes/my_feature.py`):
```python
from fastapi import APIRouter
from app.services.my_service import MyService

router = APIRouter()
service = MyService()

@router.post("/endpoint")
async def my_endpoint(request: MyRequest):
    result = service.execute(request.param)
    return {"status": "success", "data": result}
```

3. **Register Route** (`app/__main__.py`):
```python
from app.routes import my_feature

app.include_router(
    my_feature.router,
    prefix="/my-feature",
    tags=["My Feature"]
)
```

### Code Style

- ✅ Use type hints for all functions
- ✅ Include docstrings for classes and methods
- ✅ Follow PEP 8 guidelines
- ✅ Handle exceptions explicitly
- ✅ Use descriptive variable names

---

## 📊 Performance

### Concurrency
- FastAPI supports **async operations**
- WebSocket connections are handled asynchronously
- Database operations are synchronous but fast

### Scalability
- Can be deployed behind **nginx + gunicorn**
- Supports **multiple workers** in production
- Redis can be added for caching

---

## 🚀 Production Deployment

### Using Gunicorn

```bash
gunicorn app.__main__:app \
  --workers 4 \
  --worker-class uvicorn.workers.UvicornWorker \
  --bind 0.0.0.0:8000
```

### Using Docker

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ ./app/

CMD ["uvicorn", "app.__main__:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## ❓ FAQ

### Q: Why modular architecture?
**A:** Separation of concerns makes code maintainable, testable, and scalable. Monolithic files become unmanageable quickly.

### Q: Can I use this without Kali Linux?
**A:** Yes! The backend will run on any system, but some features require specific tools (nmap, yara, etc.).

### Q: Is this safe to use?
**A:** This is for **educational purposes only**. Only use on networks and systems you own or have permission to test.

### Q: How do I add authentication?
**A:** Add OAuth2/JWT middleware in `app/__main__.py`. See FastAPI documentation for security features.

---

## 📝 Changelog

### Version 2.0 (Current)
- ✅ **Modular architecture** implemented
- ✅ WebSocket support for real-time output
- ✅ PDF report generation
- ✅ Comprehensive error handling
- ✅ Production-ready code structure

### Version 1.0 (Previous)
- Initial monolithic implementation
- Basic network scanning
- Simple malware analysis

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## 📄 License

Educational purposes only. Use responsibly and legally.

---

## 👨‍💻 Maintainers

AutoMium Development Team

---

**Last Updated:** March 2026  
**Version:** 2.0  
**Status:** Production Ready ✅
