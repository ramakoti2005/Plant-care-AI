import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

DATABASE_URL = os.getenv("DATABASE_URL")

if DATABASE_URL:
    DATABASE_URL = DATABASE_URL.replace(
        "postgres://",
        "postgresql://",
        1
    )
    # Safely append sslmode=require to remote PostgreSQL/Supabase connections if not specified
    if "sqlite" not in DATABASE_URL and "sslmode" not in DATABASE_URL:
        separator = "&" if "?" in DATABASE_URL else "?"
        DATABASE_URL = f"{DATABASE_URL}{separator}sslmode=require"
else:
    DATABASE_URL = "sqlite:///./plant_disease.db"

# Configure database engine with optimization for Supabase / PostgreSQL connection pool limits
if "sqlite" in DATABASE_URL:
    engine = create_engine(
        DATABASE_URL,
        connect_args={"check_same_thread": False}
    )
else:
    engine = create_engine(
        DATABASE_URL,
        pool_size=5,
        max_overflow=10,
        pool_timeout=30,
        pool_recycle=1800,
        pool_pre_ping=True
    )

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

Base = declarative_base()

from sqlalchemy import inspect, text
def init_db_schema():
    inspector = inspect(engine)
    if "users" in inspector.get_table_names():
        columns = [c["name"] for c in inspector.get_columns("users")]
        with engine.connect() as conn:
            # Check and add columns if missing
            modified = False
            if "full_name" not in columns:
                conn.execute(text("ALTER TABLE users ADD COLUMN full_name VARCHAR"))
                modified = True
            if "phone" not in columns:
                conn.execute(text("ALTER TABLE users ADD COLUMN phone VARCHAR"))
                modified = True
            if "location" not in columns:
                conn.execute(text("ALTER TABLE users ADD COLUMN location VARCHAR"))
                modified = True
            if "two_factor_enabled" not in columns:
                conn.execute(text("ALTER TABLE users ADD COLUMN two_factor_enabled BOOLEAN DEFAULT false"))
                modified = True
            if modified:
                conn.commit()

try:
    init_db_schema()
except Exception as e:
    print(f"Database schema update warning: {e}")


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
