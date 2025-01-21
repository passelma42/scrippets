#!/bin/bash

# Help function
help() {
    echo "Usage: $0 <fasta_file> <sample_sheet>"
    echo
    echo "This script replaces the headers in a FASTA file based on a sample sheet."
    echo
    echo "FASTA file format:"
    echo "  The FASTA file should contain sequences with headers starting with '>' followed by the barcode ID."
    echo "  Example FASTA format:"
    echo "    >barcode01"
    echo "    ATCGGCTAGCTAGCTAGC"
    echo "    >barcode02"
    echo "    GCTAGCTAGCTAGCTAGC"
    echo
    echo "Sample sheet format:"
    echo "  The sample sheet is a CSV file containing two columns: the barcode and the new header."
    echo "  Example CSV format:"
    echo "    barcode01,M24-0025_24PCR-PA-15_01"
    echo "    barcode02,M24-0026_24PCR-PA-15_02"
    echo "    barcode03,M24-0027_24PCR-PA-15_03"
    echo
    echo "Options:"
    echo "  -h, --help  Display this help message"
    echo
    exit 0
}

# Check if help is requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    help
fi

# Check if correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Error: Incorrect number of arguments."
    echo "Usage: $0 <fasta_file> <sample_sheet>"
    exit 1
fi

# Input FASTA file and CSV sample sheet
FASTA_FILE=$1
SAMPLE_SHEET=$2

# Check if the FASTA file and sample sheet exist
if [ ! -f "$FASTA_FILE" ]; then
    echo "Error: FASTA file $FASTA_FILE does not exist."
    exit 1
fi

if [ ! -f "$SAMPLE_SHEET" ]; then
    echo "Error: Sample sheet $SAMPLE_SHEET does not exist."
    exit 1
fi

# Create a temporary mapping file
awk -F, '{print ">" $1 "\t" $2}' "$SAMPLE_SHEET" > barcode_mapping.txt

# Replace the headers in the FASTA file based on the mapping
awk '
NR==FNR {a[$1]=$2; next}
 /^>/ {print ">" a[$1]; next}
 {print}
' barcode_mapping.txt "$FASTA_FILE" > new_fasta_file.fasta

# Cleanup temporary mapping file
rm barcode_mapping.txt

# Notify user of success
echo "Header replacement complete. Output saved to new_fasta_file.fasta"
