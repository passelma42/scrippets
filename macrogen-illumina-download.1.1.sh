#!/bin/bash

# Function to display help message
help() {
    echo "This script will download your Illumina files based on the md5sum download list"
    echo "found in the Macrogen report. This report is a tab delimited list with the"
    echo "following column headers: File   Size   md5sum   Download_link"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -h, --help           Display this help message"
    echo "  -i, --input FILE     Path to the md5sum download list file"
    echo "  -d, --directory DIR  Directory to store downloaded files"
    exit 0
}

# Parse command line options
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--help) help ;;
        -i|--input) input_file="$2"; shift ;;
        -d|--directory) download_dir="$2"; shift ;;
        *) echo "Unknown option: $1"; help ;;
    esac
    shift
done

# Prompt user if input file or download directory not provided
if [[ -z "$input_file" ]]; then
    read -rp "Enter the path to the md5sum download list file: " input_file
fi

if [[ -z "$download_dir" ]]; then
    read -rp "Enter the directory to store downloaded files: " download_dir
fi

# Create the download directory if it doesn't exist
mkdir -p "$download_dir"

echo "Using input file: $input_file"
echo "Downloading files to: $download_dir"

# Create a temporary file to store download links
download_file=$(mktemp)
awk -F'\t' '{print $4}' "$input_file" | tail -n +2 | tr -d '\r' > "$download_file"

# Create a log file to store MD5 check results
md5_log="$download_dir/md5.out"

# Download files and calculate md5sums
failed_md5sums=0
while read -r link; do
    # Extract file name from the download link
    file=$(basename "$link")
    
    # Download the file
    echo "Downloading $file from $link..."
    wget -q --progress=bar:force "$link" -P "$download_dir"
    
    # Calculate md5sum of the downloaded file
    downloaded_md5sum=$(md5sum "$download_dir/$file" | awk '{print $1}')
    
    # Find md5sum in the input file
    expected_md5sum=$(awk -F'\t' -v f="$file" '$1 == f {print $3}' "$input_file")
    
    # Compare md5sums and write results to md5.out
    if [[ "$downloaded_md5sum" == "$expected_md5sum" ]]; then
        echo "$file  $downloaded_md5sum  OK" >> "$md5_log"
    else
        echo "$file  $downloaded_md5sum  NOK" >> "$md5_log"
        ((failed_md5sums++))
    fi
done < "$download_file"

# Remove the temporary download file
rm "$download_file"

# Print message based on the number of failed MD5 sums
if [[ "$failed_md5sums" -eq 0 ]]; then
    echo "All MD5 sums match."
else
    echo "There were $failed_md5sums files with mismatched MD5 sums."
fi
