#!/bin/bash
set -e  # Exit on error

#################### User inputs #######################
# Check if PACKAGE_NAME was provided as an argument
if [ -n "$1" ]; then
    # Use the provided argument
    PACKAGE_NAME="$1"
else
    # If not, prompt for the package name
    read -p "Enter the package name: (e.g. web_crawler): " PACKAGE_NAME
fi

# Rename the current directory to the value of PACKAGE_NAME
mv "$(pwd)" "$(dirname "$(pwd)")/${PACKAGE_NAME}"

# Prompt for Python version with strict validation
echo "Use python 3.13 as soon as possible, due to its built-in support for multi-threaded operations"
echo "Step down if something breaks until all programs have adopted python3.13 support"
echo "Script was tested for 3.9 - 3.12" 
while true; do
    read -p "In which Python version should the package be? [3.9 / 3.13]: " PACKAGE_PY_VERSION

    # Validate input: check if it matches one of the allowed versions from 3.6 to 3.13
    if [[ "$PACKAGE_PY_VERSION" =~ ^3\.(9|10|11|12|13)$ ]]; then
        echo "Valid Python version: $PACKAGE_PY_VERSION"
        break
    else
        echo "Invalid input. Please enter a version between 3.6 and 3.13 (e.g., 3.9, 3.12)."
    fi
done

echo "Please provide your personal information (used to make you the author of the package)"
read -p "What is your name? [Name]: " USER_NAME
read -p "What is your surname? [Surname]: " USER_SURNAME
read -p "What is your email? [name.surname@esforin.com]: " USER_EMAIL