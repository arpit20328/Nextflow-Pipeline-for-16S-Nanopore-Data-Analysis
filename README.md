# Nextflow Pipeline-for-16S-Nanopore-Data-Analysis built by Mr Arpit Mathur

This is basic nextlfow pipeline for analyzing 16S Nanopore fastq files with help of tools like filtlong, NanoPlot, Emu, Krona Plot. Scipts also calculates ecological indexes from output emu abundance table.

Pre requisites:  

1.  Emu: species-level taxonomic abundance for full-length 16S reads
    https://github.com/treangenlab/emu.git

    default: Default Database files available at https://osf.io/56uf7/ "see the files under the header emu-default-db-input" 

2.  Filtlong: Filtlong is a tool for filtering long reads by quality. It can take a set of long reads and produce a smaller, better subset. It uses both read length (longer 
    is better) and read identity (higher is better) when choosing which reads pass the filter.
    https://github.com/rrwick/Filtlong

3.  NanoPlot: Plotting tool for long read sequencing data and alignments.
    https://github.com/wdecoster/NanoPlot

   -basic conda installation
   -python3 lastest version installed
   -numpy python library installed
   -R.4+ version installed 
   -gunzip installed


   ![image](https://github.com/user-attachments/assets/ac579edb-fbc3-4ec4-b95b-bcaa8358f5e8)

