#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Define the package name for the project directory
read -p "What should your package be called [data_processing_tool]: " PACKAGE_NAME

# Clone the repository using SSH or fallback to HTTPS if SSH fails
git clone git@github.com:PhilBrk8/pypackage_dev_setup.git "$PACKAGE_NAME" || \
git clone https://github.com/PhilBrk8/pypackage_dev_setup.git "$PACKAGE_NAME" || {
  echo "Failed to clone the repository. Make sure your SSH keys are configured, or use HTTPS."
  exit 1
}

# Change into the project directory
cd "$PACKAGE_NAME" || exit

# Run the initialization script
chmod +x init.sh
./init.sh "$PACKAGE_NAME"

# Self-delete the script for a clean package template
trap 'rm -- "$0"' EXI