#!/bin/bash

# ==============================================================================
# Script Name: list_packages.sh
# Description: Generates a list of all installed packages on an AlmaLinux
#              (or any RHEL-based) system using the 'dnf' package manager.
# ==============================================================================

# Create a timestamped filename for the output
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="installed_packages_${TIMESTAMP}.txt"

# Function to log messages with a timestamp
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "Gathering installed packages using dnf..."

# Run dnf list installed and redirect the output to the text file
dnf list --installed > "$OUTPUT_FILE"

# Check if the dnf command executed successfully
if [ $? -eq 0 ]; then
    log "Success! The list of installed packages has been saved."
    log "File location: $(pwd)/$OUTPUT_FILE"
else
    log "Error: Failed to generate the package list."
    log "Please ensure you are running this on an AlmaLinux/RHEL system with 'dnf' installed."
    exit 1
fi
