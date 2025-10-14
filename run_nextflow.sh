#!/usr/bin/bash

nextflow -c /home/arpit/arpit_data/nextflow_rifaximin_pipleine/nextflow.config run main.nf -entry NANOPORE_16S \
--sequences /home/arpit/arpit_data/nextflow_rifaximin_pipleine/sequences/ \
--input /home/arpit/arpit_data/nextflow_rifaximin_pipleine/samplesheet.csv \
-resume -bg
