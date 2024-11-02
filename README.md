# Installation

Copy this codeblock and run it in the terminal to set up the project:

```bash
read -p "What should your package be called [data_processing_tool]: " PACKAGE_NAME
git clone https://philippburkhardt@bitbucket.org/esforinse/repo_template.git "${PACKAGE_NAME}"
cd "${PACKAGE_NAME}"
./init.sh "${PACKAGE_NAME}" pypackage_dev_setup
```
