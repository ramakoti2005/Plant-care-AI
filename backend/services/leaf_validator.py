import cv2
import numpy as np
from fastapi import HTTPException, status

def is_leaf_image(image_bytes: bytes) -> bool:
    """
    Validates if the uploaded image is likely a plant leaf using color and texture analysis.
    This runs BEFORE the ONNX model to filter out non-plant images.
    """
    # Decode image
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    
    if img is None:
        return False

    # 1. Color Analysis (HSV Space)
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    # Define color ranges for plant leaves (Green, Yellow, Brown/Dried)
    # Green range
    lower_green = np.array([30, 30, 30])
    upper_green = np.array([95, 255, 255])
    
    # Yellow/Brown range (for diseased or dried leaves)
    lower_brown = np.array([10, 30, 30])
    upper_brown = np.array([30, 255, 255])

    mask_green = cv2.inRange(hsv, lower_green, upper_green)
    mask_brown = cv2.inRange(hsv, lower_brown, upper_brown)
    
    leaf_mask = cv2.bitwise_or(mask_green, mask_brown)
    
    # Calculate percentage of pixels that match leaf colors
    leaf_pixels = cv2.countNonZero(leaf_mask)
    total_pixels = img.shape[0] * img.shape[1]
    leaf_density = (leaf_pixels / total_pixels) * 100

    # 2. Texture/Blur Check (Laplacian Variance)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    blur_score = cv2.Laplacian(gray, cv2.CV_64F).var()

    # Heuristic Thresholds:
    # - At least 15% of the image should be leaf-colored
    # - Image shouldn't be extremely blurry (score > 10)
    # - Image shouldn't be a solid color (density < 98%)
    
    if leaf_density < 15 or leaf_density > 98 or blur_score < 10:
        return False
        
    return True
