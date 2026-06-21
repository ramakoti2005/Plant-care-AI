import os
import json
import numpy as np
import onnxruntime as ort
from sqlalchemy.orm import Session
from models import ScanHistory

print("STEP 1: inference.py started with ONNX")

BASE_DIR = os.path.dirname(os.path.dirname(__file__))

CLASS_NAMES_PATH = os.path.join(
    BASE_DIR,
    "ml_models",
    "class_names.json"
)

MODEL_PATH = os.path.join(
    BASE_DIR,
    "ml_models",
    "plant_disease_model.onnx"
)

# -----------------------------
# Load class names
# -----------------------------
try:
    with open(CLASS_NAMES_PATH, "r") as f:
        class_names = json.load(f)
    print(f"Loaded {len(class_names)} classes")
except Exception as e:
    print("CLASS NAME ERROR:", e)
    class_names = []

# -----------------------------
# Load ONNX model session
# -----------------------------
try:
    session = ort.InferenceSession(MODEL_PATH)
    input_name = session.get_inputs()[0].name
    output_name = session.get_outputs()[0].name
    print("ONNX MODEL LOADED SUCCESSFULLY")
except Exception as e:
    print("MODEL LOAD ERROR:", e)
    session = None


# -----------------------------
# Core Prediction Logic
# -----------------------------
def run_inference(image):
    if session is None:
        raise Exception("Model session failed to load.")

    if not isinstance(image, np.ndarray):
        image = np.array(image, dtype=np.float32)

    if image.dtype != np.float32:
        image = image.astype(np.float32)

    raw_predictions = session.run([output_name], {input_name: image})
    predictions = raw_predictions[0][0]

    exp_logits = np.exp(predictions - np.max(predictions))
    probabilities = exp_logits / np.sum(exp_logits)

    # Get the indices of the top two highest predictions
    top_indices = np.argsort(probabilities)[-2:][::-1]
    primary_index = top_indices[0]
    secondary_index = top_indices[1]

    primary_confidence = float(probabilities[primary_index])
    secondary_confidence = float(probabilities[secondary_index])

    # Calculate the margin gap between the two highest guesses
    confidence_margin = primary_confidence - secondary_confidence

    # 🛑 STRICT GUARD: If confidence is low OR the top two guesses are too close, reject it!
    # Using 0.85 (85%) as primary threshold and 0.15 (15%) margin as requested
    if primary_confidence < 0.85 or confidence_margin < 0.15:
        return {
            "status": "Unrecognized Image",
            "message": "The uploaded image does not appear to contain a valid or recognizable plant leaf. Please try again with clear lighting."
        }

    class_index = primary_index

    raw_label = class_names[class_index]
    
    if "___" in raw_label:
        plant_part, disease_part = raw_label.split("___")
    else:
        parts = raw_label.split('_', 1)
        plant_part = parts[0]
        disease_part = parts[1] if len(parts) > 1 else "Healthy"

    plant_name = plant_part.replace("_", " ").title()
    disease_name = disease_part.replace("_", " ").title()
    
    if plant_name == "Pepperbell":
        plant_name = "Pepper Bell"

    treatment_database = {
        "Black Rot": "Prune infected branches 4-6 inches below the canker. Apply a copper-based fungicide early in the season.",
        "Apple Scab": "Rake and destroy fallen leaves to prevent overwintering spores. Apply preventative fungicides during green tip stage.",
        "Common Rust": "Remove nearby alternate hosts (like cedar trees). Apply sulfur or chlorothalonil fungicides at first sign of spots.",
        "Early Blight": "Improve air circulation by pruning lower leaves. Apply copper fungicide every 7-10 days during humid weather.",
        "Late Blight": "Immediately destroy infected plants to prevent airborne spread. Apply chlorothalonil or copper spray pre-emptively.",
        "Leaf Blast": "Avoid excessive nitrogen fertilizers. Maintain stable water layers in the field to protect the plant, and apply systemic fungicides like Tricyclazole or Azoxystrobin if spots appear.",
        "Healthy": "No treatment required. Maintain optimal watering, consistent pruning, and regular soil nutrient monitoring."
    }

    cure_solution = treatment_database.get(disease_name, "Maintain standard plant hygiene, prune affected areas, and ensure proper soil drainage.")

    reference_image_url = None
    dataset_rel_path = os.path.join("appdataset", "dataset", raw_label)
    project_root = os.path.dirname(BASE_DIR)
    dataset_full_path = os.path.join(project_root, dataset_rel_path)

    try:
        if os.path.exists(dataset_full_path) and os.path.isdir(dataset_full_path):
            files = [f for f in os.listdir(dataset_full_path) if f.lower().endswith(('.png', '.jpg', '.jpeg'))]
            if files:
                reference_image_url = f"/dataset/{raw_label}/{files[0]}"
    except Exception as e:
        print(f"Error finding reference image: {e}")

    return {
        "status": "Success",
        "plant_name": plant_name,
        "disease_name": disease_name,
        "cure": cure_solution,
        "reference_image": reference_image_url,
        "reference_image_key": raw_label.lower()
    }

# -----------------------------
# Success Logging Helper
# -----------------------------
def process_prediction_and_save(image, db: Session, user_id: int = None):
    # 1. Run the existing inference
    response_data = run_inference(image)

    # 2. If valid, log to history
    if response_data.get("status") == "Success":
        try:
            new_history = ScanHistory(
                user_id=user_id,
                plant_name=response_data["plant_name"],
                disease_name=response_data["disease_name"],
                solution_suggestion=response_data["cure"], # Mapped to treatment
                scientific_name=response_data["disease_name"], # Fallback
                confidence="N/A",
                image_quality="Good",
                possible_matches="[]",
                issues_detected="[]"
            )
            db.add(new_history)
            db.commit()
            db.refresh(new_history)
            print("Success: Scan history recorded dynamically in database.")
        except Exception as e:
            db.rollback()
            print(f"Database logging failed: {str(e)}")

    return response_data
