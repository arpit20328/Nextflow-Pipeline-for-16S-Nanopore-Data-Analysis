#!/usr/bin/env nextflow
nextflow.enable.dsl=2

log.info """
STARTING PIPELINE
=*=*=*=*=*=*=*=*=
Sample list: ${params.input}
Sequences in:${params.sequences}
"""

process Subsample { 
    input:
        val (Sample)
    output:
        tuple val (Sample), file("*_subsampled.fastq")

    script:
    """	
    seqkit sample -n 125000 -j 150 ${params.sequences}/${Sample}.fastq > ${Sample}_subsampled.fastq
    """
}


process Chimera_removal {
    publishDir "$PWD/Final_Output/${Sample}/", mode: 'copy', pattern: "${Sample}_chimera_result.txt"

    input:
        tuple val(Sample), file(subsampled_fastq)

    output:
        tuple val(Sample), file("nonchimeras.fastq")

    script:
    """
    nohup vsearch --uchime_denovo ${subsampled_fastq} \
            --threads 150 \
            --chimeras chimeras.txt \
            --nonchimeras nonchimeras.txt \
            > ${Sample}_chimera_result.txt
     
    grep '^>' nonchimeras.txt | sed 's/>//' > nonchimeras_ids.txt
    seqtk subseq ${subsampled_fastq} nonchimeras_ids.txt > nonchimeras.fastq

   """
}



process NanoFilt { 
    input:
        tuple val(Sample), file(nonchimeras_fastq) 

    output:
        tuple val(Sample), file("*_filtered.fastq")

    script:
    """	
    NanoFilt -q 6 -l 1000 --maxlength 2000 ${nonchimeras_fastq} > ${Sample}_filtered.fastq
    """
}





process NanoPlot {
	publishDir "$PWD/Final_Output/${Sample}/", mode: 'copy', pattern: '*_NanoPlot_Report'
	input:
		tuple val (Sample), file(filtered_fastq) 
	output:
		tuple val (Sample), file("*_NanoPlot_Report")
	script:
	"""	
	NanoPlot -t 150 --fastq ${filtered_fastq} --N50 -o ${Sample}_NanoPlot_Report
	"""
}

process EMU { 
	publishDir "$PWD/Final_Output/${Sample}/", mode: 'copy', pattern: '*_emu_results'
	input:
		tuple val (Sample), file(filtered_fastq) 
	output:
		tuple val (Sample), path("*_emu_results")
	script:
	"""	
	emu abundance --type map-ont ${filtered_fastq} --db /home/arpit --threads 150 --min-abundance 0.0001  --output-dir ${Sample}_emu_results
	sed -i 's/abundance/matching_reads/g' ${Sample}_emu_results/*tsv
	"""
}

process INDEX_CALCULATION {
	publishDir "$PWD/Final_Output/${Sample}/", mode: 'copy', pattern: '*_index.tsv'
	input:
		tuple val(Sample), path(emu_results)
	output:
		tuple val(Sample), file("*_index.tsv")
	script:
	"""
	# Find the appropriate file(s)
	FILE1=${emu_results}/${Sample}_filtered_rel-abundance.tsv
	FILE2=${emu_results}/${Sample}_filtered_rel-abundance-threshold-0.0001.tsv

	if [[ -f "\$FILE2" ]]; then
		echo "Using threshold file: \$FILE2"
		${params.index_calc} "\$FILE2" ${Sample}_temp.tsv > ${Sample}_index.tsv
	else
		echo "Using basic file: \$FILE1"
		${params.index_calc} "\$FILE1" ${Sample}_temp.tsv > ${Sample}_index.tsv
	fi
	"""
}


process KRONA {
	publishDir "$PWD/Final_Output/${Sample}/", mode: 'copy', pattern: '*_krona.html'
	input:
		tuple val (Sample), path(emu_results)
	output:
		tuple val (Sample), file("*_krona.html")
	script:
	"""
	# Find the appropriate file(s)
	FILE1=${emu_results}/${Sample}_filtered_rel-abundance.tsv
	FILE2=${emu_results}/${Sample}_filtered_rel-abundance-threshold-0.0001.tsv

	if [[ -f "\$FILE2" ]]; then
		echo "Using threshold file: \$FILE2"
		python3 ${params.generate_krona_tsv} "\$FILE2" ${Sample}_krona.tsv
	else
		echo "Using basic file: \$FILE1"
		python3 ${params.generate_krona_tsv} "\$FILE1" ${Sample}_krona.tsv
	fi

	${params.generate_krona_plot} ${Sample}_krona.tsv 
	mv text.krona.html ${Sample}_krona.html
	"""
}

workflow NANOPORE_16S {
    Channel
        .fromPath(params.input)
        .splitCsv(header:false)
        .flatten()
        .map{ it }
        .set { samples_ch }

    main:
    Subsample(samples_ch)
    Chimera_removal(Subsample.out)
    NanoFilt(Chimera_removal.out)
    NanoPlot(NanoFilt.out)
    EMU(NanoFilt.out)
    INDEX_CALCULATION(EMU.out)
    KRONA(EMU.out)
}



workflow.onComplete {
	log.info ( workflow.success ? "\n\nDone! Output in the 'Final_Output' directory \n" : "Oops .. something went wrong" )
}
