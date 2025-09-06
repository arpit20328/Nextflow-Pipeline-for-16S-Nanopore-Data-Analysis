#!/usr/bin/env bash
set -euo pipefail

# Settings
ROOT="<enter your directory where the folder X is present in which .fastq.gz files are present>"
REF_MMI="<location of emu species_species_taxid.fasta.mmi>"
OUTDIR="$PWD"
THREADS=<Enter Threads>

mkdir -p "$OUTDIR"
SUMMARY="$OUTDIR/coverage_summary.tsv"

# Header for summary (TSV)
echo -e "sample\ttotal_reads_millions\tmapped_reads_millions\tmean_depth\tmedian_depth\tmin_depth\tmax_depth\tbreadth_1x\tbreadth_10x" > "$SUMMARY"

# Only process these specific run folders
for run in \
  "sequences" 
do
    RUN_DIR="$ROOT/$run"
    echo "=== Entering $RUN_DIR ==="

    # Find all .fastq.gz in this run
    find "$RUN_DIR" -type f -name "*.fastq.gz" | while read -r fq; do
        sample=$(basename "$fq" .fastq.gz)
        echo "--- Processing $sample ---"

        # Count total reads (lines/4 for FASTQ)
        total_lines=$(zcat "$fq" | wc -l)
        total_reads=$(( total_lines / 4 ))
        total_reads_millions=$(awk -v r="$total_reads" 'BEGIN{printf "%.6f", r/1000000}')

        # Align with minimap2 (ONT preset)
        sorted_bam="$OUTDIR/${sample}.sorted.bam"
        minimap2 -t "$THREADS" -ax map-ont "$REF_MMI" "$fq" \
          | samtools view -b -@ "$THREADS" - \
          | samtools sort -@ "$THREADS" -o "$sorted_bam" -
        samtools index -@ "$THREADS" "$sorted_bam"

        # Count mapped reads
        mapped_reads=$(samtools view -c -F 4 "$sorted_bam")
        mapped_reads_millions=$(awk -v r="$mapped_reads" 'BEGIN{printf "%.6f", r/1000000}')

        # Compute coverage stats (per-base depth)
        depth_file="$OUTDIR/${sample}_depth.txt"
        samtools depth -a "$sorted_bam" > "$depth_file"

        # Mean depth
        mean_depth=$(awk '{sum+=$3; n++} END{ if(n>0) printf "%.4f", sum/n; else print "0.0000"}' "$depth_file")

        # Median depth
        median_depth=$(awk '{print $3}' "$depth_file" | sort -n | awk '{a[NR]=$1} END{ if(NR%2){print a[(NR+1)/2]} else {print (a[NR/2]+a[(NR/2)+1])/2}}')

        # Min and max depth
        min_depth=$(awk 'NR==1{min=$3} {if($3<min) min=$3} END{print min}' "$depth_file")
        max_depth=$(awk 'NR==1{max=$3} {if($3>max) max=$3} END{print max}' "$depth_file")

        # Breadth of coverage
        cov_1x=$(awk '$3>=1{c++} END{if(NR>0) printf "%.4f", c/NR}' "$depth_file")
        cov_10x=$(awk '$3>=10{c++} END{if(NR>0) printf "%.4f", c/NR}' "$depth_file")

        # Append results in TSV
        echo -e "${sample}\t${total_reads_millions}\t${mapped_reads_millions}\t${mean_depth}\t${median_depth}\t${min_depth}\t${max_depth}\t${cov_1x}\t${cov_10x}" >> "$SUMMARY"

        # Cleanup temporary files
        rm -f "$sorted_bam" "$sorted_bam.bai" "$depth_file"

        echo "Done $sample"
    done
done

echo "=== All runs done. Summary: $SUMMARY ==="

