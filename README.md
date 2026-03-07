# AutoMium - Personal Pentesting & Malware Analysis Tool

![AutoMium](https://img.shields.io/badge/version-1.0.0-blue)
![Platform](https://img.shields.io/badge/platform-Kali%20Linux-orange)
![Stack](https://img.shields.io/badge/stack-Flutter%20%2B%20FastAPI-green)

## 📋 Overview

**AutoMium** is a personal cybersecurity tool designed to centralize, automate, and secure pentesting and malware analysis workflows on Kali Linux. It provides a unified desktop interface for popular security tools while ensuring complete data privacy with 100% local operation.

## ✨ Features

### 🔍 Network Security
- **Port Scanning**: Detect open ports and services using `nmap`
- **Vulnerability Detection**: Identify CVE vulnerabilities with `nmap` and `nikto`
- **Brute-force Testing**: Test credentials on SSH, FTP, HTTP using `hydra`
- **Exploitation**: Exploit identified vulnerabilities via `metasploit`

### 🦠 Malware Analysis
- **Static Analysis**: Extract strings, headers, and patterns using `yara`, `peframe`, `strings`
- **Dynamic Analysis**: Execute files in isolated sandbox with `docker`/`firejail`
- **Pattern Detection**: Compare against YARA rules and known signatures
- **IOC Reporting**: Save hashes, IOCs, and analysis results

### 🤖 Automation
- **Custom Scripts**: Chain commands together (scan + exploitation)
- **Integrated Terminal**: Real-time command output display
- **Report Management**: History, search, and filtering
- **Backup/Restore**: Export and import data and configurations

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│    Flutter Desktop Application          │
│         (Frontend - Dart)               │
└───────────────────┬─────────────────────┘
                    │ REST API / WebSockets
┌───────────────────▼─────────────────────┐
│      FastAPI Backend (Python)           │
│     Orchestration & Business Logic      │
└───────────────────┬─────────────────────┘
                    │ subprocess
┌───────────────────▼─────────────────────┐
│   Kali Linux Tools                      │
│   nmap · yara · metasploit · hydra ...  │
└───────────────────┬─────────────────────┘
                    │
┌───────────────────▼─────────────────────┐
│   Local Storage                         │
│   SQLite · JSON Files                   │
└─────────────────────────────────────────┘
```

## 🚀 Installation

### Prerequisites
- Kali Linux (recommended) or any Linux distribution
- Python 3.8+
- Flutter 3.0+ (for Desktop)

### Quick Start

1. **Clone the repository**
```bash
git clone https://github.com/Indra-Labs-dev/AutiMium.git
cd AutiMium
```

2. **Run the installation script**
```bash
chmod +x install.sh
./install.sh
```

This will install:
- Python dependencies
- Kali Linux security tools (nmap, yara, hydra, etc.)
- Flutter SDK (if not already installed)
- Required system libraries

### Manual Installation

If you prefer manual setup:

#### Backend Setup
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

#### Frontend Setup
```bash
cd frontend
flutter pub get
```

## 🎯 Usage

### Starting AutoMium

**Option 1: All-in-one startup**
```bash
./start.sh
```

**Option 2: Separate components**

Start backend:
```bash
cd backend
./start.sh
```

Start frontend (in another terminal):
```bash
cd frontend
flutter run -d linux
```

### Accessing the API

The backend exposes a REST API at: `http://localhost:8000`

Interactive API documentation (Swagger UI): `http://localhost:8000/docs`

### Available Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | API status |
| `/status` | GET | Check backend and tools status |
| `/scan` | GET | Launch nmap network scan |
| `/analyze/malware` | POST | Analyze suspicious file |
| `/bruteforce` | POST | Launch Hydra brute-force attack |
| `/reports` | GET | Get all reports |
| `/report/{id}` | GET | Get specific report |
| `/report/{id}` | DELETE | Delete a report |

## 📁 Project Structure

```
AutoMium/
├── backend/
│   ├── main.py              # FastAPI application
│   ├── requirements.txt     # Python dependencies
│   └── start.sh            # Backend startup script
├── frontend/
│   ├── lib/
│   │   ├── main.dart       # Flutter entry point
│   │   ├── providers/      # State management
│   │   └── screens/        # UI screens
│   ├── pubspec.yaml        # Flutter dependencies
│   └── assets/             # Images and icons
├── scripts/                # Automation scripts
├── docs/                   # Documentation
├── install.sh             # Installation script
└── start.sh              # Main startup script
```

## 🔒 Security Considerations

### ⚠️ Important Warnings

1. **Authorization**: Only use this tool on systems you own or have explicit authorization to test
2. **Privileges**: The application runs with minimal privileges; `sudo` is used only when necessary
3. **Isolation**: Malware analysis should be performed in isolated environments (Docker/Firejail)
4. **Data Privacy**: All data is stored locally - no cloud transmission

### Input Validation
- All user inputs are validated before command execution
- IP addresses and file paths are sanitized
- Whitelists are used for tool parameters

## 🛠️ Development

### Adding New Tools

To integrate a new Kali Linux tool:

1. Add the wrapper in `backend/main.py`
2. Create the corresponding API endpoint
3. Add the UI component in `frontend/lib/screens/`
4. Update the providers

### Example: Adding a New Scanner

**Backend:**
```python
@app.get("/new-scanner")
def new_scanner(target: str):
    result = subprocess.run(
        ["tool-name", "-options", target],
        capture_output=True,
        text=True
    )
    return {"result": result.stdout}
```

**Frontend:**
```dart
// Add new screen in lib/screens/new_scanner_screen.dart
// Import and add to home_screen.dart navigation
```

## 📊 Testing

### Functional Tests
- Network scan returns results in < 60s
- EICAR file correctly detected by YARA
- Hydra returns brute-force results
- PDF reports are generated and saved locally
- Real-time terminal output works correctly

### Non-Functional Tests
- No network transmission (verify with Wireshark)
- Interface responsive at 1920×1080
- Backend starts in < 5 seconds
- SQLite reports persist after restart

## 🐛 Troubleshooting

### Common Issues

**Backend won't start:**
```bash
# Check if port 8000 is available
lsof -i :8000

# Check Python version
python3 --version

# Verify virtual environment
cd backend
source venv/bin/activate
```

**Flutter issues:**
```bash
# Check Flutter installation
flutter doctor

# Clean and rebuild
flutter clean
flutter pub get
flutter run -d linux
```

**Missing tools:**
```bash
# Install missing Kali tools
sudo apt-get install -y nmap yara hydra nikto peframe
```

## 📖 Documentation

See `docs/Cahier_des_Charges.md` for detailed specifications and requirements.

## 🤝 Contributing

This is a personal project for educational purposes. However, suggestions and improvements are welcome!

## 📄 License

Personal use only. Not for commercial distribution.

## ⚠️ Disclaimer

**This tool is designed for educational and authorized testing purposes only.** 

- Always obtain proper authorization before testing
- The authors are not responsible for misuse or damages
- Use responsibly and ethically
- Comply with all applicable laws and regulations

## 📞 Support

For questions or issues, please refer to the documentation or check the code comments.

---

**Built with ❤️ for Kali Linux**

*AutoMium v1.0 - 2025*
