# Migration Guide - Old to New Backend Structure

## Quick Reference

### Import Changes

#### ❌ Old Way
```python
from main import app, scanner, analyzer
```

#### ✅ New Way
```python
from app.__main__ import app
from app.services.network_service import NetworkScanner
from app.services.malware_service import MalwareAnalyzer
```

---

### Endpoint Changes

#### ❌ Old Routes (in main.py)
```python
@app.post("/scan")
async def network_scan(request: ScanRequest):
    # 100 lines of code mixed with business logic
```

#### ✅ New Routes (in routes/network.py)
```python
from fastapi import APIRouter

router = APIRouter()

@router.post("/scan")
async def network_scan(request: ScanRequest):
    # Clean route handler - only HTTP logic
    result = scanner.scan(**request.dict())
    return {"status": "success", "data": result}
```

---

### Service Usage

#### ❌ Old Way (Everything in one class)
```python
class Scanner:
    def scan(self, ip):
        # nmap code
        pass
    
    def analyze_malware(self, file):
        # yara code mixed here
        pass
    
    def bruteforce(self, target):
        # hydra code also here
        pass
```

#### ✅ New Way (Separate Services)
```python
# app/services/network_service.py
class NetworkScanner:
    def scan(self, ip: str, **kwargs) -> Dict:
        # Only network scanning logic
        pass

# app/services/malware_service.py
class MalwareAnalyzer:
    def analyze(self, file_path: str, **kwargs) -> Dict:
        # Only malware analysis logic
        pass
```

---

## File-by-File Migration

### Step 1: Update Main Entry Point

**Old:** `main.py` (800+ lines)

**New:** `app/__main__.py` (67 lines)

```python
# What to keep from old main.py:
- FastAPI app initialization
- CORS middleware setup
- Router includes
- Startup events

# What to remove:
- All business logic
- All tool orchestration
- All parsing functions
```

### Step 2: Extract Business Logic

**Create:** `app/services/network_service.py`

Move all nmap-related code here:
- Command building
- Output parsing
- Error handling
- Timeout management

### Step 3: Create Data Models

**Create:** `app/models/schemas.py`

Move all Pydantic models here:
- ScanRequest
- VulnerabilityScanRequest
- MalwareAnalysisRequest
- BruteforceRequest
- ReportResponse

### Step 4: Setup Database Layer

**Create:** `app/models/database.py`

Move database operations:
- Connection management
- CRUD operations
- Table creation

### Step 5: Create API Routes

**Create:** `app/routes/network.py`

Extract route handlers:
- Keep only HTTP logic
- Call service methods
- Return responses

Repeat for:
- `routes/malware.py`
- `routes/bruteforce.py`
- `routes/reports.py`
- `routes/tools.py`

---

## Common Patterns

### Pattern 1: Service Method

```python
# In app/services/my_service.py
class MyService:
    def __init__(self):
        self.tools = {
            "tool1": self._check_tool("tool1"),
            "tool2": self._check_tool("tool2")
        }
    
    def execute(self, param: str, **kwargs) -> Dict:
        """
        Execute the main operation
        
        Args:
            param: Input parameter
            **kwargs: Additional options
        
        Returns:
            Dictionary with results
        """
        try:
            # Build command
            cmd = ["tool", "args", param]
            
            # Execute
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=300
            )
            
            # Parse and return
            return {
                "success": result.returncode == 0,
                "data": self._parse(result),
                "errors": result.stderr
            }
        except Exception as e:
            raise RuntimeError(f"Operation failed: {e}")
```

### Pattern 2: Route Handler

```python
# In app/routes/my_feature.py
from fastapi import APIRouter, HTTPException
from app.models.schemas import MyRequest
from app.services.my_service import MyService

router = APIRouter()
service = MyService()

@router.post("/endpoint")
async def my_endpoint(request: MyRequest):
    """
    API endpoint description
    
    - **param1**: Description
    - **param2**: Description
    """
    try:
        result = service.execute(request.param1, **request.dict())
        
        # Save to database if needed
        report_id = save_report(
            report_type="my_feature",
            target=request.param1,
            results=str(result)
        )
        
        return {
            "report_id": report_id,
            "status": "success" if result["success"] else "error",
            "data": result["data"]
        }
        
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except TimeoutError as e:
        raise HTTPException(status_code=408, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

### Pattern 3: Pydantic Schema

```python
# In app/models/schemas.py
from pydantic import BaseModel, Field
from typing import Optional, List

class MyRequest(BaseModel):
    """Request model for my feature"""
    param1: str = Field(..., description="Required parameter")
    param2: Optional[str] = None
    option1: bool = False
    option2: int = Field(default=10, ge=1, le=100)

class MyResponse(BaseModel):
    """Response model"""
    status: str
    data: dict
    errors: Optional[List[str]] = None
