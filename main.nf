#!/usr/bin/env nextflow

// Define the base directory as a parameter that the user can provide
params.basecalled_data = null

// Check if the path is provided by the user
if (params.basecalled_data == null) {
    error "Please provide the path to the barcode directory using --basecalled_data."
}

// Process to merge and decompress FASTQ files
process merged_gunzip {

    input:
    file fastq_files from file("${params.basecalled_data}/*.fastq.gz")

    output:
    file 'merged.fastq' into merged_fastq_channel_1
    file 'merged.fastq' into merged_fastq_channel_2
    file 'merged.fastq' into merged_fastq_channel_3



    script:
    """
    cat $fastq_files > merged_fastq.gz
    gunzip merged_fastq.gz
    mv merged_fastq merged.fastq
    """
}

// Process to run filtlong on the merged FASTQ file
process filtlong {

    input:
    file merged_fastq from merged_fastq_channel_1

    output:
    file 'post_filtlong_merged.fastq' into filtered_fastq_channel_1
    file 'post_filtlong_merged.fastq' into filtered_fastq_channel_2
    file 'post_filtlong_merged.fastq' into filtered_fastq_channel_3

    script:
    """
    filtlong merged.fastq --min_length 1000 --max_length 2000 --min_mean_q 8 > post_filtlong_merged.fastq
    """
}

// Process to run NanoPlot for visualizing the quality of the FASTQ file
process NanoPlot {

    input:
    file filtered_fastq from filtered_fastq_channel_1

    output:
    file 'NanoPlot-output' into nanoplot_channel

    script:
    """
    NanoPlot --fastq post_filtlong_merged.fastq --plots hex -o NanoPlot-output
    """
}

// Process to calculate N50 from the filtered FASTQ file
process N50 {

    input:
    file filtered_fastq from filtered_fastq_channel_2

    output:
    file 'N50_result.txt' into n50_channel

    script:
    """
    awk '{if(NR%4==2) print length(\$0)}' post_filtlong_merged.fastq | \
    sort -nr | \
    awk 'BEGIN {total=0; half=0; sum=0} \
    {lengths[NR]=\$1; total+=\$1} \
    END {half=total/2; for (i=1; i<=NR; i++) {sum+=lengths[i]; if (sum >= half) {print "N50:", lengths[i]; exit}}}' > N50_result.txt
    """
}

// Process to run Emu for abundance estimation
process Emu {

    input:
    file filtered_fastq from filtered_fastq_channel_3

    output:
    file 'emu_abundance.tsv' into emu_channel

    script:
    """
    emu abundance post_filtlong_merged.fastq --type map-ont --db /home/arpit/ --min_abundance 0.0001 --threads 128 > emu_abundance.tsv
    """
}

// Process to replace "abundance" with "matching_reads" and update the Python script
process krona {

    input:
    file emu_abundance from emu_channel

    output:
    file 'krona_filtered_file.tsv' into krona_channel

    script:
    """
    # Replace "abundance" with "matching_reads" in the emu_abundance.tsv file
    sed 's/abundance/matching_reads/g' emu_abundance.tsv > krona_ready.tsv

    # Edit the Python script to update input and output file paths
    sed -i "s|input_file =.*|input_file = 'krona_ready.tsv'|" /home/arpit/Krona/arpit_made_krona_script.py
    sed -i "s|output_file =.*|output_file = 'krona_filtered_file.tsv'|" /home/arpit/Krona/arpit_made_krona_script.py

    # Run the updated Python script
    python3 /home/arpit/Krona/arpit_made_krona_script.py
   
    /home/arpit/Krona/bin/ktImportText -o /home/arpit/Krona/arpit.html /home/arpit/Krona/krona_filtered_file.tsv

     """


}

workflow {
    merged_gunzip()
    filtlong()
    NanoPlot()
    N50()
    Emu()
    krona()
}








#Ecological indexes

#now the tsv file is ready to be attached in R for index calculations

#load R 
#load the tsv file 

