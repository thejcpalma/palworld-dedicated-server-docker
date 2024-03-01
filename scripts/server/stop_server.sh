# shellcheck disable=SC2148
# shellcheck source=/dev/null

source "${SERVER_DIR}"/scripts/utils/logs.sh
source "${SERVER_DIR}"/scripts/rcon/aliases.sh
source "${SERVER_DIR}"/scripts/webhook/aliases.sh

# The difference between stop_server and restart_server is that stop server
# will always be called on the SIGTERM signal sent by docker stop/restart command
# and restart_server will be called when the server is restarted with
# the auto restart/update features
#
# Depending on the docker restart policy:
# Set to "no":
#   The container will not restart
# Set to "on-failure":
#   The container will restart only if the process exits with a non-zero status
# Set to "unless-stopped":
#   The container will restart unless it is explicitly stopped
# Set to "always":
#   The container will always restart
#
# For auto restart/update features to work properly, the restart policy should
# be set to "always" or "unless-stopped"

# Function to stop the gameserver
function stop_server() {
    log_warning ">>> Stopping server..."

    if [[ -n ${RCON_ENABLED} ]] && [[ ${RCON_ENABLED,,} == "true" ]]; then
        rcon_save_and_shutdown
    else
	    kill -SIGTERM "$(pidof PalServer-Linux-Test)"
	    tail --pid="$(pidof PalServer-Linux-Test)" -f 2>/dev/null
    fi

    send_stop_notification

    log_warning ">> Server stopped gracefully"

    exit 143;
}
