#!/usr/bin/env bash
set -euo pipefail

# Usage: coverage.sh <FASTQ> <OUTPUT_TSV> <THREADS>

FASTQ=$1
OUT_TSV=$2
THREADS=$3

REF_MMI="/goast/arpit_data/nextflow_rifaximin_pipleine/emu_database/species_species_taxid.fasta.mmi"

sample=$(basename "$FASTQ" .fastq)

# Header (create new TSV or overwrite existing)
echo -e "sample\ttotal_reads_millions\tmapped_reads_millions\tmean_depth\tmedian_depth\tmin_depth\tmax_depth\tbreadth_1x\tbreadth_10x" > "$OUT_TSV"

# --------------------------------------------------------
# 1. Count total reads (FASTQ only, no gzip)
# --------------------------------------------------------
total_reads=$(awk 'NR % 4 == 1' "$FASTQ" | wc -l)
total_reads_millions=$(awk -v r="$total_reads" 'BEGIN{printf "%.6f", r/1000000}')

# --------------------------------------------------------
# 2. Align reads using minimap2 and sort BAM
# --------------------------------------------------------
sorted_bam="${sample}.sorted.bam"
minimap2 -t "$THREADS" -ax map-ont "$REF_MMI" "$FASTQ" | \
    samtools view -b -@ "$THREADS" - | \
    samtools sort -@ "$THREADS" -o "$sorted_bam" -
samtools index "$sorted_bam"

# --------------------------------------------------------
# 3. Compute per-base depth
# --------------------------------------------------------
depth_file="${sample}_depth.txt"
samtools depth -a "$sorted_bam" > "$depth_file"

# --------------------------------------------------------
# 4. Calculate coverage metrics
# --------------------------------------------------------
mean_depth=$(awk '{sum+=$3; n++} END{if(n>0) printf "%.4f", sum/n; else print "0.0000"}' "$depth_file")
median_depth=$(awk '{print $3}' "$depth_file" | sort -n | awk '{a[NR]=$1} END{if(NR%2){print a[(NR+1)/2]} else {print (a[NR/2]+a[(NR/2)+1])/2}}')
min_depth=$(awk 'NR==1{min=$3} {if($3<min) min=$3} END{print min}' "$depth_file")
max_depth=$(awk 'NR==1{max=$3} {if($3>max) max=$3} END{print max}' "$depth_file")
cov_1x=$(awk '$3>=1{c++} END{if(NR>0) printf "%.4f", c/NR}' "$depth_file")
cov_10x=$(awk '$3>=10{c++} END{if(NR>0) printf "%.4f", c/NR}' "$depth_file")

# --------------------------------------------------------
# 5. Write summary line to output TSV
# --------------------------------------------------------
echo -e "${sample}\t${total_reads_millions}\tNA\t${mean_depth}\t${median_depth}\t${min_depth}\t${max_depth}\t${cov_1x}\t${cov_10x}" >> "$OUT_TSV"

