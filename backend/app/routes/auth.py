"""
Authentication endpoints for AutoMium API
Handles login, token refresh, and user management
"""

from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from datetime import timedelta
from typing import Optional

from app.utils.auth import (
    authenticate_user,
    create_access_token,
    get_current_user_from_token,
    ACCESS_TOKEN_EXPIRE_MINUTES,
    Token,
    User
)

router = APIRouter()

# OAuth2 scheme for token authentication
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")


async def get_current_user(token: str = Depends(oauth2_scheme)) -> User:
    """
    Dependency to get current user from JWT token
    Raises HTTPException if token is invalid
    """
    user = get_current_user_from_token(token)
    
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    return user


@router.post("/login", response_model=Token, tags=["Authentication"])
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    """
    Login endpoint - returns JWT access token
    
    **Usage:**
    ```
    curl -X POST "http://localhost:8000/auth/login" \\
         -H "Content-Type: application/x-www-form-urlencoded" \\
         -d "username=admin&password=AutoMium2024!"
    ```
    
    **Response:**
    ```json
    {
        "access_token": "eyJhbGciOiJIUzI1NiIs...",
        "token_type": "bearer",
        "expires_in": 86400
    }
    ```
    """
    user = authenticate_user(form_data.username, form_data.password)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Create access token
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username},
        expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "expires_in": int(access_token_expires.total_seconds())
    }


@router.get("/me", response_model=User, tags=["Authentication"])
async def get_current_user_info(current_user: User = Depends(get_current_user)):
    """
    Get current user information
    
    Requires valid JWT token in Authorization header:
    ```
    Authorization: Bearer <your-token>
    ```
    """
    return current_user


@router.post("/refresh", response_model=Token, tags=["Authentication"])
async def refresh_token(current_user: User = Depends(get_current_user)):
    """
    Refresh JWT access token
    
    Returns a new token with extended expiration time
    """
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": current_user.username},
        expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "expires_in": int(access_token_expires.total_seconds())
    }
