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
else:
    DATABASE_URL = "sqlite:///./plant_disease.db"

engine = create_engine(DATABASE_URL)

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
