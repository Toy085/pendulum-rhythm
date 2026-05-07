import json
import zipfile
import os
import shutil
import sys
import argparse

def save_beatmap(output_path, beatmap_data, audio_path=None, image_path=None):
    """
    Saves a beatmap to a .prbm file (which is a ZIP archive).

    :param output_path: Path to the output .prbm file
    :param beatmap_data: Dictionary containing beatmap metadata and notes
    :param audio_path: Path to the audio file (optional)
    :param image_path: Path to the image file (optional)
    """
    import tempfile

    with tempfile.TemporaryDirectory() as temp_dir:
        # Prepare manifest data
        manifest = beatmap_data.copy()

        # Handle audio file
        if audio_path and os.path.exists(audio_path):
            ext = os.path.splitext(audio_path)[1]
            song_name = f'song{ext}'
            shutil.copy(audio_path, os.path.join(temp_dir, song_name))
            manifest['audio'] = song_name

        # Handle image file
        if image_path and os.path.exists(image_path):
            ext = os.path.splitext(image_path)[1]
            cover_name = f'cover{ext}'
            shutil.copy(image_path, os.path.join(temp_dir, cover_name))
            manifest['image'] = cover_name

        # Write manifest.json
        manifest_path = os.path.join(temp_dir, 'manifest.json')
        with open(manifest_path, 'w', encoding='utf-8') as f:
            json.dump(manifest, f, indent=2)

        # Ensure output path has .prbm extension
        if not output_path.endswith('.prbm'):
            output_path += '.prbm'

        # Create ZIP file
        with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zf:
            for root, dirs, files in os.walk(temp_dir):
                for file in files:
                    file_path = os.path.join(root, file)
                    arcname = os.path.relpath(file_path, temp_dir)
                    zf.write(file_path, arcname)

        print(f"Beatmap saved successfully to {output_path}")

def main():
    parser = argparse.ArgumentParser(description="Save a beatmap to .prbm format")
    parser.add_argument("output", help="Output .prbm file path")
    parser.add_argument("manifest", help="JSON file containing beatmap data")
    parser.add_argument("--audio", help="Path to audio file")
    parser.add_argument("--image", help="Path to image file")

    args = parser.parse_args()

    # Load beatmap data from JSON file
    with open(args.manifest, 'r', encoding='utf-8') as f:
        beatmap_data = json.load(f)

    save_beatmap(args.output, beatmap_data, args.audio, args.image)

if __name__ == "__main__":
    main()