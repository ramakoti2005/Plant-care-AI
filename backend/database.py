import os
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, declarative_base

# Load environment variables from .env file locally
try:
    from dotenv import load_dotenv
    load_dotenv(os.path.join(os.path.dirname(__file__), ".env"))
except ImportError:
    # Safe manual parsing fallback if python-dotenv is not installed yet
    env_path = os.path.join(os.path.dirname(__file__), ".env")
    if os.path.exists(env_path):
        with open(env_path, "r") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    k, v = line.split("=", 1)
                    val = v.strip().strip("'").strip('"')
                    os.environ[k.strip()] = val

DATABASE_URL = os.getenv("DATABASE_URL")

# Resolve the SQLite database path dynamically relative to the root directory
# (one level up from this file 'backend/database.py')
sqlite_db_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "plant_disease.db")
sqlite_url = f"sqlite:///{sqlite_db_path}"

fallback_to_sqlite = False

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
    DATABASE_URL = sqlite_url

# Configure database engine
if "sqlite" in DATABASE_URL:
    engine = create_engine(
        DATABASE_URL,
        connect_args={"check_same_thread": False}
    )
else:
    # Attempt to test connection to remote database with a fast timeout (5 seconds)
    print(f"Testing database connection to remote database...")
    try:
        temp_engine = create_engine(
            DATABASE_URL,
            connect_args={"connect_timeout": 5}
        )
        with temp_engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        temp_engine.dispose()
        print("Successfully connected to the remote database.")
        
        # Use remote engine
        engine = create_engine(
            DATABASE_URL,
            pool_size=5,
            max_overflow=10,
            pool_timeout=30,
            pool_recycle=1800,
            pool_pre_ping=True
        )
    except Exception as e:
        print(f"Database connection error: {e}")
        print("Falling back to local SQLite database.")
        fallback_to_sqlite = True
        DATABASE_URL = sqlite_url
        engine = create_engine(
            sqlite_url,
            connect_args={"check_same_thread": False}
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
