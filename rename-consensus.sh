#!/bin/bash

# Get the current working directory
base_dir=$(pwd)

# Iterate over each barcode directory
for dir in barcode*/; do
    # Check if it's a directory
    if [[ -d "$dir" ]]; then
        # Extract the parent directory name, stripping the trailing slash
        parent_name=$(basename "$dir")

        # Construct the path to the consensus.fastq file
        consensus_file="$dir/consensus/consensus.fastq"

        # Check if the consensus file exists
        if [[ -f "$consensus_file" ]]; then
            # Construct the new filename and copy the file
            new_filename="${parent_name}"
            cp "$consensus_file" "$base_dir/${new_filename}.consensus.fastq"

            echo "Copied $consensus_file to $base_dir/$new_filename"
        else
            echo "Warning: $consensus_file does not exist in $dir"
        fi
    else
        echo "Warning: $dir is not a directory"
    fi
done
