import os
import tensorflow as tf
import tf2onnx

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
KERAS_MODEL_PATH = os.path.join(BASE_DIR, "ml_models", "plant_disease_model.keras")
ONNX_MODEL_PATH = os.path.join(BASE_DIR, "ml_models", "plant_disease_model.onnx")

print("Loading Keras model for conversion...")
model = tf.keras.models.load_model(KERAS_MODEL_PATH)

print("Converting Keras model format into optimized ONNX layout...")
# Set up a dynamic input signature to accept varying image batch requests seamlessly
input_signature = [tf.TensorSpec([None, 224, 224, 3], tf.float32, name="input_1")]

# Convert to ONNX format
onnx_model, _ = tf2onnx.convert.from_keras(model, input_signature, opset=13)

# Save the model
with open(ONNX_MODEL_PATH, "wb") as f:
    f.write(onnx_model.SerializeToString())

print(f"🎉 Success! ONNX model saved perfectly to: {ONNX_MODEL_PATH}")