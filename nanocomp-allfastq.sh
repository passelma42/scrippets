#!/bin/bash

# Function to display script usage information
display_usage() {
    echo "Usage: $0 [-h] [-d parent_directory] [-f]"
    echo " This script is intended to run NanoComp on fastq.gz files organized in BC folders as output from ONT basecall data."
    echo "Tree topology of parent directory: 
		sequencing@minion:/fastqfolder$ tree
			── barcode01
			│   ├── ASX408_pass_barcode66_61292243_dc2466ae_0.fastq.gz
			│   ├── ASX408_pass_barcode66_61292243_dc2466ae_N.fastq.gz
			│
			├── barcodeNN
			│   ├── ASX408_pass_barcode67_61292243_dc2466ae_0.fastq.gz
			│   ├── ASX408_pass_barcode67_61292243_dc2466ae_N.fastq.gz
			├── nanocomp.sh"
    echo "Options:"
    echo "  -h  Display this help message"
    echo "  -d  Specify the parent directory containing all barcode folders"
    echo "  -c  Clean up the compiled barcodexx.fastq.gz files after running NanoComp. By Default a concatenated barcodexx.fastq.gz file will be created in each barcode folder."
}

# Function to run NanoComp with compiled FASTQ files from each barcode folder
run_nanocomp() {
    local parent_dir="$1"

    # Check if the directory exists
    if [ ! -d "$parent_dir" ]; then
        echo "Error: Directory '$parent_dir' not found."
        exit 1
    fi

    # Initialize arrays to store compiled FASTQ files and barcode names
    compiled_fastq_files=()
    barcode_names=()

    # Loop over each barcode folder in the parent directory
    for barcode_folder in "$parent_dir"/barcode*; do
        # Extract the barcode number from the folder name
        barcode_number=$(basename "$barcode_folder" | sed 's/barcode//')

        # Compile all FASTQ files within the barcode folder into a single FASTQ file
        compiled_fastq="${barcode_folder}/${barcode_folder##*/}.fastq.gz"
        cat "${barcode_folder}"/*.fastq.gz > "$compiled_fastq"

        # Add the compiled FASTQ file to the array
        compiled_fastq_files+=("$compiled_fastq")

        # Add the barcode name to the array
        barcode_names+=("BC$barcode_number")
    done

    # Run NanoComp with the compiled FASTQ files and barcode names
    nano_comp_command="NanoComp --fastq ${compiled_fastq_files[@]} --names ${barcode_names[@]} --outdir $parent_dir/nanocomp.out"

    # Run NanoComp
    echo "Running NanoComp"
    echo "Command: $nano_comp_command"
    $nano_comp_command

    # Optionally, you can print a message indicating completion
    echo "NanoComp completed"

    # Clean up the compiled FASTQ files if -f option is provided
    if [ "$cleanup" == "true" ]; then
        echo "Cleaning up compiled FASTQ files"
        rm -f "${compiled_fastq_files[@]}"
        echo "Cleanup completed"
    fi
}

# Function to clean up compiled FASTQ files
cleanup() {
    echo "Cleaning up compiled FASTQ files"
    rm -c "${compiled_fastq_files[@]}"
    echo "Cleanup completed"
}

# Parse command-line options
while getopts ":hd:c" option; do
    case $option in
        h)
            display_usage
            exit 0
            ;;
        d)
            parent_dir=$OPTARG
            ;;
        c)
            cleanup="true"
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

# Run NanoComp with the provided parent directory argument
run_nanocomp "$parent_dir"

