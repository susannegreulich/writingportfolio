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
    # Extract filename without extension for title
    title="$(basename "${rel_path%.*}")"
    pandoc "$src" --template=template.html --metadata title="$title" --toc -o "$out_path"
    echo "Converted $src -> $out_path"
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
    <link rel="stylesheet" href="/css/style.css">
</head>
<body class="articles-page">
    <header>
        <div class="articles-topbar">
            <a href="/index.html" class="site-title">Home</a>
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

for file in "$WRITINGS_DIR"/*.html; do
    fname=$(basename "$file")
    [ "$fname" = "index.html" ] && continue
    title="${fname%.html}"
    echo "                <li style=\"margin-bottom:2.5rem;\"><a href=\"$fname\" style=\"font-size:1.5rem; font-weight:600; color:var(--primary-text); text-decoration:none;\">$title</a></li>" >> "$INDEX_FILE"
done

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