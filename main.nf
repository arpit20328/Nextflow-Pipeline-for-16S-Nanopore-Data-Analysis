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
    publishDir "$PWD/Final_Output/${Sample}/", mode: 'copy'

    input:
        tuple val(Sample), file(subsampled_fastq)

    output:
        tuple val(Sample), file("nonchimeras.fastq"), file("${Sample}_chimera_result.txt")

    script:
    """
    nohup vsearch --uchime_denovo ${subsampled_fastq} --chimeras chimeras.txt --nonchimeras nonchimeras.txt > ${Sample}_chimera_result.txt 2>&1 
    grep '^>' nonchimeras.txt | sed 's/>//' > nonchimeras_ids.txt
    seqtk subseq ${subsampled_fastq} nonchimeras_ids.txt > nonchimeras.fastq
    """
}

process NanoFilt { 
    input:
        tuple val(Sample), file(nonchimeras_fastq), file(chimera_result) 

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
		tuple val (Sample), path("*_NanoPlot_Report")
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

process BARPLOT_TABLE_EMU {
	publishDir "$PWD/Final_Output/${Sample}/", mode: 'copy', pattern: '*.pdf'
	publishDir "$PWD/Final_Output/${Sample}/", mode: 'copy', pattern: '*.tsv'
	input:
		tuple val (Sample), path(emu_results)
	output:
		tuple val (Sample), file("Top 25 Microbial Species Barplot.pdf"), file("Published_EMU_table.tsv")
	script:
	"""
	# Find the appropriate file(s)
	FILE1=${emu_results}/${Sample}_filtered_rel-abundance.tsv
	FILE2=${emu_results}/${Sample}_filtered_rel-abundance-threshold-0.0001.tsv

	if [[ -f "\$FILE2" ]]; then
		echo "Using threshold file: \$FILE2"
		Rscript ${params.barplot_table_emu} "\$FILE2"
	else
		echo "Using basic file: \$FILE1"
		Rscript ${params.barplot_table_emu} "\$FILE1"
	fi
	"""		
}


process Patient_report {

	//errorStrategy 'ignore'
    publishDir "$PWD/Final_Output/${Sample}/", mode: 'copy', pattern: "${Sample}_patient_report.pdf"

    input:
        tuple val(Sample), file(index_tsv), file(barplot_pdf), file(barplot_tsv), path(nanoplot_dir)

    output:
        tuple val(Sample), file("${Sample}_patient_report.pdf")

    script:
    """
    # Convert TSVs to PDFs
    bash /home/arpit/nextflow_16s/new_pipeline/scripts/tsv_pdf.sh ${index_tsv} ${Sample}_index.pdf
    bash /home/arpit/nextflow_16s/new_pipeline/scripts/tsv_pdf.sh ${barplot_tsv} ${Sample}_emu_table.pdf

    # Convert HTML to PDF
    bash /home/arpit/nextflow_16s/new_pipeline/scripts/html_to_pdf.sh ${nanoplot_dir}/NanoPlot-report.html ${Sample}_nanoplot.pdf || true

	bash /home/arpit/nextflow_16s/new_pipeline/scripts/png_to_pdf.sh ${nanoplot_dir}
    # Merge all PDFs
    
	
    if [[ "${Sample}" == FMT* ]]; then
        pdfunite \\
            ${params.fmt_pdf} \\
            ${Sample}_index.pdf \\
            ${Sample}_emu_table.pdf \\
            ${barplot_pdf} \\
            ${params.wetlab_pdf} \\
            ${Sample}_nanoplot.pdf \\
            ${nanoplot_dir}/*.pdf \\
            ${Sample}_patient_report.pdf

    elif [[ "${Sample}" == RIF* ]]; then
        pdfunite \\
            ${params.rif_pdf} \\
            ${Sample}_index.pdf \\
            ${Sample}_emu_table.pdf \\
            ${barplot_pdf} \\
            ${params.wetlab_pdf} \\
            ${Sample}_nanoplot.pdf \\
            ${nanoplot_dir}/*.pdf \\
            ${Sample}_patient_report.pdf
    else
        echo "Sample name must start with FMT or RIF" >&2
        exit 1
    fi
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
	BARPLOT_TABLE_EMU(EMU.out)
    INDEX_CALCULATION(EMU.out)
    KRONA(EMU.out)	
	Patient_report(INDEX_CALCULATION.out.join(BARPLOT_TABLE_EMU.out.join(NanoPlot.out)))
}

	


workflow.onComplete {
	log.info ( workflow.success ? "\n\nDone! Output in the 'Final_Output' directory \n" : "Oops .. something went wrong" )
}
