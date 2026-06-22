from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from api.routes import router as api_router
from api.auth_routes import router as auth_router
from api.simulator_routes import router as simulator_router
from database import engine, Base
import models
import os
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create the database tables
try:
    Base.metadata.create_all(bind=engine)
    logger.info("Database tables created successfully.")

    # Self-healing database migration for missing columns
    from sqlalchemy import inspect, text
    inspector = inspect(engine)
    if "scan_histories" in inspector.get_table_names():
        columns = [col["name"] for col in inspector.get_columns("scan_histories")]
        if "disease_name" not in columns:
            logger.info("Migrating Database: Adding 'disease_name' column to 'scan_histories' table.")
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE scan_histories ADD COLUMN disease_name VARCHAR(255)"))
            logger.info("Migrating Database: Successfully added 'disease_name' column.")
        if "image_path" not in columns:
            logger.info("Migrating Database: Adding 'image_path' column to 'scan_histories' table.")
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE scan_histories ADD COLUMN image_path VARCHAR(255)"))
            logger.info("Migrating Database: Successfully added 'image_path' column.")
except Exception as e:
    logger.error(f"Error creating database tables or migrating: {e}")

app = FastAPI(
    title="Plant Disease API",
    description="A cloud-based API platform for plant disease diagnosis.",
    version="1.1.0"
)

# Configure CORS - Very permissive for development to avoid "Failed to fetch"
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Health Check
@app.get("/api/v1/health")
def health_check():
    return {"status": "ok", "message": "AgriVision AI Backend is running"}

# Include the API routers
app.include_router(auth_router, prefix="/api/v1/auth", tags=["auth"])
app.include_router(api_router, prefix="/api/v1", tags=["analysis"])
app.include_router(simulator_router, prefix="/api/v1", tags=["simulator"])

# Serve dataset images
dataset_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "appdataset", "dataset")
if os.path.exists(dataset_dir):
    app.mount("/dataset", StaticFiles(directory=dataset_dir), name="dataset")
    logger.info(f"Serving dataset images from {dataset_dir}")

# Serve uploaded images
uploads_dir = os.path.join(os.path.dirname(__file__), "uploads")
if not os.path.exists(uploads_dir):
    os.makedirs(uploads_dir, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=uploads_dir), name="uploads")
logger.info(f"Serving uploaded images from {uploads_dir}")

# Serve frontend static files
# Make sure this is AFTER router inclusions
# Check for 'web' first (common for Flutter Web builds), then fallback to 'frontend'
web_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "web")
frontend_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "frontend")

if os.path.exists(web_dir):
    app.mount("/", StaticFiles(directory=web_dir, html=True), name="web")
    logger.info(f"Serving frontend from {web_dir}")
elif os.path.exists(frontend_dir):
    app.mount("/", StaticFiles(directory=frontend_dir, html=True), name="frontend")
    logger.info(f"Serving frontend from {frontend_dir}")
else:
    logger.warning("No frontend directory ('web' or 'frontend') found to serve.")
