"""
Authentication module for AutoMium API
Handles JWT token creation, validation, and user management
"""

from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from pydantic import BaseModel
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# JWT settings
SECRET_KEY = os.getenv("JWT_SECRET_KEY", "your-secret-key-change-this-in-production")
ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "1440"))

# Default admin credentials (should be changed via .env)
DEFAULT_ADMIN_USERNAME = os.getenv("DEFAULT_ADMIN_USERNAME", "admin")
DEFAULT_ADMIN_PASSWORD = os.getenv("DEFAULT_ADMIN_PASSWORD", "AutoMium2024!")


class Token(BaseModel):
    """JWT Token response model"""
    access_token: str
    token_type: str = "bearer"
    expires_in: int


class TokenData(BaseModel):
    """JWT Token data model"""
    username: Optional[str] = None
    exp: Optional[datetime] = None


class User(BaseModel):
    """User model"""
    username: str
    disabled: Optional[bool] = None


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a plain password against a hashed password"""
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """Hash a password"""
    return pwd_context.hash(password)


def authenticate_user(username: str, password: str) -> Optional[User]:
    """
    Authenticate a user with username and password
    Returns User if successful, None otherwise
    """
    # Check against default admin credentials
    if username == DEFAULT_ADMIN_USERNAME and verify_password(password, DEFAULT_ADMIN_PASSWORD):
        return User(username=username, disabled=False)
    
    # In future, this could check a database
    return None


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """Create a JWT access token"""
    to_encode = data.copy()
    
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    
    return encoded_jwt


def decode_access_token(token: str) -> Optional[TokenData]:
    """
    Decode a JWT access token
    Returns TokenData if valid, None otherwise
    """
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        exp: datetime = datetime.fromtimestamp(payload.get("exp", 0))
        
        if username is None:
            return None
        
        return TokenData(username=username, exp=exp)
    
    except JWTError:
        return None


def get_current_user_from_token(token: str) -> Optional[User]:
    """Get current user from JWT token"""
    token_data = decode_access_token(token)
    
    if token_data is None:
        return None
    
    # For now, just return the user if token is valid
    # In future, could check against database
    return User(username=token_data.username, disabled=False)
