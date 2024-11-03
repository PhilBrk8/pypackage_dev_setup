#!/bin/bash
# set -e  # Exit on error

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
CURRENT_DIR=$(basename "$PWD")
# Only rename if the current directory is not already the desired package name
if [ "$CURRENT_DIR" != "$PACKAGE_NAME" ]; then
    mv "$PWD" "$(dirname "$PWD")/${PACKAGE_NAME}"
fi
# resets current pwd to package name
cd .

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
read -p "What feature do you want to develop first? [does_this]: " FIRST_FEATURE_NAME
# Check if the URL is using HTTPS
read -p "Möchtest du ein neues Git-Repository initialisieren? (y/n): " INIT_GIT
if [ "${INIT_GIT}" = "y" ] || [ "${INIT_GIT}" = "Y" ]; then
    read -p "What is the location of your remote repo? [URL]: " REMOTE_REPO_URL
    if [[ "$REMOTE_REPO_URL" =~ ^https:// ]]; then
        echo "You've entered an HTTPS URL."
        read -p "Don't you want to rather use SSH for a more secure, password-less experience? (y/n): " CONFIRM_SSH
        if [[ "$CONFIRM_SSH" =~ ^[nN]$ ]]; then
            echo "Proceeding with HTTPS URL. Remember, SSH can simplify future connections by removing the need for repeated authentication."
        else
            # Offer an SSH URL suggestion
            SUGGESTED_SSH_URL=$(echo "$REMOTE_REPO_URL" | sed -E 's|https://([^/]+)/(.+)|git@\1:\2|')
            echo "Here’s an equivalent SSH URL for convenience:"
            echo "Use it to avoid typing your password every time you push or pull."
            echo "        $SUGGESTED_SSH_URL"
            read -p "Try this SSH-connection? (y/n): " SECOND_CONFIRM_SSH
            if [[ "$SECOND_CONFIRM_SSH" =~ ^[yY]$ ]]; then
                REMOTE_REPO_URL=$SUGGESTED_SSH_URL
            fi
        fi
    fi
fi

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

################### Virtual Environment #######################
# configure poetry to use .venv for python environments
poetry config virtualenvs.prefer-active-python true

if ! uv venv --python "${PACKAGE_PY_VERSION}"; then
    echo "Error creating virtual environment with Python ${PACKAGE_PY_VERSION}."
    exit 1
fi
echo "virtual ${PACKAGE_PY_VERSION} environment created"
# pythonpath and poetry dir will be set to current dir 
# everytime the virtual environment is activated with 'source .venv/bin/activate'
sed -i '/# The hash command/i \
\n# PYTHONPATH will be set to the current directory every time the virtual environment is activated\nexport PATH="${HOME}/.local/bin:$PATH"\nexport PYTHONPATH="$(dirname "$VIRTUAL_ENV")":$PYTHONPATH\n' .venv/bin/activate
export PATH="${HOME}/.local/bin:$PATH"
echo "virtual environment created and pythonpath updated"
# activates the environment (use the 'deactivate' command to exit)
source .venv/bin/activate
echo "virtual environment activated"

#################### Poetry setup and package installation #######################
AUTHOR="${USER_NAME} ${USER_SURNAME} <${USER_EMAIL}>"
    # Update the Python version in pyproject.toml
    # Ensure pyproject.toml has the correct package name
    # Replace the authors line in pyproject.toml
sed -i \
    -e "s/^python = \".*\"/python = \"^${PACKAGE_PY_VERSION}\"/" \
    -e "s/^name = .*/name = \"${PACKAGE_NAME}\"/" \
    -e "s/^authors = \[\".*\"\]/authors = \[\"${USER_NAME} ${USER_SURNAME} <${USER_EMAIL}>\"\]/" \
    pyproject.toml
# sed -i "s/^python = \".*\"/python = \"^${PACKAGE_PY_VERSION}\"/" pyproject.toml
# sed -i "s/^name = .*/name = \"${PACKAGE_NAME}\"/" pyproject.toml
# sed -i "s/^authors = \[\".*\"\]/authors = \[\"${AUTHOR}\"\]/" pyproject.toml
mkdir "$PACKAGE_NAME"
touch "$PACKAGE_NAME"/__init__.py
# add dependencies
poetry add mypy python-dotenv
poetry add --group dev pytest pytest-cov pytest-asyncio pytest-httpx pre-commit ruff bandit safety
echo "poetry add has added python packages"
# sets up project structure required for the install command 
poetry install
echo "poetry install has been run"
# Verify that pyproject.toml was created
if [ ! -f pyproject.toml ]; then
    echo "Error: pyproject.toml was not created. Exiting."
    exit 1
else
    echo "project.toml created"
fi

#################### Pre-commit-hooks #######################
# Pre-commit installieren und Hooks initialisieren
pre-commit clean
# updates all hooks in .pre-commit-hooks.yaml to their latest version
echo "pre-commit-hooks updating..."
pre-commit autoupdate
# gives logs if something is wrong whith the hooks
echo "run pre-commit with verbose parameter:"
pre-commit run --all-files --verbose
echo "pre-commit-hooks installing..."
poetry run pre-commit install

#################### Pipelines #######################
# Replace the Python version in bitbucket-pipelines.yml
sed -i "1s|^image: python:.*|image: python:${PACKAGE_PY_VERSION}|" bitbucket-pipelines.yml .gitlab-ci.yml

#################### Run first test #######################
# Run tests with coverage report
echo "Running tests with coverage report..."
poetry run pytest --cov="${PACKAGE_NAME}" --cov-report=html
echo "Running tests with coverage report... - poetry syntax"
poetry run coverage html
# Check if the coverage report was generated
COV_REPORT_DIR="htmlcov"
if [ -d "${COV_REPORT_DIR}" ]; then
    echo "Coverage report generated successfully."
else
    echo "Error: Coverage report was not generated correctly."
    exit 1
fi

echo ""
echo "Current location: $(pwd)"
echo "########################### Last Steps ############################"
echo "And now the only thing left is:"
echo "Initialize a local git repo and connect it to your remote repo"
echo "###################################################################"
echo ""

# reload the current directory path:
cd .
mv README.md README_DEV.md

if [ "${INIT_GIT}" = "y" ] || [ "${INIT_GIT}" = "Y" ]; then
    # Remove any existing Git configuration and initialize a new repository
    rm -rf .git
    git init
    git branch -m main
    echo "Git-Repository initialised."

    # Add and commit any new or modified files in the local repository
    git add -A
    git commit -m "initialization of the project structure"

    # Connect to the remote repository
    git remote add origin "${REMOTE_REPO_URL}"

    # Fetch the latest changes from the remote repository without merging
    git fetch origin main

    # Rebase your initial commit on top of the fetched remote main branch
    git rebase origin/main

    # Push the main branch to the remote, setting the upstream to origin/main
    git push -u origin main

    # Create a new feature branch, set upstream tracking, and push it to the remote
    git checkout -b feature/"${FIRST_FEATURE_NAME}"
    git push -u origin feature/"${FIRST_FEATURE_NAME}"
    echo "Remote-Repository connected."

elif [ "${INIT_GIT}" = "n" ] || [ "${INIT_GIT}" = "N" ]; then
    rm -rf .git
    echo "Git-Repository init skipped."

else
    echo "Something strange failed at git initialization."
fi

# Prompt the user to start developing the package
read -p "Start developing the package? (y/n): " START_DEV
# Check user input
if [ "$START_DEV" = "y" ] || [ "$START_DEV" = "Y" ]; then
    echo "Starting development mode..."
    # Self-delete the script for a clean package template
    trap 'rm -- "$0"' EXIT
    echo "Script has been deleted for a clean setup."
else
    echo "Development not started. Script will remain intact."
fi
