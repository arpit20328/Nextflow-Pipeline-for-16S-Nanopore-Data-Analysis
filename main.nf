#!/usr/bin/env nextflow


params.input = "input.fastq"

params.db = "/home/arpit"

params.index_script = "Index_calculation.sh"

params.krona_script = "arpit_made_krona_script.py"


workflow {


    Channel.fromPath(params.input)

        .set { input_fastq }


    process_subsample(input_fastq)

        .set { subsampled_fastq }


    process_nanofilt(subsampled_fastq)

        .set { filtered_fastq }


    process_nanoplot(filtered_fastq)


    process_emu(filtered_fastq)

        .set { emu_tsv }


    process_index_calc(emu_tsv)


    process_krona(emu_tsv)

}


// Subsample with seqkit

process process_subsample {


    input:

    path input_file


    output:

    path "subsampled_output.fastq"


    script:

    """

    seqkit sample -n 120000 -j 140 ${input_file} > subsampled_output.fastq

    """

}


// Quality filter with NanoFilt

process process_nanofilt {


    input:

    path subsampled


    output:

    path "output.fastq"


    script:

    """

    NanoFilt -q 5 -l 500 --maxlength 2000 ${subsampled} > output.fastq

    """

}


// NanoPlot visualization

process process_nanoplot {


    input:

    path fastq_file


    output:

    path "NanoPlot_Report"


    script:

    """

    NanoPlot -t 120 --fastq ${fastq_file} --plots hex dot --N50 -o NanoPlot_Report

    """

}


// Emu abundance estimation

process process_emu {


    input:

    path filtered


    output:

    path "emu_results/*.tsv"


    script:

    """

    emu abundance --type map-ont ${filtered} --db ${params.db} --threads 140 --min-abundance 0.0001 --output-dir emu_results

    """

}


// Ecological index calculation

process process_index_calc {


    input:

    path tsv_files


    output:

    path "emu_results/Ecological_index_results.txt"


    script:

    """

    cd emu_results

    bash ../${params.index_script} *.tsv > Ecological_index_results.txt

    """

}


// Krona chart generation

process process_krona {


    input:

    path tsv_files


    output:

    path "krona_filtered_file.tsv"


    script:

    """

    cd emu_results

    python3 ../${params.krona_script} *.tsv

    """

}

