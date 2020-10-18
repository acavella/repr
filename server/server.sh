#!/usr/bin/env bash

# Repo Sync: Incremental updates for offline repositories
# (c) 2018 - 2019 Tony Cavella (https://github.com/altCipher/reposync)
# This script acts as the server; syncs within an online repository
# and prepares incremental updates for transfer to offline client.
#
# This file is copyright under the latest version of the GPLv3.
# Please see LICENSE file for your rights under this license.

# -e option instructs bash to immediately exit if any command [1] has a non-zero exit status
# -u option instructs bash to exit on unset variables (useful for debugging)
set -e
set -u

######## VARIABLES #########
# For better maintainability, we store as much information that can change in variables
# These variables should all be GLOBAL variables, written in CAPS
# Local variables will be in lowercase and will exist only within functions

# Base directories
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__db="${__dir}/db"

# Script Variables
DTG=$(date '+%Y%m%d-%H%M%S')
MANIFEST="${__db}/manifest.txt"
MANIFEST_TMP="${__db}/manifest_TMP.txt"
MANIFEST_DIFF="${__db}/manifest_${DTG}.txt"

# Load variables from external config
source ${__dir}/rs-server.conf

# Color Table
COL_NC='\e[0m' # No Color
COL_LIGHT_GREEN='\e[1;32m'
COL_LIGHT_RED='\e[1;31m'
TICK="[${COL_LIGHT_GREEN}✓${COL_NC}]"
CROSS="[${COL_LIGHT_RED}✗${COL_NC}]"
INFO="[i]"
# shellcheck disable=SC2034
DONE="${COL_LIGHT_GREEN} done!${COL_NC}"
OVER="\\r\\033[K"

######## FUNCTIONS #########
# All operations are built into individual functions for better readibility
# and management.  

is_command() {
    # Checks for existence of string passed in as only function argument.
    # Exit value of 0 when exists, 1 if not exists. Value is the result
    # of the `command` shell built-in call.
    local check_command="$1"

    command -v "${check_command}" >/dev/null 2>&1
}

get_package_manager() {
    # Check for common package managers per OS
    if is_command dnf ; then
        PKG_MGR="dnf" # set to dnf
        SYSTEMD=1
        printf "  %b Package manager: %s\\n" "${TICK}" "${PKG_MGR}"
    elif is_command yum ; then
        PKG_MGR="yum" # set to yum
        SYSTEMD=0
        printf "  %b Package manager: %s\\n" "${TICK}" "${PKG_MGR}"
    else
        # unable to detect a common yum based package manager
        printf "  %b %bSupported package manager not found%b\\n" "${CROSS}" "${COL_LIGHT_RED}" "${COL_NC}"
    fi
}

build_manifest() {
    # Check if this is the initial sync
    if [ -f "${MANIFEST}" ]; then
        printf "  %b Manifest file found: %s\\n" "${TICK}" "${MANIFEST}"
        ls ${SERVER_REPO} > ${MANIFEST_TMP}
        grep -Fxv -f ${MANIFEST} ${MANIFEST_TMP} > ${MANIFEST_TMP}
    else
        printf "  %b %bManifest not found, assuming first run.%b\\n" "${CROSS}" "${COL_LIGHT_RED}" "${COL_NC}"
    fi
}

main() {
    reposync -p ${SERVER_REPO} --gpg-check --repoid=${SRC_REPO}
    exit 0 # clean exit
}