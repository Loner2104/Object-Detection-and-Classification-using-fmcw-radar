import tensorflow as tf
from tensorflow.keras import layers, models
import numpy as np
import os
import cv2
from sklearn.model_selection import train_test_split

# === CONFIG ===
image_dir = r"D:\RD_Images_Organized"  # Folder with subfolders: one per class
img_size = (128, 128)
batch_size = 32
epochs = 10

# === LOAD DATA ===
def load_data(image_dir, img_size):
    X, y = [], []
    class_names = sorted(os.listdir(image_dir))  # auto-detects class names from folders
    label_map = {cls: idx for idx, cls in enumerate(class_names)}

    for cls in class_names:
        folder = os.path.join(image_dir, cls)
        if not os.path.isdir(folder):
            continue
        for file in os.listdir(folder):
            if file.endswith('.png'):
                img_path = os.path.join(folder, file)
                img = cv2.imread(img_path)
                if img is None:
                    continue
                img = cv2.resize(img, img_size)
                X.append(img)
                y.append(label_map[cls])
    
    X = np.array(X, dtype=np.float32) / 255.0
    y = np.array(y)
    return X, y, class_names

# === LOAD AND SPLIT ===
X, y, class_names = load_data(image_dir, img_size)
print(f"✅ Classes used: {class_names}")
X_train, X_val, y_train, y_val = train_test_split(X, y, test_size=0.2, stratify=y)

# === CNN MODEL ===
model = models.Sequential([
    layers.Input(shape=(img_size[0], img_size[1], 3)),
    layers.Conv2D(32, (3, 3), activation='relu'),
    layers.MaxPooling2D(2, 2),
    layers.Conv2D(64, (3, 3), activation='relu'),
    layers.MaxPooling2D(2, 2),
    layers.Flatten(),
    layers.Dense(64, activation='relu'),
    layers.Dense(len(class_names), activation='softmax')  # output layer size = num_classes
])

model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

# === TRAIN ===
model.fit(X_train, y_train, epochs=epochs, batch_size=batch_size, validation_data=(X_val, y_val))

# === SAVE MODELS ===
model.save("rdmap_cnn_model.h5")
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()
with open("rdmap_model.tflite", "wb") as f:
    f.write(tflite_model)

print("\n✅ Training complete.")
print("💾 Saved: rdmap_cnn_model.h5 and rdmap_model.tflite")
