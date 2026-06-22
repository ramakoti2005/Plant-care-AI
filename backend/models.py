from sqlalchemy import Boolean, Column, Integer, String, Text, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from database import Base
from datetime import datetime

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    is_active = Column(Boolean, default=True)

    scans = relationship("ScanHistory", back_populates="user")

class Disease(Base):
    __tablename__ = "diseases"

    id = Column(Integer, primary_key=True, index=True)
    crop = Column(String, index=True)
    name = Column(String, index=True)
    description = Column(Text)
    
    # Treatment recommendations stored as JSON string or text
    chemical_treatment = Column(Text)
    organic_treatment = Column(Text)
    prevention = Column(Text)

class ScanHistory(Base):
    __tablename__ = "scan_histories"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    plant_name = Column(String, index=True)
    disease_name = Column(String, index=True) # Added for history compatibility
    scientific_name = Column(String)
    confidence = Column(String)
    image_quality = Column(String)
    possible_matches = Column(Text) 
    issues_detected = Column(Text) 
    solution_suggestion = Column(Text) # This maps to 'treatment'
    image_path = Column(String, nullable=True)
    timestamp = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="scans")
