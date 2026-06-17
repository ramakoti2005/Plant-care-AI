def simulate_progression(disease: str, crop: str, current_severity: str):
    """
    Mock simulator logic that predicts the progression of a disease over time
    if no action is taken.
    """
    
    # Simple hardcoded mock progression for demonstration
    timeline = []
    
    if current_severity.lower() == "mild":
        timeline = [
            {"day": 7, "severity": "Moderate", "symptoms": "Spots increase in size and number. Yellowing begins."},
            {"day": 14, "severity": "Severe", "symptoms": "Significant defoliation. Fruit yield threatened."},
            {"day": 30, "severity": "Critical", "symptoms": "Plant likely to die. Spores actively spreading to neighboring crops."}
        ]
    elif current_severity.lower() == "moderate":
        timeline = [
            {"day": 7, "severity": "Severe", "symptoms": "Significant defoliation. Fruit yield heavily impacted."},
            {"day": 14, "severity": "Critical", "symptoms": "Plant structure failing. Major crop loss."},
            {"day": 30, "severity": "Terminal", "symptoms": "Total plant death. Soil contamination high."}
        ]
    else:
        timeline = [
            {"day": 7, "severity": "Critical", "symptoms": "Rapid deterioration. Immediate removal recommended."},
            {"day": 14, "severity": "Terminal", "symptoms": "Plant death."}
        ]
        
    return {
        "disease": disease,
        "crop": crop,
        "progression": timeline
    }
