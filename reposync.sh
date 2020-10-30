#!/usr/bin/env bash

# Repo Sync: Incremental updates for offline repositories
# Version 1.0.0-Beta.2
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
DG=$(date '+%Y%m%d')
MANIFEST="${__db}/manifest.txt"
MANIFEST_TMP="${__db}/manifest_TMP.txt"
MANIFEST_DIFF="${__db}/manifest_${DG}.txt"
TMP_DIR=$(mktemp -d /tmp/repo.XXXXXXXXX)

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

show_ascii_logo() {
    echo -e "
 _ __ ___ _ __   ___  ___ _   _ _ __   ___ 
| '__/ _ \ '_ \ / _ \/ __| | | | '_ \ / __|
| | |  __/ |_) | (_) \__ \ |_| | | | | (__ 
|_|  \___| .__/ \___/|___/\__, |_| |_|\___|
         |_|              |___/            

               
reposync // generate incremental yum updates
"
}


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

create_client_install() {
    # Local, named variables
    local str="Generating client instal"
    # Configure bash script for client install
    printf "  %b %s..." "${INFO}" "${str}"
    # Install revoke virtual host configuration
    {
        echo "#!/usr/bin/env bash"
        echo "cp ./packages/*.rpm ${CLIENT_REPO}"
        echo "restorecon -r ${CLIENT_REPO}"
        echo "createrepo --update ${CLIENT_REPO}"
        echo "exit 0"
    }>${TMP_DIR}/update-repo.sh
    chmod +x ${TMP_DIR}/update-repo.sh
    printf "%b  %b %s...\\n" "${OVER}" "${TICK}" "${str}"
}

build_update_tar() {
    # Check if this is the initial sync
    if [ -f "${MANIFEST}" ]; then
        printf "  %b Manifest file found: %s\\n" "${TICK}" "${MANIFEST}"
        
        local str1="Building differential package list"
        local str2="Building update package"
        local str3="Building initial manifest"
        ls ${SERVER_REPO} > ${MANIFEST_TMP} # generate temporary manifest
        printf "  %b %s..." "${INFO}" "${str1}"
        grep -Fxv -f ${MANIFEST} ${MANIFEST_TMP} > ${MANIFEST_DIFF} # build differential manifest
        mapfile -t PACKAGE_LIST < ${MANIFEST_DIFF} # load manifest into array
        printf "%b  %b %s...\\n" "${OVER}" "${TICK}" "${str1}"
        printf "  %b %s..." "${INFO}" "${str2}"
        # iterate through array and copy new files to tmp
        for i in "${PACKAGE_LIST[@]}"
        do
            cp ${i} ${TMP_DIR}/packages/
        done
        create_client_install
        mv ${MANIFEST_DIFF} ${TMP_DIR}/MANIFEST_${DTG} # move manifest diff to be included with tar
        tar -czvf ${UPDATE_LOC}/update_${DTG}.tar.gz ${TMP_DIR} # create archive from tmp
        printf "%b  %b %s...\\n" "${OVER}" "${TICK}" "${str2}"
        rm -rf ${TMP_DIR} # cleanup tmp
        mv ${MANIFEST_TMP} ${MANIFEST} # overwrite manifest with updates
    else
        printf "  %b %bManifest not found, assuming first run.%b\\n" "${CROSS}" "${COL_LIGHT_RED}" "${COL_NC}"
        printf "  %b %s..." "${INFO}" "${str3}"
        ls ${SERVER_REPO} > ${MANIFEST} # generate initial manifest
        printf "%b  %b %s...\\n" "${OVER}" "${TICK}" "${str3}"
    fi
}

update_repo() {
    local str="Performing repository sync"
    printf "  %b %s..." "${INFO}" "${str}"
    reposync -p ${SERVER_REPO} --repoid=${SRC_REPO}
    printf "%b  %b %s...\\n" "${OVER}" "${TICK}" "${str}"
}

main() {
    show_ascii_logo
    update_repo
    build_update_tar
    exit 0 # clean exit
}

main