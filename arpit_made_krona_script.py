import pandas as pd
import sys

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

if __name__ == "__main__":
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    prep_krona(input_file, output_file)
