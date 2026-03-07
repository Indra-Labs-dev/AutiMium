#!/bin/bash

# AutoMium - Complete Startup Script
# This script starts both backend and frontend

echo "🚀 Starting AutoMium..."
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "backend/main.py" ]; then
    echo -e "${RED}Error: Please run this script from the AutoMium root directory${NC}"
    exit 1
fi

# Function to check if a port is available
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        return 1  # Port is in use
    else
        return 0  # Port is free
    fi
}

# Check if backend port is available
if ! check_port 8000; then
    echo -e "${RED}Error: Port 8000 is already in use${NC}"
    exit 1
fi

echo -e "${BLUE}📦 Setting up Backend...${NC}"

# Setup backend virtual environment if needed
if [ ! -d "backend/venv" ]; then
    echo "Creating Python virtual environment..."
    cd backend
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
    deactivate
    cd ..
fi

echo -e "${BLUE}🔧 Checking Kali Linux tools...${NC}"

# Check for required tools
tools=("nmap" "yara" "hydra")
missing_tools=()

for tool in "${tools[@]}"; do
    if ! command -v $tool &> /dev/null; then
        missing_tools+=($tool)
    fi
done

if [ ${#missing_tools[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ All required tools found${NC}"
else
    echo -e "${RED}⚠ Missing tools: ${missing_tools[*]}${NC}"
    echo "Please install them with: sudo apt-get install -y ${missing_tools[*]}"
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo -e "${GREEN}✅ Backend ready!${NC}"
echo ""

# Start backend in background
echo -e "${BLUE}🔌 Starting Backend API on http://localhost:8000${NC}"
cd backend
source venv/bin/activate
python -m uvicorn main:app --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!
cd ..

# Wait for backend to start
echo "Waiting for backend to initialize..."
sleep 5

# Check if backend is running
if ! ps -p $BACKEND_PID > /dev/null; then
    echo -e "${RED}❌ Failed to start backend${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Backend started successfully!${NC}"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}⚠ Flutter is not installed. Install it from https://flutter.dev${NC}"
    echo ""
    echo "Backend is running at: http://localhost:8000"
    echo "API Documentation: http://localhost:8000/docs"
    echo ""
    echo "Press Ctrl+C to stop the backend"
    wait $BACKEND_PID
else
    echo -e "${BLUE}🎨 Starting Flutter Frontend...${NC}"
    
    cd frontend
    
    # Get dependencies
    flutter pub get
    
    # Run the app
    echo -e "${GREEN}✅ Starting AutoMium Desktop Application...${NC}"
    flutter run -d linux
    
    cd ..
fi

# Cleanup function
cleanup() {
    echo ""
    echo -e "${BLUE}🛑 Stopping AutoMium...${NC}"
    kill $BACKEND_PID 2>/dev/null
    echo -e "${GREEN}✅ AutoMium stopped${NC}"
    exit 0
}

# Trap Ctrl+C
trap cleanup SIGINT SIGTERM

# Keep script running
wait $BACKEND_PID
