#!/bin/bash

# Test runner script for AutoMium backend
# Runs all tests with pytest

set -e  # Exit on error

echo "🧪 Running AutoMium Backend Tests"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if we're in the right directory
if [ ! -f "requirements.txt" ]; then
    echo -e "${RED}Error: Please run this script from the backend directory${NC}"
    exit 1
fi

# Activate virtual environment if not already activated
if [ -z "$VIRTUAL_ENV" ] && [ -d "venv" ]; then
    echo -e "${BLUE}📦 Activating virtual environment...${NC}"
    source venv/bin/activate
fi

# Install test dependencies if needed
echo -e "${BLUE}📦 Checking test dependencies...${NC}"
pip install -q pytest pytest-asyncio httpx

# Run tests
echo ""
echo -e "${BLUE}🚀 Running tests...${NC}"
echo ""

# Check if specific test file is requested
if [ $# -gt 0 ]; then
    echo -e "${YELLOW}Running specific test file: $1${NC}"
    pytest "$@" -v --tb=short
else
    echo -e "${YELLOW}Running all tests...${NC}"
    pytest -v --tb=short
fi

TEST_EXIT_CODE=$?

echo ""
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
else
    echo -e "${RED}❌ Some tests failed (exit code: $TEST_EXIT_CODE)${NC}"
fi

echo ""
echo "Test Summary:"
echo "-------------"
pytest --co -q 2>/dev/null | tail -n +1 | wc -l | xargs -I {} echo "{} tests collected"
echo ""

exit $TEST_EXIT_CODE
