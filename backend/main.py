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
except Exception as e:
    logger.error(f"Error creating database tables: {e}")

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

# Serve frontend static files
# Make sure this is AFTER router inclusions
frontend_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "frontend")
if os.path.exists(frontend_dir):
    app.mount("/", StaticFiles(directory=frontend_dir, html=True), name="frontend")
else:
    logger.warning(f"Frontend directory not found at {frontend_dir}")
