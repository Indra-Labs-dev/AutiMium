# 🚀 AutoMium - Quick Start Guide

## 📋 Prerequisites

Before you begin, ensure you have:
- **Kali Linux** (recommended) or any Linux distribution
- **Python 3.8+** installed
- **Internet connection** for initial setup
- **Sudo privileges** for installation

## ⚡ Installation Steps

### Step 1: Install Dependencies

Open a terminal and navigate to the AutiMium directory:

```bash
cd /path/to/AutiMium
```

Run the installation script:

```bash
chmod +x install.sh
./install.sh
```

This will automatically install:
- ✅ Python and pip
- ✅ Kali Linux tools (nmap, yara, hydra, nikto, peframe, clamav, firejail)
- ✅ Flutter SDK (if not already installed)
- ✅ Required system libraries

**⏱ Estimated time:** 5-10 minutes depending on your internet speed

### Step 2: Verify Installation

After installation completes, verify everything is working:

```bash
# Check Python
python3 --version

# Check Flutter
flutter --version

# Check Kali tools
which nmap
which yara
which hydra
```

## 🎯 Running AutoMium

### Option 1: All-in-One Startup (Recommended)

From the project root directory:

```bash
./start.sh
```

This script will:
1. ✅ Set up the Python virtual environment
2. ✅ Install backend dependencies
3. ✅ Check for required Kali tools
4. ✅ Start the FastAPI backend on port 8000
5. ✅ Launch the Flutter desktop application

**Expected output:**
```
🚀 Starting AutoMium...

📦 Setting up Backend...
✓ All required tools found
✅ Backend ready!

🔌 Starting Backend API on http://localhost:8000
✅ Backend started successfully!

🎨 Starting Flutter Frontend...
✅ Starting AutoMium Desktop Application...
```

### Option 2: Manual Startup

If you prefer to start components separately:

#### Start Backend:
```bash
cd backend

# Create virtual environment (first time only)
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start the server
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

The backend API will be available at: **http://localhost:8000**

Interactive API docs (Swagger UI): **http://localhost:8000/docs**

#### Start Frontend (new terminal):
```bash
cd frontend

# Get Flutter dependencies
flutter pub get

# Run the application
flutter run -d linux
```

## 🔍 Testing Your Installation

### 1. Test Backend API

Open your browser or use curl:

```bash
# Check API status
curl http://localhost:8000/

# Check available tools
curl http://localhost:8000/status
```

You should see JSON responses indicating the API is running.

### 2. Test Network Scan

From the Flutter interface:
1. Navigate to "Network Scan" tab
2. Enter target IP: `127.0.0.1`
3. Select scan type: "Version Detection"
4. Click "Start Scan"
5. Wait for results (should complete in < 60 seconds)

### 3. Test Malware Analysis

Create a test file:

```bash
# Create EICAR test file (harmless antivirus test pattern)
echo "X5O!P%@AP[4\PZX54(P^)7CC)7}\$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!\$H+H*" > /tmp/test_eicar.com
```

In AutoMium:
1. Navigate to "Malware Analysis" tab
2. Browse and select `/tmp/test_eicar.com`
3. Select "Static Analysis"
4. Click "Start Analysis"
5. YARA should detect the test pattern

## 🛠️ Troubleshooting

### Issue: "Port 8000 is already in use"

**Solution:** Find and kill the process using port 8000:

```bash
# Find process
lsof -i :8000

# Kill it (replace PID with actual number)
kill -9 <PID>
```

### Issue: "Flutter not found"

**Solution:** Install Flutter manually:

```bash
# Download Flutter
cd /tmp
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.5-stable.tar.xz

# Extract
tar xf flutter_linux_3.16.5-stable.tar.xz

# Move to /opt
sudo mv flutter /opt/

# Add to PATH
echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Verify
flutter --version
```

### Issue: "Missing Kali tools"

**Solution:** Install missing tools individually:

```bash
# Example for nmap
sudo apt-get install -y nmap

