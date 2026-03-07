"""
AutoMium Backend - Modular Architecture

This is the new modular backend structure with separate concerns:
- routes/: API endpoints
- services/: Business logic
- models/: Data models and database
- websocket/: Real-time communication
- utils/: Helper functions

For detailed documentation, see ARCHITECTURE.md
"""

# This file is kept for backward compatibility
# Please use app/__main__.py as the main entry point

import sys
import os

# Add app directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'app'))

from app.__main__ import app

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
