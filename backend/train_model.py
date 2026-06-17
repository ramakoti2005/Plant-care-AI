import os
import json
import tensorflow as tf
from tensorflow.keras import layers, models
from tensorflow.keras.applications import MobileNetV2

# ---------------------------------------
# Project Paths
# ---------------------------------------
PROJECT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

DATASET_DIR = os.path.join(PROJECT_DIR, "appdataset", "dataset")
MODEL_DIR = os.path.join(PROJECT_DIR, "backend", "ml_models")

MODEL_PATH = os.path.join(MODEL_DIR, "plant_disease_model.keras")
CLASS_NAMES_PATH = os.path.join(MODEL_DIR, "class_names.json")

IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 5


def main():

    print("Dataset Path:", DATASET_DIR)

    if not os.path.exists(DATASET_DIR):
        print("Dataset not found!")
        return

    os.makedirs(MODEL_DIR, exist_ok=True)

    print("Loading dataset...")

    train_ds = tf.keras.utils.image_dataset_from_directory(
        DATASET_DIR,
        validation_split=0.2,
        subset="training",
        seed=123,
        image_size=IMG_SIZE,
        batch_size=BATCH_SIZE
    )

    val_ds = tf.keras.utils.image_dataset_from_directory(
        DATASET_DIR,
        validation_split=0.2,
        subset="validation",
        seed=123,
        image_size=IMG_SIZE,
        batch_size=BATCH_SIZE
    )

    class_names = train_ds.class_names

    with open(CLASS_NAMES_PATH, "w") as f:
        json.dump(class_names, f)

    print(f"Saved {len(class_names)} class names.")

    AUTOTUNE = tf.data.AUTOTUNE

    train_ds = train_ds.shuffle(100).prefetch(AUTOTUNE)
    val_ds = val_ds.prefetch(AUTOTUNE)

    print("Building MobileNetV2...")

    base_model = MobileNetV2(
        input_shape=(224, 224, 3),
        include_top=False,
        weights="imagenet"
    )

    base_model.trainable = False

    inputs = tf.keras.Input(shape=(224, 224, 3))

    # Deployment-friendly preprocessing
    x = tf.keras.applications.mobilenet_v2.preprocess_input(inputs)

    x = base_model(x, training=False)

    x = layers.GlobalAveragePooling2D()(x)

    x = layers.Dropout(0.2)(x)

    outputs = layers.Dense(len(class_names))(x)

    model = models.Model(inputs, outputs)

    model.compile(
        optimizer="adam",
        loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
        metrics=["accuracy"]
    )

    model.summary()

    print("Training Started...")

    model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=EPOCHS
    )

    print("Saving model...")

    model.save(MODEL_PATH)

    print("Training Completed Successfully!")
    print("Model saved to:", MODEL_PATH)


if __name__ == "__main__":
    main()