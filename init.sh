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

#################### install checks #######################
# Check if python3 is installed - and install if not
if ! command -v python3 &> /dev/null
then
    echo "Python 3 not found. Installing Python 3..."

    # Attempt to install Python 3 based on the operating system
    if [ "$(uname)" = "Darwin" ]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew update
            brew install python
        else
            echo "Homebrew not found. Please install Homebrew first or install Python 3 manually."
            exit 1
        fi
    elif [ -f /etc/debian_version ]; then
        # Debian/Ubuntu
        sudo apt-get update
        sudo apt-get install -y python3 python3-venv python3-dev
    elif [ -f /etc/redhat-release ]; then
        # Red Hat/CentOS/Fedora
        sudo yum install -y python3
    else
        echo "Unsupported OS. Please install Python 3 manually."
        exit 1
    fi

    # Verify installation
    if ! command -v python3 &> /dev/null
    then
        echo "Python 3 installation failed. Please install it manually."
        exit 1
    fi
fi

# Check if uv is installed - and install if not
if ! command -v uv &> /dev/null
then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Check if poetry is installed - and install if not
export PATH="${HOME}/.local/bin:$PATH"
if ! command -v poetry &> /dev/null
then
    echo "Installing poetry..."
    curl -sSL https://install.python-poetry.org | python3 -
fi

# Check if pyproject.toml already exists
if [ -f pyproject.toml ] 
then
    echo "A pyproject.toml file already exists. Skipping poetry init."
else
    # TODO: 'poetry init --no-interaction' not running correctly
    echo "running poetry init"
    # # Neues Poetry-Projekt erstellen
    # poetry init \
    #      --name "${PACKAGE_NAME}" \
    #      --description "Beschreibung für ${PACKAGE_NAME}" \
    #      --version "0.1.0"
    #      --author "${USER_NAME} ${USER_SURNAME} <${USER_EMAIL}>"
    # echo "poetry init has been run succesfully"
fi