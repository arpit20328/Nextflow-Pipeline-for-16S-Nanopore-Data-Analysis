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

   | Tool            | Purpose                                 | Install Guide or Command                                                                          |
| --------------- | --------------------------------------- | ------------------------------------------------------------------------------------------------- |
| **seqkit**      | Subsample FASTQ files                   | `conda install -c bioconda seqkit`                                                                |
| **seqtk**       | Extract sequences from FASTQ            | `conda install -c bioconda seqtk`                                                                 |
| **vsearch**     | Chimera removal                         | `conda install -c bioconda vsearch`                                                               |
| **NanoFilt**    | Read quality and length filtering       | `pip install nanofilt` or `conda install -c bioconda nanofilt`                                    |
| **NanoPlot**    | Read quality plots                      | `pip install nanoplot` or `conda install -c bioconda nanoplot`                                    |
| **EMU**         | Microbial abundance profiling (map-ont) | [`EMU GitHub`](https://github.com/klarman-cell-observatory/emu) (may require manual installation) |
| **R** + Rscript | Generate barplots & tables              | `sudo apt install r-base` or via Conda                                                            |
| **Krona Tools** | Generate interactive taxonomic plots    | `conda install -c bioconda krona`                                                                 |
| **pdfunite**    | Merge PDFs                              | Part of `poppler-utils`: `sudo apt install poppler-utils`                                         |
| **Python 3**    | Used in custom scripts (e.g., KRONA)    | `sudo apt install python3`                                                                        |
| **bash**        | To run shell scripts                    | Typically pre-installed on Linux/macOS                                                            |
| **wkhtmltopdf**        | To convert html to PDF                  | Install TAR from https://wkhtmltopdf.org/downloads.html       


# Working Directory Structure  
Make sure you have this type of structure before running nextflow

![image](https://github.com/user-attachments/assets/d2ed1ff4-c3d2-4ccf-94b8-7b1d6b7e90ed)


# Usage
1. Files in Sequences must be with prefix like "RIF" or "FMT" [RIF for Rifaximin while FMT for Fecal Micriobiota Transplant] eg: RIF_sample.fastq.gz or FMT_samples.fastq.gz
2. Names of the files must be in the samplesheet.csv like "RIF_sample" (without .fastq.gz suffix)
3. Then run bash nextflow.sh > scripts. log 
4. Output will be in Final Output folder
   
# Citation (BibTeX)

@software{mathur_2025_nextflow,
  author       = {Arpit Mathur, Vaibhav Gawde, Rahul Dhargalkar,Nikhil Patkar, Anant Gokarn},
  title        = {Nextflow-Pipeline-for-16S-Nanopore-Data-Analysis},
  year         = {2025},
  version      = {1.0.0},
  url          = {https://github.com/arpit20328/Nextflow-Pipeline-for-16S-Nanopore-Data-Analysis},
  note         = {Accessed: 2025-04-20},
}

# License

This pipeline is based on many open-source tools. Please check the specific licenses of each individual tool.

