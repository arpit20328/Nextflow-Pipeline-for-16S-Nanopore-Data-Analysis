#!/bin/bash

tsv_file=$1
pdf_file=$2
html_file=$(mktemp --suffix=.html)

echo "<html><head><meta charset='UTF-8'><style>table,th,td { border: 1px solid black; border-collapse: collapse; padding: 5px; }</style></head><body><table>" > "$html_file"

while IFS=$'\t' read -r -a line; do
    echo "<tr>" >> "$html_file"
    for cell in "${line[@]}"; do
        echo "<td>${cell}</td>" >> "$html_file"
    done
    echo "</tr>" >> "$html_file"
done < "$tsv_file"

echo "</table></body></html>" >> "$html_file"

wkhtmltopdf "$html_file" "$pdf_file" > /dev/null 2>&1

rm -f "$html_file"

