"""
Pytest configuration and fixtures for AutoMium tests
"""

import pytest
from fastapi.testclient import TestClient
from app.__main__ import app


@pytest.fixture
def client():
    """Create a test client for the FastAPI app"""
    with TestClient(app) as test_client:
        yield test_client


@pytest.fixture
def auth_client(client):
    """Create an authenticated test client"""
    # Login and get token
    response = client.post(
        "/auth/login",
        data={
            "username": "admin",
            "password": "AutoMium2024!"
        }
    )
    
    if response.status_code == 200:
        token = response.json()["access_token"]
        client.headers["Authorization"] = f"Bearer {token}"
    
    yield client


@pytest.fixture
def sample_ip():
    """Sample IP address for testing"""
    return "127.0.0.1"


@pytest.fixture
def sample_scan_params():
    """Sample scan parameters"""
    return {
        "ip": "127.0.0.1",
        "scan_type": "-sV",
        "ports": "22,80",
        "aggressive": False,
        "os_detection": False,
        "script_scan": False,
        "traceroute": False
    }
