# AutoMium Backend - Architecture Documentation

## 📁 Project Structure

```
backend/
├── app/                      # Main application package
│   ├── __init__.py          # Package initialization
│   ├── __main__.py          # Application entry point (FastAPI app)
│   │
│   ├── routes/              # API endpoints (controllers)
│   │   ├── __init__.py
│   │   ├── network.py       # Network scanning endpoints
│   │   ├── malware.py       # Malware analysis endpoints
│   │   ├── bruteforce.py    # Bruteforce attack endpoints
│   │   ├── reports.py       # Report management endpoints
│   │   └── tools.py         # Tools status endpoints
│   │
│   ├── services/            # Business logic layer
│   │   ├── __init__.py
│   │   ├── network_service.py    # Nmap orchestration
│   │   └── malware_service.py    # Malware analysis orchestration
│   │
│   ├── models/              # Data models and database
│   │   ├── __init__.py
│   │   ├── schemas.py       # Pydantic models for validation
│   │   └── database.py      # SQLite database operations
│   │
│   ├── websocket/           # WebSocket handlers
│   │   ├── __init__.py
│   │   └── terminal.py      # Real-time terminal output
│   │
│   └── utils/               # Utility functions
│       ├── __init__.py
│       └── helpers.py       # Helper functions (validation, sanitization)
│
├── data/                    # Database and reports (auto-generated)
├── venv/                    # Python virtual environment (auto-generated)
├── requirements.txt         # Python dependencies
└── start.sh                # Startup script
```

## 🏗️ Architecture Layers

### 1. **Routes Layer** (`app/routes/`)
- Handles HTTP requests and responses
- Validates input using Pydantic schemas
- Calls appropriate service methods
- Returns structured JSON responses

**Example:**
```python
@router.post("/scan")
async def network_scan(request: ScanRequest):
    result = scanner.scan(**request.dict())
    return {"status": "success", "data": result}
```

### 2. **Services Layer** (`app/services/`)
- Contains business logic
- Orchestrates external tools (nmap, yara, hydra, etc.)
- Handles errors and timeouts
- Returns structured results

**Example:**
```python
class NetworkScanner:
    def scan(self, ip: str, ports: str = None) -> Dict:
        cmd = ["nmap", "-sV", ip]
        if ports:
            cmd.extend(["-p", ports])
        result = subprocess.run(cmd, capture_output=True, text=True)
        return self._parse_results(result)
```

### 3. **Models Layer** (`app/models/`)
- **Schemas**: Pydantic models for request/response validation
- **Database**: SQLite operations for report storage

**Example Schema:**
```python
class ScanRequest(BaseModel):
    ip: str = Field(..., description="Target IP")
    scan_type: str = "-sV"
    ports: Optional[str] = None
```

### 4. **WebSocket Layer** (`app/websocket/`)
- Manages real-time connections
- Streams terminal output to frontend
- Handles command execution

### 5. **Utils Layer** (`app/utils/`)
- Input validation
- Security sanitization
- Data formatting helpers

## 🔄 Request Flow

```
Client Request
    ↓
Route Handler (app/routes/)
    ↓
Service Layer (app/services/)
    ↓
External Tool (nmap, yara, hydra...)
    ↓
Service parses results
    ↓
Route returns response
    ↓
Client receives JSON
```

## 📡 API Endpoints

### Network Scanning (`/scan`)
- `POST /scan/scan` - Comprehensive nmap scan
- `POST /scan/vulnerabilities` - Vulnerability scan
- `GET /scan/` - Service status

### Malware Analysis (`/analyze`)
- `POST /analyze/malware` - Analyze suspicious file
- `GET /analyze/` - Service status

### Bruteforce (`/bruteforce`)
- `POST /bruteforce/` - Hydra brute-force attack

### Reports (`/reports`)
- `GET /reports/` - List all reports
- `GET /reports/{id}` - Get specific report
- `DELETE /reports/{id}` - Delete report
- `POST /reports/export/{id}?format=pdf|json` - Export report

### Tools (`/tools`)
- `GET /tools/status` - Check installed tools
- `GET /tools/install/{name}` - Get installation instructions

## 🔒 Security Features

1. **Input Validation**
   - IP address format validation
   - Path sanitization
   - Command injection prevention

2. **Timeout Protection**
   - All subprocess calls have timeouts
   - Prevents resource exhaustion

3. **Error Handling**
   - Comprehensive try-catch blocks
   - User-friendly error messages
   - Detailed logging

## 📊 Database Schema

### Reports Table
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

## 🚀 Running the Backend

### Development Mode
```bash
cd backend
source venv/bin/activate
uvicorn app.__main__:app --reload --host 0.0.0.0 --port 8000
```

### Production Mode
```bash
cd backend
./start.sh
```

### Access API Documentation
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## 🧪 Testing

```bash
# Test a specific endpoint
curl http://localhost:8000/tools/status

# Test network scan
curl -X POST "http://localhost:8000/scan/scan" \
  -H "Content-Type: application/json" \
  -d '{"ip": "127.0.0.1", "scan_type": "-sV"}'
```

## 🛠️ Adding New Features

### 1. Create Service
```python
# app/services/new_service.py
class NewService:
    def execute(self, params: str) -> Dict:
        # Business logic here
        pass
```

### 2. Create Route
```python
# app/routes/new_feature.py
@router.post("/endpoint")
async def new_endpoint(request: NewRequest):
    service = NewService()
    result = service.execute(request.param)
    return {"status": "success", "data": result}
```

### 3. Register Route
```python
# app/__main__.py
from app.routes import new_feature
app.include_router(new_feature.router, prefix="/new", tags=["New Feature"])
```

## 📝 Code Style

- Use type hints for all functions
- Include docstrings for classes and public methods
- Follow PEP 8 guidelines
- Use descriptive variable names
- Handle exceptions explicitly

## 🔧 Dependencies

Main dependencies (see `requirements.txt`):
- **fastapi** - Web framework
- **uvicorn** - ASGI server
- **pydantic** - Data validation
- **sqlite3** - Database (built-in)

---

**Version:** 1.0  
**Last Updated:** 2026  
**Architecture:** Modular Microservices-inspired
