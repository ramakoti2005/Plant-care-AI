import cv2
import numpy as np

def preprocess_image(image_bytes: bytes) -> np.ndarray:
    """
    Preprocess uploaded image for ONNX model inference with ImageNet standardization.
    """
    # Decode image bytes
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    if img is None:
        raise ValueError("Invalid image data")

    # Convert BGR to RGB
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    # Resize image to 224x224
    img = cv2.resize(img, (224, 224))

    # Convert image tensor array to float32
    img = img.astype(np.float32)

    # 🔄 Standard raw float scaling (No division or subtraction transformations)
    # Keeping the values in the native [0.0, 255.0] range
    
    # Add batch array layer dimension (1, 224, 224, 3)
    img = np.expand_dims(img, axis=0)

    print(f"Preprocessed image shape with raw 0-255 scaling: {img.shape}")
    return img
