#!/bin/bash
# shellcheck disable=SC2148
# shellcheck source=/dev/null

source "${SERVER_DIR}"/scripts/utils/logs.sh

# Function to run RCON commands
# Arguments: <command>
# Example: rconcli "showplayers"
rconcli() {
    local cmd="$*"
    if [[ -z ${RCON_ENABLED+x} ]] || [[ "${RCON_ENABLED,,}" != "true" ]]; then
        log_error ">>> RCON is not enabled. Aborting RCON command ..."
        return
    fi

    if [[ ! -f "${RCON_CONFIG_FILE}" ]]; then
        return
    fi

    # Edge case for broadcast because it doesn't support spaces in the message
    if [[ ${cmd,,} == broadcast* ]]; then
        cmd=${cmd#broadcast }  # Remove 'broadcast ' from the command (also removes the space after 'broadcast')
        output=$(rcon_broadcast -c "${RCON_CONFIG_FILE}" "${cmd}" | tr -d '\0')
    else
        output=$(rcon -c "${RCON_CONFIG_FILE}" "${cmd}" | tr -d '\0')
    fi

    log_info -n "> RCON: "
    log_base "$output"
}

rconcli "$*"
