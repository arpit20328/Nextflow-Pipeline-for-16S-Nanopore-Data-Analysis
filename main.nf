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
	seqkit sample -n 120000 -j 140  ${params.sequences}/${Sample}.fastq > ${Sample}_subsampled.fastq
	"""
}

process NanoFilt { 
	input:
		tuple val (Sample), file(subsampled_fastq) 
	output:
		tuple val (Sample), file("*_filtered.fastq")
	script:
	"""	
	NanoFilt -q 5 -l 1000 --maxlength 2000  ${subsampled_fastq} > ${Sample}_filtered.fastq
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
	NanoPlot -t 128 --fastq ${filtered_fastq} --N50 -o ${Sample}_NanoPlot_Report
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
	emu abundance --type map-ont ${filtered_fastq} --db /home/arpit --threads 128 --min-abundance 0.0001  --output-dir ${Sample}_emu_results
	sed -i 's/abundance/matching_reads/g' ${Sample}_emu_results/*tsv
	"""
}

process INDEX_CALCULATION {
	publishDir "$PWD/Final_Output/${Sample}/", mode: 'copy', pattern: '*_index.tsv'
	input:
		tuple val (Sample), path(emu_results)
	output:
		tuple val (Sample), file("*_index.tsv")
	script:
	"""
	${params.index_calc} ${emu_results}/*tsv ${Sample}_temp.tsv > ${Sample}_index.tsv
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
	${params.generate_krona_tsv} ${emu_results}/*tsv ${Sample}_krona.tsv
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
	NanoFilt(Subsample.out)
	NanoPlot(NanoFilt.out)
	EMU(NanoFilt.out)
	INDEX_CALCULATION(EMU.out)
	KRONA(EMU.out)
}

workflow.onComplete {
	log.info ( workflow.success ? "\n\nDone! Output in the 'Final_Output' directory \n" : "Oops .. something went wrong" )
}
