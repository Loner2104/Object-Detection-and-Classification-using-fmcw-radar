import os
import scipy.io
import numpy as np
from scipy.signal.windows import hann
import cv2

def generate_rd_map_image(mat_path, output_path, variable_name='adcData', N_range=128):
    try:
        mat = scipy.io.loadmat(mat_path)
        raw = mat[variable_name]  # (128, 255, 4, 2)
        complex_data = raw[..., 0] + 1j * raw[..., 1]
        iq_data = np.mean(complex_data, axis=2)
        window = hann(N_range)
        windowed = iq_data * window[:, np.newaxis]
        range_fft = np.fft.fft(windowed, axis=0)
        doppler_fft = np.fft.fftshift(np.fft.fft(range_fft, axis=1), axes=1)
        rd_map = 20 * np.log10(np.abs(doppler_fft) + 1e-6)
        rd_map_norm = cv2.normalize(rd_map, None, 0, 255, cv2.NORM_MINMAX)
        rd_map_img = rd_map_norm.astype(np.uint8)
        rd_map_color = cv2.applyColorMap(rd_map_img, cv2.COLORMAP_JET)
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        cv2.imwrite(output_path, rd_map_color)
        return True
    except Exception as e:
        return f"Failed on {mat_path}: {str(e)}"

def batch_process_radar_dataset(base_dir, output_root):
    folders = [f for f in os.listdir(base_dir) if os.path.isdir(os.path.join(base_dir, f))]
    results = []
    for folder in folders:
        mat_dir = os.path.join(base_dir, folder, 'radar_raw_frame')
        output_dir = os.path.join(output_root, folder)
        if not os.path.exists(mat_dir):
            continue
        for mat_file in os.listdir(mat_dir):
            if mat_file.endswith('.mat'):
                mat_path = os.path.join(mat_dir, mat_file)
                out_img = os.path.join(output_dir, mat_file.replace('.mat', '.png'))
                result = generate_rd_map_image(mat_path, out_img)
                results.append((mat_file, result))
    return results

# ✅ Change these if your folder paths are different:
base_data_folder = r"D:\Automotive\Automotive"
output_image_folder = r"D:\RD_Images"

# Run the batch conversion
results = batch_process_radar_dataset(base_data_folder, output_image_folder)

# Log failed ones
with open("rd_map_conversion_log.txt", "w") as f:
    for fname, result in results:
        if result is not True:
            f.write(f"{fname}: {result}\n")
