import pandas as pd

def prep_krona(input_file, output_file):
    # Read the TSV file
    df = pd.read_csv(input_file, delimiter='\t')

    # Drop the tax_id column
    df = df.drop(columns=['tax_id'])

    # Add prefixes to the taxonomy columns
    df['superkingdom'] = 'k__' + df['superkingdom'].astype(str)
    df['phylum'] = 'p__' + df['phylum'].astype(str)
    df['class'] = 'c__' + df['class'].astype(str)
    df['order'] = 'o__' + df['order'].astype(str)
    df['family'] = 'f__' + df['family'].astype(str)
    df['genus'] = 'g__' + df['genus'].astype(str)
    df['species'] = 's__' + df['species'].astype(str)

    # Reorder the columns
    df = df[['matching_reads', 'superkingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species']]

    # Save the updated TSV file
    df.to_csv(output_file, sep='\t', index=False, header=False)

# Update with your actual file paths
input_file = '/home/arpit/Krona/filtlong_post_processed_barcode15_fastq_rel-abundance.tsv'
output_file = '/home/arpit/Krona/krona_filtered_barcode15.fastq_rel-abundance_13_august.tsv'

prep_krona(input_file, output_file)

