#!/bin/bash

# Usage: ./html_to_jpg_converter.sh input.html output.jpg

# Check for two arguments
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <input.html> <output.pdf>"
    exit 1
fi

input_html="$1"
output_pdf="$2"

# Run wkhtmltoimage
wkhtmltopdf "$input_html" "$output_pdf" 

