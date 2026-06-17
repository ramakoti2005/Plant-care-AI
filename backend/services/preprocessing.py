import cv2
import numpy as np


def preprocess_image(image_bytes: bytes) -> np.ndarray:
    """
    Preprocess uploaded image for TensorFlow model inference.

    Steps:
    1. Decode image bytes
    2. Convert BGR -> RGB
    3. Resize to model input size (224x224)
    4. Convert to float32
    5. Normalize to [0,1]
    6. Add batch dimension

    Returns:
        Shape: (1, 224, 224, 3)
    """

    # Decode image bytes
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    if img is None:
        raise ValueError("Invalid image data")

    # Convert BGR to RGB
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    # Resize image
    img = cv2.resize(img, (224, 224))

    # Convert to float32
    img = img.astype(np.float32)

    # Normalize
    img = img / 255.0

    # Add batch dimension
    img = np.expand_dims(img, axis=0)

    print(f"Preprocessed image shape: {img.shape}")

    return img
