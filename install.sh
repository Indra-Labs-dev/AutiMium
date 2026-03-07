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

# Check if running on Kali Linux
if [ ! -f "/etc/kali-version" ] && [ "$(id -fn $(logname))" != "Kali" ]; then
    echo -e "${YELLOW}⚠ Warning: This script is designed for Kali Linux${NC}"
    echo "Your distribution may not be fully supported"
    read -p "Continue? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Update system
echo -e "${BLUE}📦 Updating system packages...${NC}"
sudo apt-get update

# Install Python dependencies
echo -e "${BLUE}🐍 Installing Python dependencies...${NC}"
sudo apt-get install -y python3 python3-pip python3-venv python3-dev

# Install Kali Linux security tools
echo -e "${BLUE}🔧 Installing Kali Linux security tools...${NC}"
sudo apt-get install -y nmap yara hydra nikto peframe clamav firejail

# Install additional utilities
sudo apt-get install -y git curl wget net-tools

# Install Flutter (if not already installed)
if ! command -v flutter &> /dev/null; then
    echo -e "${BLUE}🎨 Installing Flutter...${NC}"
    
    # Download Flutter SDK
    cd /tmp
    wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.5-stable.tar.xz
    tar xf flutter_linux_3.16.5-stable.tar.xz
    sudo mv flutter /opt/
    sudo ln -s /opt/flutter/bin/flutter /usr/local/bin/flutter
    
    # Add to PATH
    echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.bashrc
    source ~/.bashrc
    
    echo -e "${GREEN}✓ Flutter installed successfully${NC}"
else
    echo -e "${GREEN}✓ Flutter already installed${NC}"
fi

# Enable Linux desktop support
echo -e "${BLUE}🖥️ Enabling Linux desktop support...${NC}"
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev

# Verify installations
echo ""
echo -e "${BLUE}📋 Verifying installations...${NC}"
echo ""

tools=("python3" "pip3" "nmap" "yara" "hydra" "flutter")
for tool in "${tools[@]}"; do
    if command -v $tool &> /dev/null; then
        version=$($tool --version 2>&1 | head -n 1)
        echo -e "${GREEN}✓ $tool${NC}: $version"
    else
        echo -e "${RED}✗ $tool${NC}: NOT FOUND"
    fi
done

echo ""
echo -e "${GREEN}✅ Installation completed successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. Navigate to the project directory: cd AutiMium"
echo "2. Run the application: ./start.sh"
echo ""
echo "Or manually:"
echo "  Backend: cd backend && ./start.sh"
echo "  Frontend: cd frontend && flutter run -d linux"
echo ""
