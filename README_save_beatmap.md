# Beatmap Saver Script

This Python script saves beatmap data to the `.prbm` file format, which is a ZIP archive containing the beatmap manifest and associated assets (audio and image files).

## Usage

```bash
python save_beatmap.py <output.prbm> <manifest.json> [--audio <audio_file>] [--image <image_file>]
```

### Arguments

- `output`: Path to the output `.prbm` file. If it doesn't end with `.prbm`, the extension will be added automatically.
- `manifest`: Path to a JSON file containing the beatmap data (metadata and notes).
- `--audio`: (Optional) Path to the audio file to include in the beatmap.
- `--image`: (Optional) Path to the image file to include in the beatmap.

### Example

```bash
python save_beatmap.py my_beatmap.prbm beatmap_data.json --audio song.mp3 --image cover.png
```

This will create `my_beatmap.prbm` containing:
- `manifest.json`: The beatmap data with updated asset paths.
- `song.mp3`: The audio file (renamed internally).
- `cover.png`: The image file (renamed internally).

## Requirements

- Python 3.x
- Standard library modules (no external dependencies)

## How it works

1. Creates a temporary directory.
2. Copies the audio and image files to the temp directory with standardized names (`song.*` and `cover.*`).
3. Updates the manifest JSON to reference the new asset paths.
4. Writes the manifest to `manifest.json` in the temp directory.
5. Zips the contents of the temp directory into the output `.prbm` file.
6. Cleans up the temporary directory.

## Troubleshooting

- Ensure the input JSON file is valid JSON.
- Check that audio and image file paths exist if provided.
- The script will overwrite the output file if it already exists.