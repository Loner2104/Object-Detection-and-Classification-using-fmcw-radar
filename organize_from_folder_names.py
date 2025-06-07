import os
import shutil

# === PATH SETUP ===
rd_image_root = r"D:\RD_Images"                   # Source: session-wise folders
output_root = r"D:\RD_Images_Organized"           # Destination: class-wise folders

# === LABEL MAP: Map prefixes to merged class labels
prefix_label_map = {
    '2019_04_09_bms': 'bicycle',
    '2019_04_09_cms': 'car',
    '2019_04_09_css': 'car',
    '2019_04_09_pms': 'pedestrian',
    '2019_04_09_pbms': 'pedestrian_mixed',
    '2019_04_09_pcms': 'pedestrian_mixed',
    '2019_04_30_mlms': 'multi',
    '2019_04_30_pbms': 'pedestrian_mixed',
    '2019_04_30_pbss': 'pedestrian_mixed',
    '2019_04_30_pcms': 'pedestrian_mixed',
    '2019_05_09_bm1s': 'bicycle',
    '2019_05_09_cm1s': 'car',
    '2019_05_09_mlms': 'multi',
    '2019_05_29_bcms': 'bicycle',                 # Optional: treat as bicycle-only
    '2019_05_29_pbms': 'pedestrian_mixed',
    '2019_05_29_mlms': 'multi',
    '2019_05_29_cm1s': 'car'
}

# === LABEL DETECTION ===
def label_from_folder(folder_name):
    for prefix in sorted(prefix_label_map.keys(), key=lambda x: -len(x)):
        if folder_name.startswith(prefix):
            return prefix_label_map[prefix]
    return "unknown"

# === ORGANIZE ===
def organize_by_folder_labels(input_root, output_root):
    unknown_count = 0
    file_count = 0

    for folder in os.listdir(input_root):
        full_path = os.path.join(input_root, folder)
        if not os.path.isdir(full_path):
            continue

        label = label_from_folder(folder)
        if label == "unknown":
            print(f"⚠️ Unknown label for folder: {folder}")
            unknown_count += 1
            continue

        out_dir = os.path.join(output_root, label)
        os.makedirs(out_dir, exist_ok=True)

        for fname in os.listdir(full_path):
            if fname.endswith('.png'):
                src = os.path.join(full_path, fname)
                dst = os.path.join(out_dir, f"{folder}_{fname}")
                shutil.copy2(src, dst)
                file_count += 1

    print(f"\n✅ Organized {file_count} images.")
    if unknown_count > 0:
        print(f"⚠️ Skipped {unknown_count} unknown folders.")

# === RUN ===
organize_by_folder_labels(rd_image_root, output_root)