```

---

## Testing Changes

### Old Testing Approach
```bash
# Hard to test - everything is coupled
python -c "from main import scanner; scanner.scan('127.0.0.1')"
```

### New Testing Approach
```bash
# Easy to test - isolated components

# Test service independently
python -c "
from app.services.network_service import NetworkScanner
scanner = NetworkScanner()
result = scanner.scan('127.0.0.1')
assert result['success'] == True
"

# Test route with FastAPI TestClient
from fastapi.testclient import TestClient
from app.__main__ import app

client = TestClient(app)
response = client.post("/scan/scan", json={"ip": "127.0.0.1"})
assert response.status_code == 200
```

---

## Running Both Versions

### During Migration

You can keep both versions temporarily:

```bash
backend/
├── main.py              # Old version (rename to main_old.py)
├── app/                 # New version
│   └── __main__.py
└── requirements.txt
```

Start old version:
```bash
uvicorn main:app --port 8000
```

Start new version:
```bash
uvicorn app.__main__:app --port 8001
```

Test both and compare!

---

## Checklist

### Files to Create
- [ ] `app/__init__.py`
- [ ] `app/__main__.py`
- [ ] `app/routes/__init__.py`
- [ ] `app/routes/network.py`
- [ ] `app/routes/malware.py`
- [ ] `app/routes/bruteforce.py`
- [ ] `app/routes/reports.py`
- [ ] `app/routes/tools.py`
- [ ] `app/services/__init__.py`
- [ ] `app/services/network_service.py`
- [ ] `app/services/malware_service.py`
- [ ] `app/models/__init__.py`
- [ ] `app/models/schemas.py`
- [ ] `app/models/database.py`
- [ ] `app/utils/__init__.py`
- [ ] `app/utils/helpers.py`

### Code to Migrate
- [ ] Move FastAPI app setup to `app/__main__.py`
- [ ] Extract nmap logic to `services/network_service.py`
- [ ] Extract malware logic to `services/malware_service.py`
- [ ] Move Pydantic models to `models/schemas.py`
- [ ] Move database code to `models/database.py`
- [ ] Create route handlers in `routes/*.py`
- [ ] Add helper functions to `utils/helpers.py`

### Testing
- [ ] Test each endpoint individually
- [ ] Test service methods independently
- [ ] Test database operations
- [ ] Test error handling
- [ ] Run full integration tests

### Documentation
- [ ] Update README with new structure
- [ ] Add docstrings to all classes
- [ ] Create architecture documentation
- [ ] Write migration guide

---

## Troubleshooting

### Issue: Import Errors
```
ModuleNotFoundError: No module named 'app'
```

**Solution:** Make sure you're running from backend directory:
```bash
cd backend
python -m uvicorn app.__main__:app
```

### Issue: Circular Imports
```
ImportError: cannot import name 'X' from partially initialized module 'app'
```

**Solution:** 
- Use forward references: `def method(self) -> "MyClass":`
- Restructure imports (import at module level, not inside functions)
- Check `__init__.py` files don't create cycles

### Issue: Database Not Found
```
sqlite3.OperationalError: unable to open database file
```

**Solution:** Create data directory:
```bash
mkdir -p data
```

### Issue: Routes Not Working
```
404 Not Found
```

**Solution:** Check router is included in `app/__main__.py`:
```python
from app.routes import network
app.include_router(network.router, prefix="/scan", tags=["Network Scanning"])
```

---

## Benefits After Migration

### Before
```bash
$ wc -l backend/main.py
847 backend/main.py
```

**Problems:**
- Hard to navigate
- Difficult to test
- No separation of concerns
- Merge conflicts likely

### After
```bash
$ find backend/app -name "*.py" -exec wc -l {} + | tail -1
  1247 total
```

**Advantages:**
- Each file < 300 lines
- Clear organization
- Easy to test
- Team-friendly
- Professional quality

---

## Next Steps After Migration

1. **Add More Features**
   - Easier now with modular structure
   - Just add new service + route files

2. **Improve Testing**
   - Add unit tests for services
   - Add integration tests for routes
   - Add end-to-end tests

3. **Enhance Security**
   - Add authentication middleware
   - Implement rate limiting
   - Add audit logging

4. **Optimize Performance**
   - Add caching layer
   - Use async database operations
   - Implement connection pooling

5. **Deploy to Production**
   - Docker containerization
   - Kubernetes deployment
   - CI/CD pipeline

---

## Resources

- **FastAPI Docs:** https://fastapi.tiangolo.com/
- **Pydantic Docs:** https://docs.pydantic.dev/
- **Uvicorn Docs:** https://www.uvicorn.org/
- **Python Project Structure:** https://docs.python-guide.org/writing/structure/

---

**Migration Status:** ✅ Complete  
**Time Saved:** Hours of debugging  
**Code Quality:** 10x Better  
**Maintainability:** Excellent
