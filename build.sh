#!/usr/bin/env bash

# Exit on error
set -e

# Create public directory if it doesn't exist
mkdir -p public
mkdir -p public/images

# Loop over supported file types
for ext in md odt pdf docx; do
  # Find all files with the current extension in source/ (recursively)
  find source -type f -name "*.${ext}" | while read -r src; do
    # Get the path relative to source/
    rel_path="${src#source/}"
    # Remove extension and add .html
    out_path="public/${rel_path%.*}.html"
    # Create the output directory if it doesn't exist
    mkdir -p "$(dirname "$out_path")"
    
    # Calculate relative path to the root of the 'public' directory
    # This is needed for links to CSS, JS, etc. to work from nested pages.
    rel_path_no_ext="${rel_path%.*}"
    # A more robust way to count slashes to determine directory depth
    temp=${rel_path_no_ext//[^\/]/}
    depth=${#temp}
    pathtoroot=""
    for ((i=0; i<depth; i++)); do
        pathtoroot+="../"
    done

    # Extract the first heading from the document to use as title
    # Convert to markdown and take the first line as the title
    first_heading=$(pandoc "$src" --to=markdown | head -1)
    
    # Remove pandoc's escaping of apostrophes and anchor tags
    title=$(echo "$first_heading" | sed -e "s/\\\\'/'/g" -e 's/\[\]{#anchor[^}]*}//g' -e 's/\\//g')
    
    # If no heading found or it's empty, use filename as fallback
    if [ -z "$title" ]; then
        title="$(basename "${rel_path%.*}")"
    fi
    
    # Create a temporary directory for extracted images
    temp_img_dir=$(mktemp -d)
    
    # Convert to HTML with image extraction
    # --extract-media extracts images to the specified directory
    # --variable=pathtoroot sets the path to root for CSS/JS links
    pandoc "$src" \
        --template=template.html \
        --metadata title="$title" \
        --toc \
        --extract-media="$temp_img_dir" \
        --variable="pathtoroot:${pathtoroot}" \
        -o "$out_path"
    
    # Move extracted images to public/images and update HTML
    if [ -d "$temp_img_dir/media" ]; then
        # Find all image files in the extracted media directory
        find "$temp_img_dir/media" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.svg" -o -name "*.webp" \) | while read -r img_file; do
            # Get the filename
            img_name=$(basename "$img_file")
            # Move to public/images
            mv "$img_file" "public/images/$img_name"
            
            # Update the HTML file to reference the correct image path
            # Replace various possible path formats with the correct relative path
            sed -i "s|src=\"media/$img_name\"|src=\"${pathtoroot}images/$img_name\"|g" "$out_path"
            sed -i "s|src=\"$img_name\"|src=\"${pathtoroot}images/$img_name\"|g" "$out_path"
            # Handle absolute paths to temp directory
            sed -i "s|src=\"$temp_img_dir/media/$img_name\"|src=\"${pathtoroot}images/$img_name\"|g" "$out_path"
        done
    fi
    
    # Also check for Pictures directory (common in ODT files)
    if [ -d "$temp_img_dir/Pictures" ]; then
        # Find all image files in the extracted Pictures directory
        find "$temp_img_dir/Pictures" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.svg" -o -name "*.webp" \) | while read -r img_file; do
            # Get the filename
            img_name=$(basename "$img_file")
            # Move to public/images
            mv "$img_file" "public/images/$img_name"
            
            # Update the HTML file to reference the correct image path
            # Replace various possible path formats with the correct relative path
            sed -i "s|src=\"Pictures/$img_name\"|src=\"${pathtoroot}images/$img_name\"|g" "$out_path"
            sed -i "s|src=\"$img_name\"|src=\"${pathtoroot}images/$img_name\"|g" "$out_path"
            # Handle absolute paths to temp directory
            sed -i "s|src=\"$temp_img_dir/Pictures/$img_name\"|src=\"${pathtoroot}images/$img_name\"|g" "$out_path"
        done
    fi
    
    # Clean up temporary directory
    rm -rf "$temp_img_dir"
    
    echo "Converted $src -> $out_path (Title: $title)"
  done
done

# Generate index.html for writings
WRITINGS_DIR="public/writings"
INDEX_FILE="$WRITINGS_DIR/index.html"

cat > "$INDEX_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Writings</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body class="articles-page">
    <header>
        <div class="header-container">
            <nav>
                <a href="../index.html" class="site-title">Home</a>
            </nav>
        </div>
        <div class="articles-title">
            <h1>Writings</h1>
        </div>
    </header>
    <main>
        <div class="main-content">
            <ul style="list-style:none; padding:0;">
EOF

# Create a temporary file to store title-filename pairs
TEMP_FILE=$(mktemp)
# Create a temporary pandoc template to extract titles
TITLE_TPL=$(mktemp)
echo '$title$' > "$TITLE_TPL"

# Extract titles and filenames, then sort by title
find "$WRITINGS_DIR" -maxdepth 1 -name "*.html" -not -name "index.html" | while read -r file; do
    fname=$(basename "$file")
    
    # Use pandoc to reliably extract the title from the HTML file
    # and then remove newlines to handle multi-line titles
    title=$(pandoc "$file" --template="$TITLE_TPL" | tr '\n' ' ' | sed 's/&#8288;/ /g')
    
    # If title extraction failed, fall back to filename
    if [ -z "$title" ]; then
        title="${fname%.html}"
    fi
    
    # Store title and filename in temp file
    echo "$title|$fname" >> "$TEMP_FILE"
done

# Clean up the temporary template
rm "$TITLE_TPL"

# Sort by title and generate HTML
if [ -f "$TEMP_FILE" ]; then
    sort "$TEMP_FILE" | while IFS='|' read -r title fname; do
        echo "                <li style=\"margin-bottom:2.5rem;\"><a href=\"$fname\" style=\"font-size:1.5rem; font-weight:600; color:var(--primary-text); text-decoration:none;\">$title</a></li>" >> "$INDEX_FILE"
    done
    rm "$TEMP_FILE"
fi

cat >> "$INDEX_FILE" <<EOF
            </ul>
        </div>
    </main>
    <footer>
        <p>&copy; <span id="copyright-year"></span> Susanne Greulich. All rights reserved.</p>
    </footer>
    <script>
    document.getElementById('copyright-year').textContent = new Date().getFullYear();
    </script>
</body>
</html>
EOF