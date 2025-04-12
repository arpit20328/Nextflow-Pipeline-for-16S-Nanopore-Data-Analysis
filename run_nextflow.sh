#!/usr/bin/bash

nextflow -c /home/arpit/nextflow_16s/new_pipeline/nextflow.config run main.nf -entry NANOPORE_16S \
--sequences /home/arpit/nextflow_16s/new_pipeline/sequences/ \
--input /home/arpit/nextflow_16s/new_pipeline/samplesheet.csv \
-resume -bg