# Install all at once
sudo apt-get install -y nmap yara hydra nikto peframe clamav firejail
```

### Issue: "Flutter Linux desktop build fails"

**Solution:** Install required libraries:

```bash
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
```

### Issue: "Backend won't start"

**Check logs:**
```bash
cd backend
source venv/bin/activate
python -m uvicorn main:app --host 0.0.0.0 --port 8000
```

Look for error messages in the terminal output.

### Issue: "Connection refused" from Flutter

**Solutions:**
1. Ensure backend is running (`curl http://localhost:8000/`)
2. Check firewall isn't blocking localhost
3. Restart both backend and frontend

## 📊 What's Installed?

### Backend Dependencies (Python)
- **FastAPI** - Modern web framework for APIs
- **Uvicorn** - ASGI server
- **Pydantic** - Data validation

### Frontend Dependencies (Flutter)
- **provider** - State management
- **http** - HTTP client
- **hive** - Local database
- **google_fonts** - Typography
- **file_picker** - File selection dialogs
- **pdf/printing** - Report generation

### Kali Linux Tools Integration
- **nmap** - Network scanning
- **yara** - Malware pattern matching
- **hydra** - Brute-force testing
- **nikto** - Web vulnerability scanner
- **peframe** - PE file analysis
- **clamav** - Antivirus engine
- **firejail** - Sandboxing

## 🎓 Learning Resources

### Understanding the Code

**Backend Structure:**
```
backend/main.py
├── API Routes (/scan, /analyze, /bruteforce)
├── Database Functions (SQLite)
├── Tool Wrappers (subprocess calls)
└── Input Validation
```

**Frontend Structure:**
```
frontend/lib/
├── main.dart              # App entry point
├── providers/             # State management
│   ├── api_provider.dart  # Backend communication
│   └── report_provider.dart # Local storage
└── screens/               # UI components
    ├── home_screen.dart
    ├── network_scan_screen.dart
    ├── malware_analysis_screen.dart
    ├── bruteforce_screen.dart
    └── reports_screen.dart
```

### API Documentation

Access interactive API documentation at: **http://localhost:8000/docs**

This Swagger UI shows:
- All available endpoints
- Request/response formats
- Try-it-out functionality

## 🔐 Security Best Practices

1. **Authorization**: Only test systems you own or have permission to test
2. **Isolation**: Use Firejail/Docker for malware analysis
3. **Minimal Privileges**: Don't run as root unless necessary
4. **Data Privacy**: All data stays local (no cloud transmission)
5. **Validation**: All inputs are sanitized before command execution

## 📈 Next Steps

1. **Explore the Interface**: Try each module (Network Scan, Malware Analysis, Bruteforce)
2. **Read the Docs**: Check `docs/Cahier_des_Charges.md` for detailed specifications
3. **Customize**: Modify scan parameters, add custom wordlists
4. **Extend**: Add new tools following the existing patterns
5. **Report Issues**: Note any bugs or feature requests

## 💡 Tips & Tricks

### Faster Scans
```python
# Use -T4 for faster scans (but more noise)
# Use --top-ports 100 to scan only top 100 ports
```

### Custom Wordlists
```bash
# Create your own wordlists
mkdir -p ~/wordlists
echo -e "admin\nroot\ntest" > ~/wordlists/usernames.txt
```

### Export Reports
All reports are automatically saved to SQLite database and can be:
- Viewed in the Reports tab
- Filtered by type
- Deleted when no longer needed
- Exported via API calls

### Keyboard Shortcuts (Flutter Desktop)
- **F5**: Refresh connection status
- **Ctrl+R**: Reload current screen
- **Esc**: Close dialogs

## 🆘 Getting Help

If you encounter issues:

1. **Check this guide** thoroughly
2. **Review error messages** carefully
3. **Check backend logs** in the terminal
4. **Verify tool installations** with `which <tool>`
5. **Test API directly** with curl or browser

## 📝 Summary

✅ **Installation**: `./install.sh` (5-10 min)
✅ **Startup**: `./start.sh` 
✅ **Test**: Try network scan on 127.0.0.1
✅ **Explore**: Check all modules
✅ **Learn**: Read API docs at localhost:8000/docs

---

**Happy (ethical) hacking! 🚀**

*Remember: With great power comes great responsibility.*
