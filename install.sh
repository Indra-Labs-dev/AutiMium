#!/bin/bash

# Installation script for AutoMium
# Run this script to install all dependencies

set -e  # Exit on error

echo "🚀 AutoMium Installation Script"
echo "================================"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if running as root (don't do that!)
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}Error: Do not run this script as root${NC}"
    echo "The script will use sudo when needed"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check distribution
echo -e "${BLUE}📋 Checking system requirements...${NC}"
if [ -f "/etc/os-release" ]; then
    source /etc/os-release
    echo "Distribution: $NAME $VERSION_ID"
    
    # Check if it's a Debian-based system
    if [[ ! "$ID_LIKE" =~ "debian" ]] && [[ ! "$ID" =~ "debian" ]] && [[ ! "$ID" =~ "kali" ]]; then
        echo -e "${YELLOW}⚠ Warning: This script is optimized for Debian/Kali Linux${NC}"
        echo "Your distribution: $NAME"
        read -p "Continue? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
else
    echo -e "${YELLOW}⚠ Cannot detect distribution${NC}"
fi

# Update system
echo -e "${BLUE}📦 Updating system packages...${NC}"
sudo apt-get update || {
    echo -e "${RED}Failed to update packages${NC}"
    exit 1
}

# Install Python dependencies
echo -e "${BLUE}🐍 Installing Python dependencies...${NC}"
sudo apt-get install -y python3 python3-pip python3-venv python3-dev build-essential

# Create backend virtual environment
echo -e "${BLUE}📦 Setting up Python virtual environment...${NC}"
if [ -d "backend/venv" ]; then
    echo "Removing old virtual environment..."
    rm -rf backend/venv
fi

cd backend
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip

# Install Python packages
echo -e "${BLUE}📦 Installing Python dependencies...${NC}"
pip install -r requirements.txt

# Add JWT authentication support
echo -e "${BLUE}🔐 Adding JWT authentication support...${NC}"
pip install PyJWT==2.8.0 python-jose[cryptography]==3.3.0 passlib[bcrypt]==1.7.4

cd ..

# Install Kali Linux security tools
echo -e "${BLUE}🔧 Installing Kali Linux security tools...${NC}"
sudo apt-get install -y nmap yara hydra nikto peframe clamav firejail metasploit-framework

# Install additional utilities
sudo apt-get install -y git curl wget net-tools lsof

# Install Flutter dependencies
echo -e "${BLUE}🖥️ Installing Flutter Linux desktop dependencies...${NC}"
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev xz-utils

# Install Flutter (if not already installed)
if ! command_exists flutter; then
    echo -e "${BLUE}🎨 Installing Flutter SDK...${NC}"
    
    # Check architecture
    ARCH=$(uname -m)
    if [ "$ARCH" != "x86_64" ]; then
        echo -e "${RED}Error: Flutter requires x86_64 architecture, detected: $ARCH${NC}"
        exit 1
    fi
    
    # Download Flutter SDK
    cd /tmp
    echo "Downloading Flutter SDK (this may take a while)..."
    wget -q --show-progress https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz
    
    echo "Extracting Flutter SDK..."
    tar xf flutter_linux_3.24.0-stable.tar.xz
    
    # Move to /opt
    echo "Installing Flutter to /opt/flutter..."
    sudo rm -rf /opt/flutter
    sudo mv flutter /opt/
    
    # Add to PATH in .bashrc and .zshrc
    if ! grep -q "flutter/bin" ~/.bashrc 2>/dev/null; then
        echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.bashrc
    fi
    
    if [ -f ~/.zshrc ] && ! grep -q "flutter/bin" ~/.zshrc 2>/dev/null; then
        echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.zshrc
    fi
    
    # Source bashrc
    export PATH="$PATH:/opt/flutter/bin"
    
    # Enable desktop support
    flutter config --enable-linux-desktop
    
    # Accept licenses
    flutter doctor --android-licenses || true
    
    echo -e "${GREEN}✓ Flutter installed successfully${NC}"
    rm -f /tmp/flutter_linux_*-stable.tar.xz
else
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    echo -e "${GREEN}✓ Flutter already installed: $FLUTTER_VERSION${NC}"
    
    # Enable Linux desktop
    flutter config --enable-linux-desktop 2>/dev/null || true
fi

# Enable Linux desktop support
echo -e "${BLUE}🖥️ Enabling Linux desktop support...${NC}"
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev

# Verify installations
echo ""
echo -e "${BLUE}📋 Verifying installations...${NC}"
echo ""

tools=("python3" "pip3" "nmap" "yara" "hydra" "flutter")
all_ok=true

for tool in "${tools[@]}"; do
    if command_exists $tool; then
        version=$($tool --version 2>&1 | head -n 1)
        echo -e "${GREEN}✓ $tool${NC}: $version"
    else
        echo -e "${RED}✗ $tool${NC}: NOT FOUND"
        all_ok=false
    fi
done

echo ""

# Check Python packages
echo -e "${BLUE}📦 Checking Python packages...${NC}"
cd backend
source venv/bin/activate
python_packages=("fastapi" "uvicorn" "pydantic")
for pkg in "${python_packages[@]}"; do
    if pip show "$pkg" > /dev/null 2>&1; then
        version=$(pip show "$pkg" | grep Version | cut -d' ' -f2)
        echo -e "${GREEN}✓ $pkg${NC}: $version"
    else
        echo -e "${RED}✗ $pkg${NC}: NOT INSTALLED"
        all_ok=false
    fi
done
cd ..

echo ""

if [ "$all_ok" = true ]; then
    echo -e "${GREEN}✅ All dependencies installed successfully!${NC}"
else
    echo -e "${YELLOW}⚠ Some dependencies are missing. You can continue but some features won't work.${NC}"
fi

echo ""
echo -e "${GREEN}✅ Installation completed successfully!${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Next steps:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1️⃣  Start the application:"
echo "   ./start.sh"
echo ""
echo "2️⃣  Or start components separately:"
echo "   Backend:  cd backend && ./start.sh"
echo "   Frontend: cd frontend && flutter run -d linux"
echo ""
echo "3️⃣  Access API documentation:"
echo "   http://localhost:8000/docs"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create default user credentials file
echo -e "${BLUE}🔐 Creating default authentication configuration...${NC}"
if [ ! -f "backend/.env" ]; then
    cat > backend/.env << 'EOF'
# AutoMium Configuration
# Change these values!
JWT_SECRET_KEY=your-secret-key-change-this-in-production
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440

# Default admin credentials (CHANGE THESE!)
DEFAULT_ADMIN_USERNAME=admin
DEFAULT_ADMIN_PASSWORD=AutoMium2024!
EOF
    echo -e "${YELLOW}⚠ IMPORTANT: Edit backend/.env and change the default password!${NC}"
else
    echo -e "${GREEN}✓ Configuration file already exists${NC}"
fi

echo ""
