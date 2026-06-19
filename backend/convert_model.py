import os
import tensorflow as tf
import tf2onnx

# 1. SET YOUR FILENAMES HERE
# Change this to 'plant_disease_model.h5' if you prefer using the .h5 file instead
ORIGINAL_MODEL_NAME = "plant_disease_model.keras"
OUTPUT_ONNX_NAME = "plant_disease_model.onnx"

# Define your model's expected image size (Height, Width, Channels)
# Look at your old inference code or training code to verify if it's 224, 256, 150, etc.
IMAGE_HEIGHT = 224
IMAGE_WIDTH = 224
CHANNELS = 3

# Build the paths dynamically based on your project structure
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "ml_models", ORIGINAL_MODEL_NAME)
ONNX_PATH = os.path.join(BASE_DIR, "ml_models", OUTPUT_ONNX_NAME)

print(f"Loading Keras model from: {MODEL_PATH}...")

try:
    # 2. Load your existing model without compiling it (saves memory)
    model = tf.keras.models.load_model(MODEL_PATH, compile=False)
    print("Model loaded successfully!")

    # Show the exact input shape to verify your setup
    print("Model Input Shape:", model.input_shape)

    # 3. Define the input signature for ONNX
    # [None, Height, Width, Channels] allows for dynamic batching during production
    input_signature = [
        tf.TensorSpec([None, IMAGE_HEIGHT, IMAGE_WIDTH, CHANNELS], tf.float32, name="input_1")
    ]

    print("Converting to ONNX format (this may take a minute)...")

    # 4. Perform the conversion using tf2onnx
    onnx_model, _ = tf2onnx.convert.from_keras(
        model,
        input_signature=input_signature,
        opset=13  # Opset 13 is highly compatible and reliable for Render production
    )

    # 5. Save the final .onnx file to your ml_models folder
    with open(ONNX_PATH, "wb") as f:
        f.write(onnx_model.SerializeToString())

    print(f"🎉 Success! Your ONNX model is ready at: {ONNX_PATH}")
    print("You can now safely delete the script and your old .keras/.h5 files before deploying.")

except Exception as e:
    print(f"\n❌ CONVERSION FAILED: {e}")
    print("Double check that your IMAGE_HEIGHT and IMAGE_WIDTH match your model's true architecture.")