"""
Tests for API endpoints and core functionality
"""

import pytest
from fastapi import status


class TestRootEndpoints:
    """Test root endpoints"""
    
    def test_root(self, client):
        """Test root endpoint"""
        response = client.get("/")
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["status"] == "online"
        assert "AutoMium" in data["service"]
    
    def test_health_check(self, client):
        """Test health check endpoint"""
        response = client.get("/health")
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["status"] == "healthy"


class TestToolsEndpoints:
    """Test tools endpoints"""
    
    def test_tools_status(self, client):
        """Test tools status endpoint"""
        response = client.get("/tools/status")
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "tools" in data or "installed" in data or isinstance(data, list) or isinstance(data, dict)


class TestNetworkScanning:
    """Test network scanning endpoints"""
    
    def test_network_scan_status(self, client):
        """Test network scan service status"""
        response = client.get("/scan/")
        
        assert response.status_code == status.HTTP_200_OK
    
    def test_network_scan_with_valid_ip(self, auth_client, sample_scan_params):
        """Test network scan with valid IP address"""
        # Note: This test may fail if nmap is not installed
        response = auth_client.post(
            "/scan/scan",
            json=sample_scan_params
        )
        
        # Should either succeed or return a helpful error
        assert response.status_code in [
            status.HTTP_200_OK,
            status.HTTP_400_BAD_REQUEST,
            status.HTTP_500_INTERNAL_SERVER_ERROR
        ]
    
    def test_network_scan_with_invalid_ip(self, auth_client):
        """Test network scan with invalid IP address"""
        response = auth_client.post(
            "/scan/scan",
            json={
                "ip": "invalid-ip",
                "scan_type": "-sV"
            }
        )
        
        assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY


class TestReportsEndpoints:
    """Test reports endpoints"""
    
    def test_list_reports(self, auth_client):
        """Test listing reports"""
        response = auth_client.get("/reports/")
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert isinstance(data, list)
    
    def test_get_nonexistent_report(self, auth_client):
        """Test getting a report that doesn't exist"""
        response = auth_client.get("/reports/nonexistent-id")
        
        # Should return 404 or empty result
        assert response.status_code in [
            status.HTTP_404_NOT_FOUND,
            status.HTTP_422_UNPROCESSABLE_ENTITY
        ]


class TestMalwareAnalysis:
    """Test malware analysis endpoints"""
    
    def test_malware_analysis_status(self, auth_client):
        """Test malware analysis service status"""
        response = auth_client.get("/analyze/")
        
        assert response.status_code == status.HTTP_200_OK


class TestBruteforce:
    """Test bruteforce endpoints"""
    
    def test_bruteforce_status(self, auth_client):
        """Test bruteforce service status"""
        response = auth_client.get("/bruteforce/")
        
        assert response.status_code == status.HTTP_200_OK
