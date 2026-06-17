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
    plant_name: str
    scientific_name: str
    confidence: str
    possible_matches: List[str]
    image_quality: str
    issues_detected: List[str]
    solution_suggestion: str

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

    class Config:
        from_attributes = True
