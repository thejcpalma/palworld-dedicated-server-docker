#!/bin/bash
# shellcheck disable=SC2148,SC1091

source "${PWD}"/includes/colors.sh
source "${PWD}"/includes/rcon.sh

# Function to run RCON commands
# Arguments: <command>
# Example: rconcli "showplayers"
rconcli() {
    local cmd="$*"
    if [[ -z ${RCON_ENABLED+x} ]] || [[ "${RCON_ENABLED,,}" != "true" ]]; then
        echo_error ">>> RCON is not enabled. Aborting RCON command ..."
        exit
    fi

    echo_info -n "> RCON: "
    output=$(rcon -c "${PWD}"/configs/rcon.yaml "${cmd}" | tr -d '\0')
    echo_base "$output"

}

rconcli "$*"
