# shellcheck disable=SC2148
# shellcheck source=/dev/null

source "${SERVER_DIR}"/scripts/utils/logs.sh
source "${SERVER_DIR}"/scripts/rcon/aliases.sh

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
# be set to "always" or "unless-stopped" and RCON should be enabled

# Function to restart the gameserver
function restart_server() {
    if [ "${RCON_ENABLED,,}" = true ]; then
        players_online=$(rcon_get_player_count)

        local warn_minutes=${1}

        # If (no players online) or (warn_minutes is not empty and equal to 0)
        if [ "${players_online}" -eq 0 ] || { [ -n "${warn_minutes}" ] && [ "${warn_minutes}" -eq 0 ]; }; then
            warn_minutes=0
            log_warning ">> Restarting server now..."
        # If warn_minutes is not empty and a valid positive int
        elif [[ -n "${warn_minutes}" ]] && [[ "${warn_minutes}" =~ ^[0-9]+$ ]]; then
            log_warning ">> Restarting server in ${warn_minutes} minutes..."
        # If warn_minutes is not empty but isn't a valid int then default to 30
        else
            warn_minutes=30
            log_warning ">> Restarting server in ${warn_minutes} minutes..."
        fi

        rcon_restart "${warn_minutes}"

    else
        log_warning ">> Restarting server without RCON might cause data loss! Feature is disabled."
    fi
}
