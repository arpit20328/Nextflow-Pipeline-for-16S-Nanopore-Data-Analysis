# Nextflow Pipeline-for-16S-Nanopore-Data-Analysis

This is basic nextlfow pipeline for analyzing 16S Nanopore fastq files with help of tools like filtlong, NanoPlot, Emu, Krona Plot. Scipts also calculates ecological indexes from output emu abundance table.

# Pipeline Structure 

![image](https://github.com/user-attachments/assets/1133a9d0-53f4-40bf-89db-70b2b171686e)

# Patient Report

![image](https://github.com/user-attachments/assets/f1d41190-b4e2-4ec8-808b-65410b51ebd5)

# Pre requisites:  

1.  Emu: species-level taxonomic abundance for full-length 16S reads
    https://github.com/treangenlab/emu.git

    default: Default Database files available at https://osf.io/56uf7/ "see the files under the header emu-default-db-input" 

2.  NanoFilt: NanoFilt is a tool for filtering long reads by quality. It can take a set of long reads and produce a smaller, better subset. It uses both read length (longer 
    is better) and read identity (higher is better) when choosing which reads pass the filter.
    https://github.com/wdecoster/nanofilt

3.  NanoPlot: Plotting tool for long read sequencing data and alignments.
    https://github.com/wdecoster/NanoPlot

   -basic conda installation
   -python3 lastest version installed
   -numpy python library installed
   -R.4+ version installed 
   -gunzip installed

# Working Directory Structure  
Make sure you have this type of structure before running nextflow

![image](https://github.com/user-attachments/assets/d2ed1ff4-c3d2-4ccf-94b8-7b1d6b7e90ed)


# Usage

bash nextflow.sh > scripts. log 

# Citation (BibTeX)

@software{mathur_2025_nextflow,
  author       = {Arpit Mathur, Vaibhav Gawde},
  title        = {Nextflow-Pipeline-for-16S-Nanopore-Data-Analysis},
  year         = {2025},
  version      = {1.0.0},
  url          = {https://github.com/arpit20328/Nextflow-Pipeline-for-16S-Nanopore-Data-Analysis},
  note         = {Accessed: 2025-04-20},
}

# License

This pipeline is based on many open-source tools. Please check the specific licenses of each individual tool.

