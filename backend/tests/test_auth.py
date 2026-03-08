"""
Tests for authentication endpoints
"""

import pytest
from fastapi import status


class TestAuthentication:
    """Test authentication endpoints"""
    
    def test_login_success(self, client):
        """Test successful login with default credentials"""
        response = client.post(
            "/auth/login",
            data={
                "username": "admin",
                "password": "AutoMium2024!"
            }
        )
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "access_token" in data
        assert data["token_type"] == "bearer"
        assert "expires_in" in data
        assert len(data["access_token"]) > 0
    
    def test_login_failure_wrong_password(self, client):
        """Test login failure with wrong password"""
        response = client.post(
            "/auth/login",
            data={
                "username": "admin",
                "password": "wrongpassword"
            }
        )
        
        assert response.status_code == status.HTTP_401_UNAUTHORIZED
    
    def test_login_failure_wrong_username(self, client):
        """Test login failure with wrong username"""
        response = client.post(
            "/auth/login",
            data={
                "username": "wronguser",
                "password": "AutoMium2024!"
            }
        )
        
        assert response.status_code == status.HTTP_401_UNAUTHORIZED
    
    def test_get_current_user_info(self, auth_client):
        """Test getting current user information"""
        response = auth_client.get("/auth/me")
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert data["username"] == "admin"
    
    def test_get_current_user_info_without_auth(self, client):
        """Test getting current user info without authentication"""
        response = client.get("/auth/me")
        
        assert response.status_code == status.HTTP_401_UNAUTHORIZED
    
    def test_refresh_token(self, auth_client):
        """Test token refresh"""
        response = auth_client.post("/auth/refresh")
        
        assert response.status_code == status.HTTP_200_OK
        data = response.json()
        assert "access_token" in data
        assert len(data["access_token"]) > 0
