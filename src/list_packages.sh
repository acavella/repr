#!/bin/bash

# ==============================================================================
# Script Name: list_packages.sh
# Description: Generates a list of all installed packages on an AlmaLinux
#              (or any RHEL-based) system using the 'dnf' package manager.
# ==============================================================================

# Create a timestamped filename for the output
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="installed_packages_${TIMESTAMP}.txt"

echo "Gathering installed packages using dnf..."

# Run dnf list installed and redirect the output to the text file
# Using awk to format the output nicely (optional, but makes it cleaner)
dnf list installed > "$OUTPUT_FILE"

# Check if the dnf command executed successfully
if [ $? -eq 0 ]; then
    echo "✅ Success! The list of installed packages has been saved."
    echo "📄 File location: $(pwd)/$OUTPUT_FILE"
else
    echo "❌ Error: Failed to generate the package list."
    echo "Please ensure you are running this on an AlmaLinux/RHEL system with 'dnf' installed."
    exit 1
fi
