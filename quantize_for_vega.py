import tensorflow as tf
import numpy as np

# Load your trained Keras model
model = tf.keras.models.load_model("rdmap_cnn_model.h5")

# Set up converter
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]

# Dummy calibration data
def representative_dataset():
    for _ in range(100):
        yield [np.random.rand(1, 128, 128, 3).astype(np.float32)]

converter.representative_dataset = representative_dataset
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
converter.inference_input_type = tf.uint8
converter.inference_output_type = tf.uint8

# Convert and save
tflite_model = converter.convert()
with open("rdmap_model_vega.tflite", "wb") as f:
    f.write(tflite_model)

print("✅ Saved quantized model: rdmap_model_vega.tflite")
