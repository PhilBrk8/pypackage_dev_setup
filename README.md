# Installation

Copy this codeblock and run it in the terminal to set up the project:

```bash
read -p "What should your package be called [data_processing_tool]: " PACKAGE_NAME
git clone https://philippburkhardt@bitbucket.org/esforinse/repo_template.git "${PACKAGE_NAME}"
cd "${PACKAGE_NAME}"
./init.sh "${PACKAGE_NAME}" pypackage_dev_setup
```

# Usage

## Activate virtual environment

Activate the virtual environment using the following command:

```bash
source .venv/bin/activate
```

## Run Tests

To run the tests with coverage reporting, activate the virtual environment and use poetry run pytest:

```bash
source .venv/bin/activate
poetry run pytest --cov="${PACKAGE_NAME}" --cov-report=html
```

A coverage report will be created in the htmlcov dir.

## Security checks

Run the following commands to check your code and dependencies for security issues:

```bash
poetry run safety check
poetry run bandit -r "${PACKAGE_NAME}"
```

# CI/CD

## Pre-Commit-Hooks

A Pre-Commit-Hook ist a number of commands that are run during the commit creation process, before the commit is finally created, so you can have some security in place.

This project uses several pre-commit hooks to maintain code quality and security:

- Ruff: A linter and formatter that enforces Python code style and fixes issues automatically.
- Bandit: A static analysis tool that scans Python code for potential security vulnerabilities.

## Pipelines

If using Bitbucket Pipelines, the following steps are included:

- Git Secrets Scan: Scans for sensitive information in commits.
- Code Linting and Formatting: Runs ruff to check and format code.
- Snyk Security Scan: Scans dependencies for vulnerabilities. (must be registered first)

# Lizenz

Dieses Projekt steht unter der [MIT-Lizenz](LICENSE)

```

```
