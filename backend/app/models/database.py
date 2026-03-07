"""Database initialization and management"""

import sqlite3
import os
from typing import List, Dict, Optional

DB_PATH = "data/reports.db"


def init_database():
    """Initialize SQLite database with required tables"""
    os.makedirs("data", exist_ok=True)
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Reports table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS reports (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            target TEXT,
            results TEXT,
            status TEXT DEFAULT 'completed',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    # Configurations table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS configurations (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    conn.commit()
    conn.close()
    print(f"✅ Database initialized at {DB_PATH}")


def get_db_connection():
    """Get database connection"""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def save_report(report_type: str, target: str, results: str, status: str = "completed") -> str:
    """Save report to database"""
    import uuid
    report_id = str(uuid.uuid4())
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute(
        """INSERT INTO reports (id, type, target, results, status) 
           VALUES (?, ?, ?, ?, ?)""",
        (report_id, report_type, target, results, status)
    )
    conn.commit()
    conn.close()
    
    return report_id


def get_report(report_id: str) -> dict:
    """Get a specific report by ID"""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute(
        "SELECT * FROM reports WHERE id = ?",
        (report_id,)
    )
    row = cursor.fetchone()
    conn.close()
    
    if row:
        return dict(row)
    return None


def get_all_reports(limit: int = 50) -> List[dict]:
    """Get all reports with optional limit"""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute(
        "SELECT * FROM reports ORDER BY created_at DESC LIMIT ?",
        (limit,)
    )
    rows = cursor.fetchall()
    conn.close()
    
    return [dict(row) for row in rows]


def delete_report(report_id: str) -> bool:
    """Delete a specific report"""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute(
        "DELETE FROM reports WHERE id = ?",
        (report_id,)
    )
    deleted = cursor.rowcount
    conn.commit()
    conn.close()
    
    return deleted > 0
