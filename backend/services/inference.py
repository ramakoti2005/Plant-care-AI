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

# CHANGED: Update the file extension to point to your new ONNX file
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
    # CHANGED: Replaced tf.keras.models.load_model with ort.InferenceSession
    session = ort.InferenceSession(MODEL_PATH)

    # Extract structural input/output keys dynamically
    input_name = session.get_inputs()[0].name
    output_name = session.get_outputs()[0].name
    input_shape = session.get_inputs()[0].shape

    print("ONNX MODEL LOADED SUCCESSFULLY")
    print("Input Name  :", input_name)
    print("Input Shape :", input_shape)

except Exception as e:
    print("MODEL LOAD ERROR:", e)
    session = None


# -----------------------------
# Inference Function
# -----------------------------
def run_inference(image):
    if session is None:
        raise Exception("Model session failed to load.")

    # CHANGED: Ensure the image is a strict NumPy float32 array (ONNX requirement)
    if not isinstance(image, np.ndarray):
        image = np.array(image, dtype=np.float32)

    if image.dtype != np.float32:
        image = image.astype(np.float32)

    # CHANGED: Replaced model.predict() with session.run()
    # ONNX requires an explicit map dictionary: { input_node_name: input_data }
    raw_predictions = session.run([output_name], {input_name: image})

    # Extract the prediction scores for the first batch item
    predictions = raw_predictions[0][0]
    
    # DEBUG PRINT: Check if Tomato (usually one of the last indexes) is dominating raw output
    print(f"RAW LOGITS PREDICTIONS MATRIX: {predictions}")

    # Apply Softmax to turn logits into real probabilities (0.0 to 1.0)
    exp_logits = np.exp(predictions - np.max(predictions))
    probabilities = exp_logits / np.sum(exp_logits)

    class_index = int(np.argmax(probabilities))
    confidence = float(probabilities[class_index]) * 100
    raw_label = class_names[class_index] if class_names else f"Unknown_{class_index}"

    # Clean up specific typos or names from your list
    display_name = raw_label.replace("_", " ").title()
    if "Peace" in display_name:
        display_name = display_name.replace("Peace", "Peach")
    elif "Pepper Bill" in display_name:
        display_name = display_name.replace("Pepper Bill", "Pepper Bell")

    scientific_names = {
        "Apple": "Malus domestica",
        "Corn": "Zea mays",
        "Grape": "Vitis vinifera",
        "Peach": "Prunus persica",
        "Potato": "Solanum tuberosum",
        "Rice": "Oryza sativa",
        "Tomato": "Solanum lycopersicum",
        "Pepper": "Capsicum annuum"  # Stripped to match the first word
    }
    
    # Extract the first word safely to match keys (e.g., "Tomato" from "Tomato Late Blight")
    first_word = display_name.split()[0] if display_name else ""
    sci_name = scientific_names.get(first_word, "Unknown Species")

    return {
        "plant_name": display_name,
        "scientific_name": sci_name, 
        "condition_name": "Analyzed", 
        "confidence": f"{confidence:.2f}%",  # Handled as clean percentage string string format
        "possible_matches": [],
        "image_quality": "Good",
        "issues_detected": [],
        "solution_suggestion": f"Your {display_name} leaf scan has been successfully processed. Check for visible signs of spots, wilting, or discoloration to determine specific treatments."
    }


