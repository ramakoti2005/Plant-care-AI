from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from typing import List
import json

from schemas import AnalysisResponse, ScanHistorySchema
from services.preprocessing import preprocess_image
from services.inference import process_prediction_and_save
from services.leaf_validator import is_leaf_image
from services.auth import get_current_user
from models import User, ScanHistory
from database import get_db

router = APIRouter()


@router.post("/analyze", response_model=AnalysisResponse)
async def analyze_leaf_image(
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """
    Endpoint to upload a leaf image and get a disease analysis report.
    """

    # 1. Validate file type
    if not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=400,
            detail="File provided is not an image."
        )

    try:
        # Read uploaded image
        image_bytes = await file.read()

        # 2. VALIDATION STEP: Check if it's actually a plant leaf
        if not is_leaf_image(image_bytes):
            return {
                "status": "Unrecognized Image",
                "message": "This image is not recognized as a supported plant leaf. Please upload a clear image of a supported plant leaf."
            }

        # 3. Preprocess image for ONNX
        preprocessed_image = preprocess_image(image_bytes)

        # 4. Run inference and save history
        response_data = process_prediction_and_save(
            preprocessed_image, 
            db, 
            user_id=None
        )

        return response_data

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"An error occurred during analysis: {str(e)}"
        )


@router.get("/plants/history", response_model=List[ScanHistorySchema])
def get_user_scan_history(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Retrieve scan history for logged-in user.
    """

    try:
        history_records = (
            db.query(ScanHistory)
            .filter(ScanHistory.user_id == current_user.id)
            .order_by(ScanHistory.timestamp.desc())
            .all()
        )

        results = []

        for s in history_records:
            results.append({
                "id": s.id,
                "plant_name": s.plant_name,
                "scientific_name": s.scientific_name or s.disease_name or "N/A",
                "confidence": s.confidence or "N/A",
                "possible_matches": [],
                "image_quality": s.image_quality or "Good",
                "issues_detected": [],
                "solution_suggestion": s.solution_suggestion or "No treatment recorded",
                "timestamp": s.timestamp
            })

        return results

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to fetch scan history: {str(e)}"
        )
