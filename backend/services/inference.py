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

    # Get the top prediction
    class_index = int(np.argmax(probabilities))
    confidence = float(probabilities[class_index]) * 100

    # If confidence is too low, we treat it as unrecognized
    if confidence < 15.0:
        return {
            "status": "Unrecognized Image",
            "message": "The uploaded image does not match any supported plant leaf in the dataset."
        }

    raw_label = class_names[class_index]
    
    # Split the string into distinct parts (Plant and Disease)
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

    # Treatment database (Expanded to support all your model classes)
    treatment_database = {
        "Black Rot": "Prune infected branches 4-6 inches below the canker. Apply a copper-based fungicide early in the season and destroy fallen leaves.",
        "Apple Scab": "Rake and destroy fallen leaves to prevent overwintering spores. Apply preventative fungicides during green tip stage.",
        "Common Rust": "Remove nearby alternate hosts (like cedar trees). Apply sulfur or chlorothalonil fungicides at first sign of spots.",
        "Early Blight": "Improve air circulation by pruning lower leaves. Apply copper fungicide every 7-10 days during humid weather.",
        "Late Blight": "Immediately destroy infected plants to prevent airborne spread. Apply chlorothalonil or copper spray pre-emptively.",
        "Leaf Blast": "Avoid excessive nitrogen fertilizers. Maintain stable water layers in the field to protect the plant, and apply systemic fungicides like Tricyclazole or Azoxystrobin if spots appear.",
        "Bacterial Spot": "Apply copper-based bactericides early in the season. Avoid overhead watering to reduce moisture on leaves and remove infected plant debris.",
        "Brown Spot": "Apply balanced fertilizers (avoid low potassium). Use certified disease-free seeds and apply recommended fungicides if infestation spreads.",
        "Healthy": "No treatment required. Maintain optimal watering, consistent pruning, and regular soil nutrient monitoring."
    }

    # Fallback to a general safe message if a disease isn't explicitly listed
    treatment = treatment_database.get(
        disease_name, 
        f"Prune affected areas, optimize water drainage, remove plant debris, and apply a general-purpose crop protector matching {disease_name} if symptoms persist."
    )

    # Get Reference Image Link
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

    # 🚀 MULTI-KEY PAYLOAD: Sends every possible variant so Flutter never reads a null field!
    return {
        "status": "Success",
        "plant_name": plant_name,
        "disease_name": disease_name,
        "reference_image": reference_image_url,
        "treatment": treatment,
        "cure": treatment,
        "solution_suggestion": treatment
    }

# -----------------------------
# Success Logging Helper
# -----------------------------
def process_prediction_and_save(image, db: Session, user_id: int = None):
    response_data = run_inference(image)

    if response_data.get("status") == "Success":
        try:
            new_history = ScanHistory(
                user_id=user_id,
                plant_name=response_data["plant_name"],
                disease_name=response_data["disease_name"],
                solution_suggestion=response_data["treatment"],
                timestamp=None # Default will be used
            )
            db.add(new_history)
            db.commit()
        except Exception as e:
            db.rollback()
            print(f"Database logging failed: {str(e)}")

    return response_data
