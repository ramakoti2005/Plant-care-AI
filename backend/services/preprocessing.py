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

    # Convert to float32 and scale to [0, 1]
    img = img.astype(np.float32) / 255.0

    # Apply ImageNet normalization (Mean & Std Deviation subtraction)
    mean = np.array([0.485, 0.456, 0.406], dtype=np.float32)
    std = np.array([0.229, 0.224, 0.225], dtype=np.float32)
    img = (img - mean) / std

    # Add batch dimension (1, 224, 224, 3)
    img = np.expand_dims(img, axis=0)

    print(f"Preprocessed image shape with ImageNet scaling: {img.shape}")
    return img
