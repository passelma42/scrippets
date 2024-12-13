#!/bin/bash

# RUNNING epi2melabs on HPC

# Function to display help message
show_help() {
  echo "Usage: $0 -u <user> [--default] [--cache-dir <path>] [--temp-dir <path>] [--images-dir <path>] [--scratch-vo]"
  echo "\nOptions:"
  echo "  -u, --user          Specify the user identifier (required)."
  echo "  --default           Run in default mode with predefined directory structure."
  echo "  --cache-dir         Specify a custom cache directory."
  echo "  --temp-dir          Specify a custom temporary directory."
  echo "  --images-dir        Specify a custom images directory."
  echo "  --scratch-vo        Use /scratch/gent/vo/001/gvo00142/<user>/singularity as base directory instead of /scratch/gent/433/<user>."
  echo "  --help              Show this help message and exit."
  exit 0
}

# Parse arguments
USER=""
DEFAULT_MODE=false
SCRATCH_VO=false
CACHE_DIR=""
TEMP_DIR=""
IMAGES_DIR=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -u|--user)
      USER="$2"
      shift 2
      ;;
    --default)
      DEFAULT_MODE=true
      shift
      ;;
    --scratch-vo)
      SCRATCH_VO=true
      shift
      ;;
    --cache-dir)
      CACHE_DIR="$2"
      shift 2
      ;;
    --temp-dir)
      TEMP_DIR="$2"
      shift 2
      ;;
    --images-dir)
      IMAGES_DIR="$2"
      shift 2
      ;;
    --help)
      show_help
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      ;;
  esac
done

if [[ -z "$USER" ]]; then
  echo "Error: User identifier is required."
  show_help
fi

if $DEFAULT_MODE || $SCRATCH_VO; then
  if $SCRATCH_VO; then
    BASE_DIR="/scratch/gent/vo/001/gvo00142/$USER/singularity"
  else
    BASE_DIR="/scratch/gent/433/$USER"
  fi
  CACHE_DIR="$BASE_DIR/cache"
  TEMP_DIR="$BASE_DIR/temp"
  IMAGES_DIR="$BASE_DIR/images"
fi

if [[ -z "$CACHE_DIR" || -z "$TEMP_DIR" || -z "$IMAGES_DIR" ]]; then
  echo "Error: All directories (--cache-dir, --temp-dir, --images-dir) must be specified unless --default or --scratch-vo is used."
  show_help
fi

# Create directories
create_directory() {
  if [[ ! -d "$1" ]]; then
    echo "Creating directory: $1"
    mkdir -p "$1"
  else
    echo "Directory already exists: $1"
  fi
}

create_directory "$CACHE_DIR"
create_directory "$TEMP_DIR"
create_directory "$IMAGES_DIR"

# Set environment variables
export SINGULARITY_CACHEDIR="$CACHE_DIR"
export SINGULARITY_TMPDIR="$TEMP_DIR"
export NXF_SINGULARITY_CACHEDIR="$IMAGES_DIR"

echo "Set SINGULARITY_CACHEDIR=$CACHE_DIR"
echo "Set SINGULARITY_TMPDIR=$TEMP_DIR"
echo "Set NXF_SINGULARITY_CACHEDIR=$IMAGES_DIR"

# Apply permissions
chmod -R 777 "$CACHE_DIR"
chmod -R 777 "$TEMP_DIR"
chmod -R 777 "$IMAGES_DIR"

# Confirm setup
echo "\nEnvironment setup complete."
echo "SINGULARITY_CACHEDIR=$SINGULARITY_CACHEDIR"
echo "SINGULARITY_TMPDIR=$SINGULARITY_TMPDIR"
echo "NXF_SINGULARITY_CACHEDIR=$NXF_SINGULARITY_CACHEDIR"
