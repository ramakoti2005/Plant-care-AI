import os
import shutil

# Paths based on your Windows directory structure
ROOT_DATASET_DIR = r"E:\projects\Plant-care-AI\appdataset\dataset"

print("Starting dataset flattening process...")

# 1. Scan the subfolders (e.g., dataset/apple, dataset/tomato)
for plant_folder in os.listdir(ROOT_DATASET_DIR):
    plant_path = os.path.join(ROOT_DATASET_DIR, plant_folder)
    
    # Make sure we are looking inside a folder, not a stray file
    if os.path.isdir(plant_path):
        
        # 2. Scan the deep disease folders (e.g., dataset/apple/Apple_Black_Rot)
        for disease_folder in os.listdir(plant_path):
            disease_path = os.path.join(plant_path, disease_folder)
            
            if os.path.isdir(disease_path):
                # Define the new flat destination path (e.g., dataset/Apple_Black_Rot)
                destination_path = os.path.join(ROOT_DATASET_DIR, disease_folder)
                
                print(f"Moving: {disease_folder} -> Out to main level")
                
                # Move the entire disease folder up to the main level
                shutil.move(disease_path, destination_path)
        
        # 3. Clean up the now-empty parent category folder (like empty 'apple' folder)
        try:
            os.rmdir(plant_path)
            print(f"Removed empty parent category folder: {plant_folder}")
        except Exception:
            pass

print("Dataset successfully flattened!")
