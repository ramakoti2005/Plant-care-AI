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
    # Green range - refined to require clear leaf saturation and value
    lower_green = np.array([25, 35, 35])
    upper_green = np.array([90, 255, 255])
    
    # Yellow/Brown range (for diseased or dried leaves)
    lower_brown = np.array([9, 40, 40])
    upper_brown = np.array([25, 255, 255])

    mask_green = cv2.inRange(hsv, lower_green, upper_green)
    mask_brown = cv2.inRange(hsv, lower_brown, upper_brown)
    
    leaf_mask = cv2.bitwise_or(mask_green, mask_brown)
    
    # Calculate percentage of pixels that match leaf colors
    leaf_pixels = cv2.countNonZero(leaf_mask)
    total_pixels = img.shape[0] * img.shape[1]
    leaf_density = (leaf_pixels / total_pixels) * 100

    # 2. Non-Leaf Color Analysis (Red, Blue, Purple, Pink, Magenta)
    # Red range 1
    mask_red1 = cv2.inRange(hsv, np.array([0, 50, 50]), np.array([8, 255, 255]))
    # Red range 2 / Magenta / Pink
    mask_red2 = cv2.inRange(hsv, np.array([160, 50, 50]), np.array([180, 255, 255]))
    # Blue / Purple / Violet
    mask_blue = cv2.inRange(hsv, np.array([100, 50, 50]), np.array([150, 255, 255]))
    
    non_leaf_mask = cv2.bitwise_or(cv2.bitwise_or(mask_red1, mask_red2), mask_blue)
    non_leaf_pixels = cv2.countNonZero(non_leaf_mask)
    non_leaf_density = (non_leaf_pixels / total_pixels) * 100

    # 3. Texture/Blur Check (Laplacian Variance)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    blur_score = cv2.Laplacian(gray, cv2.CV_64F).var()

    # Stricter Heuristic Thresholds:
    # - At least 15% of the image should be leaf-colored
    # - Image shouldn't be blurry (blur_score >= 10)
    # - Non-leaf colors (red, blue, magenta, purple) must be <= 10%
    if leaf_density < 15 or blur_score < 10 or non_leaf_density > 10:
        return False
        
    return True
