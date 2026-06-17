import os
import json
import numpy as np
import tensorflow as tf

print("STEP 1: inference.py started")

BASE_DIR = os.path.dirname(os.path.dirname(__file__))

CLASS_NAMES_PATH = os.path.join(
    BASE_DIR,
    "ml_models",
    "class_names.json"
)

MODEL_PATH = os.path.join(
    BASE_DIR,
    "ml_models",
    "plant_disease_model.keras"
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
# Load TensorFlow model
# -----------------------------
try:
    model = tf.keras.models.load_model(
        MODEL_PATH,
        compile=False
    )

    print("MODEL LOADED SUCCESSFULLY")
    print("Input Shape :", model.input_shape)
    print("Output Shape:", model.output_shape)

except Exception as e:
    print("MODEL LOAD ERROR:", e)
    model = None


# -----------------------------
# Inference Function
# -----------------------------
def run_inference(image):

    if model is None:
        raise Exception("Model failed to load.")

    # Prediction
    predictions = model.predict(image, verbose=0)[0]

    class_index = int(np.argmax(predictions))

    confidence = float(predictions[class_index]) * 100

    disease_name = class_names[class_index]

    return {
        "plant_name": disease_name,
        "scientific_name": disease_name,
        "confidence": round(confidence, 2),
        "possible_matches": [],
        "image_quality": "Good",
        "issues_detected": [],
        "solution_suggestion": f"Detected disease: {disease_name}"

    }

