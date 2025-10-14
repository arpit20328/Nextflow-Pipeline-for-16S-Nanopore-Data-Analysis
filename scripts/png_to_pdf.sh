#!/bin/bash

# Check if folder is provided
if [ -z "$1" ]; then
  echo "Usage: $0 /path/to/folder"
  exit 1
fi

FOLDER="$1"

# Check if folder exists
if [ ! -d "$FOLDER" ]; then
  echo "Error: Folder '$FOLDER' does not exist."
  exit 1
fi

# Convert each PNG file in the folder
for img in "$FOLDER"/*.png; do
  # Skip if no PNGs are found
  [ -e "$img" ] || continue

  base=$(basename "$img" .png)
  output_pdf="$FOLDER/$base.pdf"

  magick "$img" "$output_pdf"
  echo "Converted: $img -> $output_pdf"
done
