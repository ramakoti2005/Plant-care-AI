from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from typing import List
import json

from schemas import AnalysisResponse, ScanHistorySchema
from services.preprocessing import preprocess_image
from services.inference import run_inference
from services.auth import get_current_user
from models import User, ScanHistory
from database import get_db

router = APIRouter()


@router.post("/analyze", response_model=AnalysisResponse)
async def analyze_leaf_image(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
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

        # 2. Preprocess image
        preprocessed_image = preprocess_image(image_bytes)

        # 3. Run inference
        response_data = run_inference(preprocessed_image)

        # Force the confidence number to format as a string percentage text
        if "confidence" in response_data and isinstance(response_data["confidence"], (int, float)):
            response_data["confidence"] = f"{response_data['confidence']:.2f}%"

        # 4. Save scan history
        try:
            db_scan = ScanHistory(
                user_id=current_user.id,
                plant_name=response_data.get("plant_name"),
                scientific_name=response_data.get("scientific_name"),
                confidence=response_data.get("confidence"),
                image_quality=response_data.get("image_quality"),
                possible_matches=json.dumps(
                    response_data.get("possible_matches", [])
                ),
                issues_detected=json.dumps(
                    response_data.get("issues_detected", [])
                ),
                solution_suggestion=response_data.get(
                    "solution_suggestion"
                )
            )

            db.add(db_scan)
            db.commit()

        except Exception as db_err:
            print(f"Error saving scan history: {db_err}")

        # 5. Return response
        return response_data

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"An error occurred during analysis: {str(e)}"
        )


@router.get("/history", response_model=List[ScanHistorySchema])
def get_scan_history(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Retrieve scan history for logged-in user.
    """

    try:
        scans = (
            db.query(ScanHistory)
            .filter(ScanHistory.user_id == current_user.id)
            .order_by(ScanHistory.id.desc())
            .all()
        )

        results = []

        for s in scans:

            try:
                possible = (
                    json.loads(s.possible_matches)
                    if s.possible_matches
                    else []
                )
            except Exception:
                possible = []

            try:
                issues = (
                    json.loads(s.issues_detected)
                    if s.issues_detected
                    else []
                )
            except Exception:
                issues = []

            results.append({
                "id": s.id,
                "plant_name": s.plant_name,
                "scientific_name": s.scientific_name,
                "confidence": s.confidence,
                "possible_matches": possible,
                "image_quality": s.image_quality,
                "issues_detected": issues,
                "solution_suggestion": s.solution_suggestion,
                "timestamp": s.timestamp
            })

        return results

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to fetch scan history: {str(e)}"
        )
