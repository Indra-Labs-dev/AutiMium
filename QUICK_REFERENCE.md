# 🚀 AutoMium - Quick Reference Guide

## 🔑 Essential Commands

### Installation & Startup
```bash
# Fresh installation
./install.sh

# Start everything (backend + frontend)
./start.sh

# Backend only
cd backend && ./start.sh

# Frontend only
cd frontend && flutter run -d linux
```

### Testing
```bash
# Run all backend tests
cd backend && ./run_tests.sh

# Test specific module
pytest tests/test_auth.py -v

# Check Flutter code
cd frontend && flutter analyze
```

---

## 📡 API Endpoints Cheat Sheet

### Authentication
```bash
# Login
curl -X POST "http://localhost:8000/auth/login" \
  -d "username=admin&password=AutoMium2024!"

# Get current user
curl -X GET "http://localhost:8000/auth/me" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Refresh token
curl -X POST "http://localhost:8000/auth/refresh" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Network Scanning
```bash
# Nmap scan
curl -X POST "http://localhost:8000/scan/scan" \
  -H "Content-Type: application/json" \
  -d '{"ip":"192.168.1.1","ports":"22,80,443"}'

# Vulnerability scan
curl -X POST "http://localhost:8000/scan/vulnerabilities" \
  -H "Content-Type: application/json" \
  -d '{"ip":"192.168.1.1","ports":"80"}'
```

### Kali Linux Tools
```bash
# Reconnaissance
curl -X POST "http://localhost:8000/kali/recon" \
  -H "Content-Type: application/json" \
  -d '{"target":"example.com","tool":"whois"}'

# Network enumeration
curl -X POST "http://localhost:8000/kali/scan/enumeration" \
  -H "Content-Type: application/json" \
  -d '{"target":"192.168.1.1","scan_type":"nmap"}'

# Generate payload
curl -X POST "http://localhost:8000/kali/malware/generate" \
  -H "Content-Type: application/json" \
  -d '{
    "payload":"windows/meterpreter/reverse_tcp",
    "lhost":"192.168.1.100",
    "lport":4444,
    "format":"exe"
  }'

# SQL injection test
curl -X POST "http://localhost:8000/kali/web/sqli" \
  -H "Content-Type: application/json" \
  -d '{
    "url":"http://testphp.vulnweb.com/listproducts.php?cat=1",
    "level":3,"risk":2
  }'
```

### Reports & Exports
```bash
# List all reports
curl http://localhost:8000/reports/

# Export single report (CSV)
curl -X POST "http://localhost:8000/reports/export/REPORT_ID?format=csv" \
  -o report.csv

# Export single report (HTML)
curl -X POST "http://localhost:8000/reports/export/REPORT_ID?format=html" \
  -o report.html

# Export all reports (CSV)
curl -X POST "http://localhost:8000/reports/export-all?format=csv" \
  -o all_reports.csv

# Export all reports (HTML)
curl -X POST "http://localhost:8000/reports/export-all?format=html" \
  -o all_reports.html
```

---

## 🔐 Security Configuration

### Change Default Password
```bash
# Edit .env file
nano backend/.env

# Update these values:
DEFAULT_ADMIN_PASSWORD=YourNewStrongPassword123!
JWT_SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
```

### Environment Variables
```env
# backend/.env
JWT_SECRET_KEY=your-secret-key-here
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
DEFAULT_ADMIN_USERNAME=admin
DEFAULT_ADMIN_PASSWORD=ChangeMeNow123!
```

---

## 🛠️ Automation Scripts

### Network Reconnaissance
```bash
python scripts/automation.py network 192.168.1.1
```

### Malware Analysis
```bash
python scripts/automation.py malware /tmp/suspicious.exe
```

### Custom Workflow
```bash
python scripts/automation.py custom scripts/configs/full_network_assessment.json
```

---

## 📊 Dashboard Access

The dashboard is accessible from the main Flutter UI:
- Launch frontend: `flutter run -d linux`
- Click "Dashboard" in navigation
- View real-time statistics and charts

---

## 🐛 Troubleshooting

### Backend won't start
```bash
# Check port availability
lsof -i :8000

# Kill process if needed
kill -9 $(lsof -t -i:8000)

# Restart backend
cd backend && ./start.sh
```

### Flutter compilation errors
```bash
# Clean and rebuild
cd frontend
flutter clean
flutter pub get
flutter run -d linux
```

### Missing Kali tools
```bash
# Install missing tools
sudo apt install -y nmap yara hydra nikto metasploit-framework
sudo apt install -y sqlmap aircrack-ng wireshark john hashcat
```

### Database issues
```bash
# Reset database (WARNING: deletes all reports)
rm backend/data/reports.db
cd backend && python -m app.__main__
```

---

## 📚 Documentation Links

- **Main README:** `/README.md`
- **API Docs:** http://localhost:8000/docs
- **Kali Integration:** `/KALI_INTEGRATION_COMPLETE.md`
- **Improvements Summary:** `/IMPROVEMENTS_SUMMARY.md`
- **Quick Start:** `/QUICKSTART_GUIDE.md`

---

## ⚡ Power User Tips

### 1. Use Swagger UI for Testing
Open http://localhost:8000/docs to interactively test all endpoints

### 2. WebSocket Terminal
Use WebSocket endpoint for real-time command output:
```
ws://localhost:8000/ws/terminal
```

### 3. Batch Operations
Chain multiple commands in automation scripts for complex workflows

### 4. Export Formats
- **JSON:** Machine-readable, for further processing
- **CSV:** Spreadsheet-compatible, for analysis
- **HTML:** Beautiful reports for sharing

### 5. Token Management
Save your JWT token after login:
```bash
TOKEN=$(curl -X POST "http://localhost:8000/auth/login" \
  -d "username=admin&password=YourPassword" | jq -r '.access_token')

# Use in subsequent requests
curl -H "Authorization: Bearer $TOKEN" http://localhost:8000/reports/
```

---

<div align="center">

### 🛡️ AutoMium v2.5 - Quick Reference

*Complete • Powerful • Professional*

</div>
