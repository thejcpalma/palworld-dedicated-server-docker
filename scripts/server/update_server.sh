# shellcheck disable=SC2148
# shellcheck source=/dev/null

source "${SERVER_DIR}"/scripts/utils/logs.sh
source "${SERVER_DIR}"/scripts/webhook/aliases.sh

steamcmd_dir="/home/steam/steamcmd"

# Function to update the gameserver
# Function: update_server
# Description: This function is used to update the server.
# Parameters: None
# Returns: 0 (true) if 
#          1 (false) if server is up-to-date
function update_server() {

    if [ "${ALWAYS_UPDATE_ON_START,,}" == "false" ]; then
        return 1
    fi

    if [[ -n ${STEAMCMD_VALIDATE_FILES} ]] && [[ ${STEAMCMD_VALIDATE_FILES,,} == "true" ]]; then
        # The update here is forced because we can only use 'validate' with the option '+app_update' on 'steamcmd'
        log_warning ">> Updating and validating gameserver files..."
        
        send_update_and_validate_notification

        "${steamcmd_dir}"/steamcmd.sh +force_install_dir "${GAME_ROOT}" +login anonymous +app_update "${APP_ID}" validate +quit
        log_success ">>> Done updating and validating gameserver files"
    else
        # Only update the server if a new update is available
        if check_update_server; then
            log_warning ">> Updating gameserver files..."

            send_update_notification

            "${steamcmd_dir}"/steamcmd.sh +force_install_dir "${GAME_ROOT}" +login anonymous +app_update "${APP_ID}" +quit
            log_success ">>> Done updating gameserver files"
            return 0
        fi
    fi
}
