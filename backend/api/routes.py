from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
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
from database import get_db

router = APIRouter()


@router.post("/analyze", response_model=AnalysisResponse)
async def analyze_leaf_image(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_optional_current_user)
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
    db: Session = Depends(get_db)
):
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


# --- Background Tasks and Weather Alerts ---

from fastapi import BackgroundTasks
from pydantic import BaseModel
from services.weather import get_weather_alerts

class WeatherAlertRequest(BaseModel):
    latitude: float
    longitude: float

def run_background_inference(scan_id: int, image_bytes: bytes, relative_image_path: str):
    from database import SessionLocal
    db = SessionLocal()
    try:
        record = db.query(ScanHistory).filter(ScanHistory.id == scan_id).first()
        if not record:
            return

        if not is_leaf_image(image_bytes):
            record.plant_name = "Unknown"
            record.disease_name = "No Plant Detected"
            record.scientific_name = "No Plant Detected"
            record.confidence = "0.0"
            record.image_quality = "Poor"
            record.possible_matches = "[]"
            record.issues_detected = '["Not a supported plant leaf"]'
            record.solution_suggestion = "This image is not recognized as a supported plant leaf. Please upload a clear image of a supported plant leaf."
            record.status = "completed"
            db.commit()
            return

        preprocessed_image = preprocess_image(image_bytes)
        from services.inference import run_inference
        response_data = run_inference(preprocessed_image)

        confidence_val = 1.0
        if response_data.get("confidence") is not None:
            try:
                confidence_val = float(response_data["confidence"])
            except ValueError:
                pass

        if response_data.get("status") == "Success" and confidence_val < 0.70:
            record.plant_name = "Unknown"
            record.disease_name = "No Plant Detected"
            record.scientific_name = "No Plant Detected"
            record.confidence = "0.0"
            record.image_quality = "Poor"
            record.possible_matches = "[]"
            record.issues_detected = '["Low confidence or non-leaf content"]'
            record.solution_suggestion = "The uploaded image could not be verified as a plant leaf. Please capture a clear, close-up photo of a plant leaf for accurate disease analysis."
            record.status = "completed"
            db.commit()
            return

        if response_data.get("status") == "Success":
            record.plant_name = response_data.get("plant_name")
            record.disease_name = response_data.get("disease_name")
            record.scientific_name = response_data.get("scientific_name")
            record.confidence = response_data.get("confidence")
            record.solution_suggestion = response_data.get("treatment")
            record.status = "completed"
            db.commit()
        else:
            record.status = "failed"
            db.commit()

    except Exception as e:
        db.rollback()
        print(f"Background inference error: {e}")
        try:
            record = db.query(ScanHistory).filter(ScanHistory.id == scan_id).first()
            if record:
                record.status = "failed"
                db.commit()
        except:
            pass
    finally:
        db.close()


@router.post("/scan")
async def scan_leaf_image(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...),
    background: bool = True,
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_optional_current_user)
):
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File provided is not an image.")

    try:
        image_bytes = await file.read()
        
        # Create uploads directory if missing
        uploads_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "uploads")
        if not os.path.exists(uploads_dir):
            os.makedirs(uploads_dir, exist_ok=True)

        file_ext = file.filename.split(".")[-1] if "." in file.filename else "jpg"
        unique_filename = f"{uuid.uuid4()}.{file_ext}"
        file_path = os.path.join(uploads_dir, unique_filename)

        with open(file_path, "wb") as buffer:
            buffer.write(image_bytes)

        relative_image_path = f"/uploads/{unique_filename}"

        # If user is logged in, create a database record
        user_id = current_user.id if current_user else None
        
        new_scan = ScanHistory(
            user_id=user_id,
            plant_name="Processing",
            disease_name="Processing",
            scientific_name="Processing",
            confidence="0.0",
            solution_suggestion="Analysis in progress...",
            image_path=relative_image_path,
            status="processing"
        )
        db.add(new_scan)
        db.commit()
        db.refresh(new_scan)

        if background:
            background_tasks.add_task(
                run_background_inference,
                new_scan.id,
                image_bytes,
                relative_image_path
            )
            return {
                "status": "processing",
                "scan_id": new_scan.id,
                "message": "Analysis started in the background"
            }
        else:
            # Synchronous processing
            run_background_inference(new_scan.id, image_bytes, relative_image_path)
            db.refresh(new_scan)
            return {
                "status": new_scan.status,
                "scan_id": new_scan.id,
                "plant_name": new_scan.plant_name,
                "disease_name": new_scan.disease_name,
                "scientific_name": new_scan.scientific_name,
                "confidence": new_scan.confidence,
                "treatment": new_scan.solution_suggestion,
                "image_path": new_scan.image_path
            }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Scan failed: {str(e)}")


@router.get("/scan/{scan_id}")
def get_scan_status(scan_id: int, db: Session = Depends(get_db)):
    record = db.query(ScanHistory).filter(ScanHistory.id == scan_id).first()
    if not record:
        raise HTTPException(status_code=404, detail="Scan record not found")
        
    return {
        "status": record.status,
        "scan_id": record.id,
        "plant_name": record.plant_name,
        "disease_name": record.disease_name,
        "scientific_name": record.scientific_name,
        "confidence": record.confidence,
        "treatment": record.solution_suggestion,
        "image_path": record.image_path
    }


@router.post("/weather-alert")
async def get_weather_risk_alerts(req: WeatherAlertRequest):
    try:
        alerts = await get_weather_alerts(req.latitude, req.longitude)
        return {"alerts": alerts}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to check weather alerts: {str(e)}")

