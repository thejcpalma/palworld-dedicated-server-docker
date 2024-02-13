#!/bin/bash
# shellcheck disable=SC1091

set -e

source "${PWD}"/includes/colors.sh
source "${PWD}"/includes/webhook.sh
source "${PWD}"/includes/server.sh

if [[ "${PUID}" -eq 0 ]] || [[ "${PGID}" -eq 0 ]]; then
    echo_warning ">>> Running as root is not supported, please fix your PUID and PGID!"
    exit 1
elif [[ "$(id -u steam)" -ne "${PUID}" ]] || [[ "$(id -g steam)" -ne "${PGID}" ]]; then
    echo_info "> Current steam user UID is '$(id -u steam)' and GID is '$(id -g steam)'"
    echo_info "> Setting new steam user UID to '${PUID}' and GID to '${PGID}'"
    groupmod -g "${PGID}" steam && usermod -u "${PUID}" -g "${PGID}" steam
fi

mkdir -p /palworld/backups
chown -R steam:steam /palworld /home/steam/

### Signal Handling (Handlers & Traps)

# Handler for SIGTERM from docker-based stop events
function term_handler() {
    echo_error ">>> SIGTERM received"
    stop_server
}

function start_handlers() {

    # If SIGTERM is sent to the process, call term_handler function
    trap 'kill ${!}; term_handler' SIGTERM

    echo_info "> Handlers started"
}

# Process loop to keep the server manager running
while true
do
    echo_success ">>>> Starting server manager <<<<"
    start_handlers

    # Start the server manager
    su steam -c /home/steam/server/scripts/servermanager.sh &

    killpid="${!}"
    echo_info "> Server main thread started with pid ${killpid}"
    wait ${killpid}


    # Wait for backup jobs to finish
    mapfile -t backup_pids < <(pgrep backup)
    if [ "${#backup_pids[@]}" -ne 0 ]; then
        echo "Waiting for backup to finish"
        for pid in "${backup_pids[@]}"; do
            tail --pid="$pid" -f 2>/dev/null
        done
    fi

    exit 0;
done
