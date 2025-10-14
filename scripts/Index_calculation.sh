#!/bin/bash

# Check if input and output file paths are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_file.tsv> <output_file.tsv>"
    exit 1
fi

# Input and output file paths
input_file="$1"
output_file="$2"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' not found!"
    exit 1
fi

# Sort the input file by the second column in descending order
temp_file="${input_file}.tmp"
(head -n 1 "$input_file" && tail -n +2 "$input_file" | sort -t$'\t' -k2,2nr) > "$temp_file" || { echo "Sorting failed!"; exit 1; }
mv "$temp_file" "$input_file"

# Process the sorted input file
awk -F'\t' '
BEGIN { OFS = "\t"; }
NR == 1 {
    print $0, "n_n_1", "pi", "lnpi", "pi_lnpi";
    next;
}
{
    if ($2 == "" || $2 == "NA") next;
    $2 *= 100;
    sum_col2 += $2;
    data[NR] = $0;
}
END {
    for (i in data) {
        split(data[i], row, FS);
        if (row[2] == "" || row[2] == "NA") continue;

        n_n_1 = row[2] * (row[2] - 1);
        sum_n_n_1 += n_n_1;

        pi = row[2] / sum_col2;
        lnpi = (pi > 0) ? log(pi) : 0;
        pi_lnpi = pi * lnpi;
        sum_pi_lnpi += pi_lnpi;

        print row[1], row[2], n_n_1, pi, lnpi, pi_lnpi;
    }

    D = sum_n_n_1 / 9900;
    ISI = 1 / D;
    H = -sum_pi_lnpi;

    print "D\t" D > "'"${output_file}_summary"'";
    print "ISI\t" ISI >> "'"${output_file}_summary"'";
    print "H\t" H >> "'"${output_file}_summary"'";
}' "$input_file" > "$output_file" || { echo "Processing failed!"; exit 1; }

# Check if the output file exists
if [ ! -f "$output_file" ]; then
    echo "Error: Output file not created!"
    exit 1
fi

# Extract summary values
D=$(grep '^D' "${output_file}_summary" | cut -f2)
ISI=$(grep '^ISI' "${output_file}_summary" | cut -f2)
H=$(grep '^H' "${output_file}_summary" | cut -f2)

# Calculate corrected ISI
isi_corrected=$(echo "$ISI * -0.5303 / 100 + $ISI" | bc -l)
h_corrected=$(echo "$H * 1.36 / 100 + $H" | bc -l)
# Calculate alpha diversity
alpha=$(( $(wc -l < "$input_file") - 3 ))

# Print results
echo "Alpha Diversity: $alpha"
echo "Inverse Simpson's Index (ISI): $ISI"
echo "Corrected ISI: $isi_corrected"
echo "Shannon Diversity Index (H): $H"
echo "Corrected Shannon Diversity Index (H): $h_corrected"

echo "Processed file saved to '$output_file'."
