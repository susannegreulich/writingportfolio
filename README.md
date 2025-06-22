A static website generator that converts academic documents (ODT, DOCX, PDF, MD) to HTML using Pandoc, creating a clean, responsive writing portfolio.

## Overview

This project automatically converts source documents in the `source/` directory to HTML files in the `public/` directory, maintaining the original folder structure. It's designed for efficient content management - once documents are converted, source files can be deleted while keeping the generated HTML files.

## Features

- **Multi-format Support**: Converts ODT, DOCX, PDF, and Markdown files to HTML
- **Automatic Image Extraction**: Extracts and properly links images from documents
- **Table of Contents**: Generates navigation TOC for each document
- **Responsive Design**: Clean, modern styling with mobile-friendly layout
- **Incremental Builds**: Only converts new/changed files, preserving existing HTML
- **Auto-generated Index**: Creates an alphabetically sorted index of all writings

## Structure

```
Site_Pandoc/
├── source/          # Source documents (ODT, DOCX, PDF, MD)
├── public/          # Generated HTML website
├── template.html    # HTML template for converted documents
└── build.sh         # Build script
```

## Usage

1. Place your source documents in the `source/` directory (maintain subdirectories as needed)
2. Run the build script:
   ```bash
   ./build.sh
   ```
3. The generated website will be in the `public/` directory
4. Serve the `public/` directory with any web server

## Requirements

- Pandoc
- Bash shell
- Standard Unix tools (find, sed, etc.)

## Deployment

The `public/` directory contains a complete static website that can be deployed to any web hosting service (GitHub Pages, Netlify, Vercel, etc.).









My notes to self on efficient build:

'settings' files, ie files that aren't new posts to be added, but rather timeless enduring settings that apply to
these posts, should be added directly to the public folder, and not included in the build process. the build process
should only apply to content that you ADD to your website over time. redundant to re-convert the same default settings
to html every time. Examples of such default settings pages are:
- landing page, it is customized and 'timeless'. so directly as html in public folder.
- css formatting


configure build.sh in a way that organizes the converted source files in the public folder in the same way as the source folder.
so for example when converting source/articles/equalityofopportunity.md, the converted file should be placed in public/articles/equalityofopportunity.html . 


also configure to delete the original source files once converted to html, and to KEEP ALL converted html files even
after the source files are deleted. This way, every build only builds the new content, and doesn't need to re-convert old
content. 


but how do i serve this website online, when packages like pandoc and python are being used?

tested. this workflow keeps old htmls when generating new ones. ie i don't have to keep the source files for EVERY desired html file, 
and reconvert everytime. i can just delete old source files, and add new source files and convert only these to html, adding to the
existing stock of htmls. 