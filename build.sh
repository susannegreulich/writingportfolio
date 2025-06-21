#!/usr/bin/env bash

# Exit on error
set -e

# Create public directory if it doesn't exist
mkdir -p public

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
    
    # Convert to HTML with the extracted title and correct path to root
    pandoc "$src" --template=template.html --metadata title="$title" --toc --variable="pathtoroot:${pathtoroot}" -o "$out_path"
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
        <div class="articles-topbar">
            <a href="../index.html" class="site-title">Home</a>
            <nav class="articles-nav"></nav>
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

# Extract titles and filenames, then sort by title
find "$WRITINGS_DIR" -maxdepth 1 -name "*.html" -not -name "index.html" | while read -r file; do
    fname=$(basename "$file")
    
    # Use a highly robust awk command to extract the title, handling multi-line cases
    title=$(awk -v RS='</title>' -v FS='<title>' 'NF>1{print $2; exit}' "$file" | sed 's/&#8288;/ /g')
    
    # If title extraction failed, fall back to filename
    if [ -z "$title" ]; then
        title="${fname%.html}"
    fi
    
    # Store title and filename in temp file
    echo "$title|$fname" >> "$TEMP_FILE"
done

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