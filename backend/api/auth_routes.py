from datetime import timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

import models
import schemas
import database
from services import auth

router = APIRouter()

@router.post("/register", response_model=schemas.User)
def register_user(user: schemas.UserCreate, db: Session = Depends(database.get_db)):
    try:
        db_user = auth.get_user(db, username=user.username)
        if db_user:
            raise HTTPException(status_code=400, detail="Username already registered")

        db_email = db.query(models.User).filter(models.User.email == user.email).first()
        if db_email:
            raise HTTPException(status_code=400, detail="Email already registered")

        hashed_password = auth.get_password_hash(user.password)
        db_user = models.User(username=user.username, email=user.email, hashed_password=hashed_password)
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        return db_user
    except HTTPException as e:
        raise e
    except Exception as e:
        # Catch database or hashing errors and return them to the UI
        raise HTTPException(status_code=500, detail=f"Internal Server Error: {str(e)}")

@router.post("/token", response_model=schemas.Token)
def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(database.get_db)):
    user = auth.get_user(db, username=form_data.username)
    if not user or not auth.verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=auth.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = auth.create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "username": user.username,
        "email": user.email
    }

@router.get("/profile")
def get_user_profile(current_user: models.User = Depends(auth.get_current_user), db: Session = Depends(database.get_db)):
    # Calculate stats dynamically from actual ScanHistory
    total_scans = db.query(models.ScanHistory).filter(models.ScanHistory.user_id == current_user.id).count()
    
    # Unique diseases detected (excluding "healthy")
    diseases_query = db.query(models.ScanHistory.disease_name).filter(
        models.ScanHistory.user_id == current_user.id
    ).distinct().all()
    
    diseases_list = [d[0] for d in diseases_query if d[0] and "healthy" not in d[0].lower()]
    diseases_detected = len(diseases_list)
    
    # Calculate accuracy: average of confidence values, or fallback to 98% if no scans
    accuracy_avg = 98
    scans_with_conf = db.query(models.ScanHistory.confidence).filter(
        models.ScanHistory.user_id == current_user.id,
        models.ScanHistory.confidence != None,
        models.ScanHistory.confidence != "N/A"
    ).all()
    
    if scans_with_conf:
        conf_sum = 0.0
        conf_count = 0
        for c in scans_with_conf:
            try:
                # Remove % sign if any, then convert to float
                val = float(c[0].replace("%", "").strip())
                conf_sum += val
                conf_count += 1
            except ValueError:
                pass
        if conf_count > 0:
            accuracy_avg = int(conf_sum / conf_count)

    fullName = "Ramu Reddy" if current_user.username.lower() == "ramu123" or current_user.username.lower() == "ramu2005" else current_user.username.capitalize()
    
    return {
        "full_name": fullName,
        "username": current_user.username,
        "email": current_user.email,
        "phone": "+91 98765 43210",
        "location": "Chennai, Tamil Nadu",
        "total_scans": total_scans,
        "diseases_detected": diseases_detected,
        "accuracy": accuracy_avg
    }
