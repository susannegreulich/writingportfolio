#!/usr/bin/env bash

# Exit on error
set -e

# Create public directory if it doesn't exist
mkdir -p public

# Loop over supported file types
for ext in md odt pdf; do
  # Find all files with the current extension in source/ (recursively)
  find source -type f -name "*.${ext}" | while read -r src; do
    # Get the path relative to source/
    rel_path="${src#source/}"
    # Remove extension and add .html
    out_path="public/${rel_path%.*}.html"
    # Create the output directory if it doesn't exist
    mkdir -p "$(dirname "$out_path")"
    pandoc "$src" -o "$out_path"
    echo "Converted $src -> $out_path"
    # Delete the original source file
    rm "$src"
    echo "Deleted source file $src"
  done
done 