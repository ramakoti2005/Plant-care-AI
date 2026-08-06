from fastapi import APIRouter, UploadFile, File, HTTPException, Depends, Header
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from typing import List, Optional
import json
import os
import uuid

from schemas import AnalysisResponse, ScanHistorySchema
from services.preprocessing import preprocess_image
from services.inference import process_prediction_and_save, TREATMENT_BY_NAME, create_base64_thumbnail
from services.leaf_validator import is_leaf_image
from services.auth import get_current_user, get_optional_current_user
from models import User, ScanHistory
from database import get_db, fallback_to_sqlite

router = APIRouter()


@router.post("/analyze", response_model=AnalysisResponse)
async def analyze_leaf_image(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_optional_current_user),
    authorization: Optional[str] = Header(None)
):
    """
    Endpoint to upload a leaf image and get a disease analysis report.
    """

    # If fallback is active and we have an authenticated user, forward the scan to Render
    # so that it gets analyzed and recorded in Supabase.
    if fallback_to_sqlite and current_user and authorization:
        try:
            import requests
            # Read file bytes to forward
            file_bytes = await file.read()
            # Reset file pointer for local fallback if needed
            await file.seek(0)
            
            render_res = requests.post(
                "https://plant-care-ai-1-beem.onrender.com/api/v1/analyze",
                headers={"Authorization": authorization},
                files={"file": (file.filename, file_bytes, file.content_type)},
                timeout=30
            )
            if render_res.status_code == 200:
                print("Successfully proxied analyze scan to Render server.")
                return render_res.json()
        except Exception as e:
            print(f"Failed to proxy analyze scan to Render: {e}")
            # Reset file pointer if we need to fall back to local inference
            await file.seek(0)

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
            base64_uri = create_base64_thumbnail(image_bytes)
            
            # Save to database history if user is logged in
            if current_user:
                try:
                    new_history = ScanHistory(
                        user_id=current_user.id,
                        plant_name="Unknown",
                        disease_name="No Plant Detected",
                        scientific_name="No Plant Detected",
                        confidence="0.0",
                        image_quality="Poor",
                        possible_matches="[]",
                        issues_detected='["Not a supported plant leaf"]',
                        solution_suggestion="This image is not recognized as a supported plant leaf. Please upload a clear image of a supported plant leaf.",
                        image_path=base64_uri
                    )
                    db.add(new_history)
                    db.commit()
                except Exception as db_err:
                    db.rollback()
                    print(f"Failed to save unrecognized image to database: {db_err}")
            
            return {
                "status": "Unrecognized Image",
                "message": "This image is not recognized as a supported plant leaf. Please upload a clear image of a supported plant leaf.",
                "image_path": base64_uri,
                "plant_name": "Unknown",
                "disease_name": "No Plant Detected",
                "plant": "Unknown",
                "disease": "No Plant Detected",
                "scientific_name": "No Plant Detected"
            }

        # Create uploads directory if it doesn't exist
        uploads_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "uploads")
        if not os.path.exists(uploads_dir):
            os.makedirs(uploads_dir, exist_ok=True)

        # Generate a unique name for the file
        file_ext = file.filename.split(".")[-1] if "." in file.filename else "jpg"
        unique_filename = f"{uuid.uuid4()}.{file_ext}"
        file_path = os.path.join(uploads_dir, unique_filename)

        # Save the file
        with open(file_path, "wb") as buffer:
            buffer.write(image_bytes)

        relative_image_path = f"/uploads/{unique_filename}"

        # 3. Preprocess image for ONNX
        preprocessed_image = preprocess_image(image_bytes)

        # 4. Run inference and save history
        response_data = process_prediction_and_save(
            preprocessed_image, 
            db, 
            user_id=current_user.id if current_user else None,
            image_path=relative_image_path,
            raw_image_bytes=image_bytes
        )

        response_data["image_path"] = response_data.get("image_path") or relative_image_path
        return response_data

    except Exception as e:
        print(f"Backend Exception Logged: {str(e)}")
        return {
            "status": "Unrecognized Image",
            "message": f"An unexpected error occurred while parsing the photo: {str(e)}",
            "is_plant": False,
            "confidence": "0.0",
            "crop": "Not Recognized",
            "plant_name": "Unknown",
            "disease_name": "No Plant Detected",
            "scientific_name": "N/A",
            "condition": "Error Processing Image",
            "overview": "An unexpected error occurred while parsing the photo metadata. Please re-take a clear photo of a leaf.",
            "symptoms": "N/A",
            "treatment": "N/A"
        }


@router.get("/plants/history", response_model=List[ScanHistorySchema])
@router.get("/history", response_model=List[ScanHistorySchema])
def get_user_scan_history(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    authorization: Optional[str] = Header(None)
):
    """
    Retrieve scan history for logged-in user.
    """
    if fallback_to_sqlite and authorization:
        try:
            import requests
            render_res = requests.get(
                "https://plant-care-ai-1-beem.onrender.com/api/v1/history",
                headers={"Authorization": authorization},
                timeout=15
            )
            if render_res.status_code == 200:
                return render_res.json()
        except Exception as e:
            print(f"Failed to proxy get_history to Render: {e}")

    try:
        history_records = (
            db.query(ScanHistory)
            .filter(ScanHistory.user_id == current_user.id)
            .order_by(ScanHistory.timestamp.desc())
            .all()
        )

        results = []

        for s in history_records:
            p_name = s.plant_name or ""
            d_name = s.disease_name or ""
            detail = TREATMENT_BY_NAME.get((p_name.lower(), d_name.lower()), {})

            results.append({
                "id": s.id,
                "plant_name": s.plant_name,
                "disease_name": s.disease_name,
                "scientific_name": s.scientific_name or s.disease_name or "N/A",
                "confidence": s.confidence or "N/A",
                "possible_matches": [],
                "image_quality": s.image_quality or "Good",
                "issues_detected": [],
                "solution_suggestion": s.solution_suggestion or "No treatment recorded",
                "timestamp": s.timestamp,
                "image_path": s.image_path,
                "cause": detail.get("cause"),
                "symptoms": detail.get("symptoms"),
                "organic_remedy": detail.get("organic_remedy"),
                "chemical_control": detail.get("chemical_control")
            })

        return results

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to fetch scan history: {str(e)}"
        )


@router.delete("/plants/history/{scan_id}")
@router.delete("/history/{scan_id}")
def delete_scan_history(
    scan_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    authorization: Optional[str] = Header(None)
):
    if fallback_to_sqlite and authorization:
        try:
            import requests
            render_res = requests.delete(
                f"https://plant-care-ai-1-beem.onrender.com/api/v1/history/{scan_id}",
                headers={"Authorization": authorization},
                timeout=15
            )
            if render_res.status_code == 200:
                # Also delete locally if it exists, to keep local DB clean
                try:
                    record = db.query(ScanHistory).filter(ScanHistory.id == scan_id).first()
                    if record:
                        db.delete(record)
                        db.commit()
                except Exception:
                    db.rollback()
                return render_res.json()
        except Exception as e:
            print(f"Failed to proxy delete_history to Render: {e}")

    try:
        record = (
            db.query(ScanHistory)
            .filter(ScanHistory.id == scan_id, ScanHistory.user_id == current_user.id)
            .first()
        )
        if not record:
            raise HTTPException(status_code=404, detail="Scan history record not found")
        
        db.delete(record)
        db.commit()
        return {"status": "success", "message": "Scan history deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Failed to delete scan history: {str(e)}"
        )
