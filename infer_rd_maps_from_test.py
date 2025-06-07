import os
import cv2
import numpy as np
import tensorflow as tf
import csv
from datetime import datetime

# === CONFIG ===
model_path = "rdmap_model_vega.tflite"
test_folder = r"C:\Users\PRASHANTH\Desktop\testttttttttt"
img_size = (128, 128)
label_names = ['bicycle', 'car', 'multi', 'pedestrian', 'pedestrian_mixed']

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
output_csv = f"predictions_from_vivado_{timestamp}.csv"

# === Load TFLite model
interpreter = tf.lite.Interpreter(model_path=model_path)
interpreter.allocate_tensors()
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# === Log predictions
rows = [["Filename", "Top1", "Conf1", "Top2", "Conf2", "Top3", "Conf3"]]

# === Process images
for fname in os.listdir(test_folder):
    if not fname.lower().endswith(('.png', '.jpg', '.jpeg')):
        continue

    img_path = os.path.join(test_folder, fname)
    img = cv2.imread(img_path)
    if img is None:
        continue

    img = cv2.resize(img, img_size).astype(np.uint8)
    input_data = np.expand_dims(img, axis=0)

    interpreter.set_tensor(input_details[0]['index'], input_data)
    interpreter.invoke()
    output = interpreter.get_tensor(output_details[0]['index'])[0]

    top_indices = np.argsort(output)[::-1][:3]
    top_scores = [output[i] / 255.0 * 100 for i in top_indices]
    top_labels = [label_names[i] for i in top_indices]

    print(f"\n🧠 {fname} → {top_labels[0]} ({top_scores[0]:.2f}%)")
    for i in range(3):
        print(f"   {top_labels[i]}: {top_scores[i]:.2f}%")

    rows.append([
        fname,
        top_labels[0], f"{top_scores[0]:.2f}",
        top_labels[1], f"{top_scores[1]:.2f}",
        top_labels[2], f"{top_scores[2]:.2f}"
    ])

# === Write CSV
with open(output_csv, "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerows(rows)

print(f"\n✅ Predictions saved to {output_csv}")
