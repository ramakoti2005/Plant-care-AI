import os
import json
import numpy as np
import onnxruntime as ort

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

print("STEP 2: Paths created")

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
# Inference Function
# -----------------------------
def run_inference(image):
    if session is None:
        raise Exception("Model session failed to load.")

    # Preprocessing
    if not isinstance(image, np.ndarray):
        image = np.array(image, dtype=np.float32)

    if image.dtype != np.float32:
        image = image.astype(np.float32)

    # Inference
    raw_predictions = session.run([output_name], {input_name: image})
    predictions = raw_predictions[0][0]

    # Apply Softmax to get probabilities
    exp_logits = np.exp(predictions - np.max(predictions))
    probabilities = exp_logits / np.sum(exp_logits)

    class_index = int(np.argmax(probabilities))
    confidence = float(probabilities[class_index]) * 100

    # 1. Validation Logic
    # If confidence is low, categorize as Unrecognized Image
    if confidence < 75.0:
        return {
            "status": "Unrecognized Image",
            "message": "This image is not recognized as a supported plant leaf. Please upload a clear image of a supported plant leaf."
        }

    raw_label = class_names[class_index]
    
    # 1. Split the string into distinct parts using delimiter
    if "___" in raw_label:
        plant_part, disease_part = raw_label.split("___")
    else:
        # Fallback for single underscore or other formats
        parts = raw_label.split('_', 1)
        plant_part = parts[0]
        disease_part = parts[1] if len(parts) > 1 else "Healthy"

    # 2. Clean up underscores and format text beautifully
    plant_name = plant_part.replace("_", " ").title()
    disease_name = disease_part.replace("_", " ").title()
    
    # Handle specific naming fixes
    if plant_name == "Pepperbell":
        plant_name = "Pepper Bell"

    # 3. Create a deterministic treatment database mapping
    treatment_database = {
        "Black Rot": "Prune infected branches 4-6 inches below the canker. Apply a copper-based fungicide early in the season.",
        "Apple Scab": "Rake and destroy fallen leaves to prevent overwintering spores. Apply preventative fungicides during green tip stage.",
        "Common Rust": "Remove nearby alternate hosts (like cedar trees). Apply sulfur or chlorothalonil fungicides at first sign of spots.",
        "Early Blight": "Improve air circulation by pruning lower leaves. Apply copper fungicide every 7-10 days during humid weather.",
        "Late Blight": "Immediately destroy infected plants to prevent airborne spread. Apply chlorothalonil or copper spray pre-emptively.",
        
        # 🌾 Added specific mapping for Rice Leaf Blast:
        "Leaf Blast": "Avoid excessive nitrogen fertilizers. Maintain stable water layers in the field to protect the plant, and apply systemic fungicides like Tricyclazole or Azoxystrobin if spots appear.",

        "Healthy": "No treatment required. Maintain optimal watering, consistent pruning, and regular soil nutrient monitoring."
    }

    # Fetch the cure based on the disease name (default back to general care)
    cure_solution = treatment_database.get(disease_name, "Maintain standard plant hygiene, prune affected areas, and ensure proper soil drainage.")

    # 3. Get Reference Image Link
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

    # Return the complete package to your Flutter app
    return {
        "status": "Success",
        "plant_name": plant_name,
        "disease_name": disease_name,
        "cure": cure_solution,
        "reference_image": reference_image_url,
        "reference_image_key": raw_label.lower()
    }
