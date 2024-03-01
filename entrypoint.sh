#!/bin/bash
# shellcheck source=/dev/null

# This line sets the shell option -e, which causes the script to 
# exit immediately if any command exits with a non-zero status.
set -e

source "${SERVER_DIR}"/scripts/utils/logs.sh
source "${SERVER_DIR}"/scripts/server/stop_server.sh

if [[ "${PUID}" -eq 0 ]] || [[ "${PGID}" -eq 0 ]]; then
    log_warning ">>> Running as root is not supported, please fix your PUID and PGID!"
    exit 1
elif [[ "$(id -u steam)" -ne "${PUID}" ]] || [[ "$(id -g steam)" -ne "${PGID}" ]]; then
    log_info "> Current steam user UID is '$(id -u steam)' and GID is '$(id -g steam)'"
    log_info "> Setting new steam user UID to '${PUID}' and GID to '${PGID}'"
    groupmod -g "${PGID}" steam && usermod -u "${PUID}" -g "${PGID}" steam
fi

mkdir -p /palworld/backups
chown -R steam:steam /palworld /home/steam/

# shellcheck disable=SC2317
# Handler for SIGTERM from docker-based stop events
function term_handler() {
    log_error ">>> SIGTERM received"
    stop_server
}

log_success ">>>> Starting server manager <<<<"

# If SIGTERM is sent to the process, call term_handler function
trap 'kill ${!}; term_handler' SIGTERM

# Start the server manager
su steam -c "/home/steam/server/scripts/server_manager.sh init" &

killpid="${!}"
log_info "> Server main thread started with pid ${killpid}"
wait ${killpid}


# Wait for backup jobs to finish
mapfile -t backup_pids < <(pgrep backup)
if [ "${#backup_pids[@]}" -ne 0 ]; then
    log_warning ">> Waiting for backup jobs to finish..."
    for pid in "${backup_pids[@]}"; do
        tail --pid="$pid" -f 2>/dev/null
    done
    log_success ">>> Backup jobs finished"
fi

exit 0;

