from fastapi import APIRouter, Depends
import schemas
from services.simulator import simulate_progression
from services.auth import get_current_user
from models import User

router = APIRouter()

@router.get("/simulator", response_model=schemas.SimulatorResponse)
def get_simulation(disease: str, crop: str, current_severity: str = "mild", current_user: User = Depends(get_current_user)):
    """
    Returns a simulated timeline of how the disease will progress.
    """
    result = simulate_progression(disease, crop, current_severity)
    return result
