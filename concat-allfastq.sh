#!/bin/bash

# Function to display script usage information
display_usage() {
    echo "Usage: $0 [-h] [-d parent_directory]"
    echo " This script is intended to concatenate fastq.gz files organized in BC folders."
    echo "Tree topology of parent directory: 
		sequencing@minion:/fastqfolder$ tree
			── barcode01
			│   ├── ASX408_pass_barcode66_61292243_dc2466ae_0.fastq.gz
			│   ├── ASX408_pass_barcode66_61292243_dc2466ae_N.fastq.gz
			│
			├── barcodeNN
			│   ├── ASX408_pass_barcode67_61292243_dc2466ae_0.fastq.gz
			│   ├── ASX408_pass_barcode67_61292243_dc2466ae_N.fastq.gz"
    echo "Options:"
    echo "  -h  Display this help message"
    echo "  -d  Specify the parent directory containing all barcode folders"
}

# Function to concatenate fastq.gz files in each barcode folder
concatenate_fastq() {
    local parent_dir="$1"

    # Check if the directory exists
    if [ ! -d "$parent_dir" ]; then
        echo "Error: Directory '$parent_dir' not found."
        exit 1
    fi

    # Loop over each barcode folder in the parent directory
    for barcode_folder in "$parent_dir"/barcode*; do
        # Concatenate all FASTQ files within the barcode folder into a single FASTQ file
        concatenated_fastq="${barcode_folder}/${barcode_folder##*/}.fastq.gz"
        cat "${barcode_folder}"/*.fastq.gz > "$concatenated_fastq"
        echo "Concatenated files for barcode: ${barcode_folder##*/}"
    done
}

# Parse command-line options
while getopts ":hd:" option; do
    case $option in
        h)
            display_usage
            exit 0
            ;;
        d)
            parent_dir=$OPTARG
            ;;
        \?)
            echo "Error: Invalid option -$OPTARG" >&2
            display_usage
            exit 1
            ;;
        :)
            echo "Error: Option -$OPTARG requires an argument" >&2
            display_usage
            exit 1
            ;;
    esac
done

# If no option is provided or -d option is missing an argument
if [ $OPTIND -eq 1 ] || [ -z "$parent_dir" ]; then
    echo "Error: Missing argument for -d option" >&2
    display_usage
    exit 1
fi

# Concatenate fastq.gz files in the provided parent directory
concatenate_fastq "$parent_dir"
