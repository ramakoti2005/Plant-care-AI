from pydantic import BaseModel
from typing import Optional, List

# Token Schemas
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

# User Schemas
class UserBase(BaseModel):
    username: str
    email: str

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: int
    is_active: bool

    class Config:
        from_attributes = True

# Analysis Responses
class AnalysisResponse(BaseModel):
    status: str
    message: Optional[str] = None
    plant_name: Optional[str] = None
    disease_name: Optional[str] = None
    reference_image: Optional[str] = None
    treatment: Optional[str] = None
    cure: Optional[str] = None
    reference_image_key: Optional[str] = None
    scientific_name: Optional[str] = None
    confidence: Optional[str] = None
    image_quality: Optional[str] = None
    possible_matches: Optional[List[str]] = []
    issues_detected: Optional[List[str]] = []
    solution_suggestion: Optional[str] = None

# Simulator Schemas
class ProgressionStage(BaseModel):
    day: int
    severity: str
    symptoms: str

class SimulatorResponse(BaseModel):
    disease: str
    crop: str
    progression: List[ProgressionStage]

# Scan History Schema
from datetime import datetime

class ScanHistorySchema(BaseModel):
    id: int
    plant_name: str
    scientific_name: str
    confidence: str
    possible_matches: List[str]
    image_quality: str
    issues_detected: List[str]
    solution_suggestion: str
    timestamp: datetime
    image_path: Optional[str] = None

    class Config:
        from_attributes = True
