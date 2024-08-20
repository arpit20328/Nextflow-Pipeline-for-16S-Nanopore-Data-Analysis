  #! /usr/bin/env nextflow



basecalled_data= /path/to/barcode04/ 


 
cd basecalled_data

cat   *.fastq.gz > merged_fastq.gz

gunzip merged_fastq.gz  

#generaion of merged.fastq


#filtlong



filtlong merged.fastq --min_length 1000 --max_length 2000 --min_mean_q 8 > post_filtlong_merged.fastq


Nanoplot --fastq post_filtlong_merged.fastq  --plots hex  


#NanoPlots are generated


#N50 calculation

awk '{if(NR%4==2) print length($0)}' post_filtlong_merged.fastq | sort -nr | awk 'BEGIN {total=0; half=0; sum=0} {lengths[NR]=$1; total+=$1} END {half=total/2; for (i=1; i<=NR; i++) {sum+=lengths[i]; if (sum >= half) {print "N50:", lengths[i]; exit}}}'




#Emu table generation


emu abundance post_filtlong_merged.fastq --type map-ont --db /home/arpit/   --min_abundance 0.0001 --threads 128  

#results of emu will be in folder results
#folder results/*.tsv  $only 1 tsv file 

#Krona plot generation

#(change “abundance” to “matching_reads” in this tsv file)

#edit the input and output paths in the /home/arpit/Krona/arpit_made_krona_script.py


python3 /home/arpit/Krona/arpit_made_krona_script.py

/home/arpit/Krona/bin/ktImportText -o /home/arpit/Krona/arpit.html /home/arpit/Krona/krona_filtered_barcode15.fastq_rel-abundance.tsv

#arpit.html will be the krona plot link





#Ecological indexes

#now the tsv file is ready to be attached in R for index calculations

#load R 
#load the tsv file 

/*
 * Define the workflow
 */
workflow {
    filtlong(params.in) \
      | N50 \
      | NanoPlot \ 
      | Emu \
      | Krona \
      | Ecological_index \

}
