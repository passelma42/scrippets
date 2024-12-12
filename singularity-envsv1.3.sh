#!/bin/bash

# RUNNING epi2melabs on HPC

# Function to display help message
show_help() {
  echo "Usage: $0 -u <user> [--default] [--cache-dir <path>] [--temp-dir <path>] [--images-dir <path>]"
  echo
  echo "Options:"
  echo "  -u <user>          Specify the user identifier."
  echo "  --default          Run in default mode with predefined directory structure."
  echo "  --cache-dir <path> Specify a custom cache directory."
  echo "  --temp-dir <path>  Specify a custom temporary directory."
  echo "  --images-dir <path> Specify a custom images directory."
  echo "  --help             Display this help message and exit."
  echo
  echo "This script sets up the following directories and environment variables:"
  echo "  Directories (default mode):"
  echo "    - SINGULARITY_CACHEDIR_DIR: /scratch/gent/433/<user>/singularity/cache"
  echo "    - SINGULARITY_TMPDIR_DIR: /scratch/gent/433/<user>/singularity/temp"
  echo "    - NXF_SINGULARITY_CACHEDIR_DIR: /scratch/gent/433/<user>/singularity/images"
  echo "  Environment Variables:"
  echo "    - SINGULARITY_CACHEDIR"
  echo "    - SINGULARITY_TMPDIR"
  echo "    - NXF_SINGULARITY_CACHEDIR"
}

# Default values
DEFAULT_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -u)
      USER=$2
      shift 2
      ;;
    --default)
      DEFAULT_MODE=true
      shift
      ;;
    --cache-dir)
      SINGULARITY_CACHEDIR_DIR=$2
      shift 2
      ;;
    --temp-dir)
      SINGULARITY_TMPDIR_DIR=$2
      shift 2
      ;;
    --images-dir)
      NXF_SINGULARITY_CACHEDIR_DIR=$2
      shift 2
      ;;
    --help)
      show_help
      exit 0
      ;;
    *)
      echo "Invalid option: $1"
      show_help
      exit 1
      ;;
  esac
done

# Check if USER is set
if [ -z "$USER" ]; then
  echo "Error: USER is not set. Use the -u flag to specify the user."
  exit 1
fi

# Set default directories if running in default mode
if [ "$DEFAULT_MODE" = true ]; then
  SINGULARITY_CACHEDIR_DIR=/scratch/gent/433/$USER/singularity/cache
  SINGULARITY_TMPDIR_DIR=/scratch/gent/433/$USER/singularity/temp
  NXF_SINGULARITY_CACHEDIR_DIR=/scratch/gent/433/$USER/singularity/images
fi

# Check if directories are defined
if [ -z "$SINGULARITY_CACHEDIR_DIR" ] || [ -z "$SINGULARITY_TMPDIR_DIR" ] || [ -z "$NXF_SINGULARITY_CACHEDIR_DIR" ]; then
  echo "Error: One or more directories are not set. Use --default or specify all directories manually."
  exit 1
fi

# Create directories if they do not already exist
echo "Creating directories..."
if [ ! -d "$SINGULARITY_CACHEDIR_DIR" ]; then
    echo "Creating cache directory: $SINGULARITY_CACHEDIR_DIR"
    mkdir -p "$SINGULARITY_CACHEDIR_DIR"
fi

if [ ! -d "$SINGULARITY_TMPDIR_DIR" ]; then
    echo "Creating temporary directory: $SINGULARITY_TMPDIR_DIR"
    mkdir -p "$SINGULARITY_TMPDIR_DIR"
fi

if [ ! -d "$NXF_SINGULARITY_CACHEDIR_DIR" ]; then
    echo "Creating images directory: $NXF_SINGULARITY_CACHEDIR_DIR"
    mkdir -p "$NXF_SINGULARITY_CACHEDIR_DIR"
fi

# Export environment variables
echo "Setting environment variables..."
export SINGULARITY_CACHEDIR="$SINGULARITY_CACHEDIR_DIR"
export SINGULARITY_TMPDIR="$SINGULARITY_TMPDIR_DIR"
export NXF_SINGULARITY_CACHEDIR="$NXF_SINGULARITY_CACHEDIR_DIR"

# Set permissions after directories exist
echo "Setting permissions for directories..."
chmod -R 777 "$SINGULARITY_CACHEDIR_DIR"
chmod -R 777 "$SINGULARITY_TMPDIR_DIR"
chmod -R 777 "$NXF_SINGULARITY_CACHEDIR_DIR"

# Display the values to confirm
echo "Environment setup complete."
echo "SINGULARITY_CACHEDIR=$SINGULARITY_CACHEDIR"
echo "SINGULARITY_TMPDIR=$SINGULARITY_TMPDIR"
echo "NXF_SINGULARITY_CACHEDIR=$NXF_SINGULARITY_CACHEDIR"