#shellcheck disable=SC2148
#shellcheck source=/dev/null

source "${SERVER_DIR}"/scripts/utils/logs.sh
source "${SERVER_DIR}"/scripts/config/utils.sh




# Function to setup the rcon.yaml config file
#
# Description:
#   This function sets up the 'rcon.yaml' config file for the server.
#   It will always use 'PalWorldSettings.ini' file to configure the 'rcon.yaml' file.
function setup_rcon_yaml () {
    if [[ -n ${RCON_ENABLED+x} ]] && [ "${RCON_ENABLED,,}" == "true" ] ; then
        log_info "> RCON is enabled"

        mkdir -p "$(dirname "${RCON_CONFIG_FILE}")"
        cp "${SERVER_DIR}/scripts/config/templates/rcon.yaml.template" "${RCON_CONFIG_FILE}"

        if [[ -f "${GAME_SETTINGS_FILE}" ]]; then
            log_warning ">> Using file '${GAME_SETTINGS_FILE}' to configure '${RCON_CONFIG_FILE}'..."

            # Use file information
            admin_password=$(awk -F'AdminPassword="' '{print $2}' "${GAME_SETTINGS_FILE}" | awk -F'"' '{print $1}' | tr -d '\n')
            rcon_port=$(awk -F'RCONPort=' '{print $2}' "${GAME_SETTINGS_FILE}" | awk -F',' '{print $1}' | tr -d '\n')

            # Check if rcon port is valid
            if [ "$(is_valid_port "${rcon_port}" "0")" = 0 ]; then
                log_error ">>> RCON_PORT is not a valid port number, please set a valid port number for RCON functionality to work!"
                exit 1
            fi

            log_info -n "> Admin Password: " && log_base "'██████████'"
            log_info -n "> RCON Port: " && log_base "'██████████'"

            if [[ -n ${rcon_port+x} ]]; then
                sed -i "s/###RCON_PORT###/${rcon_port}/" "${RCON_CONFIG_FILE}"
            else
                log_error ">>> RCON_PORT is not set in the file, please set it for RCON functionality to work!"
            fi
            if [[ -n ${admin_password+x} ]]; then
                sed -i "s/###ADMIN_PASSWORD###/${admin_password}/" "${RCON_CONFIG_FILE}"
            else
                log_error ">>> ADMIN_PASSWORD is not set in the file, please set it for RCON functionality to work!"
            fi

            log_success ">>> Finished setting up 'rcon.yaml' config file."
        else
            log_warning ">> File '${GAME_SETTINGS_FILE}' does not exist."
            log_warning ">> Restart the server after configuring '${GAME_SETTINGS_FILE}'."
            log_warning ">> RCON features will not work!"
        fi
    else
        log_warning ">> RCON is disabled, skipping '${RCON_CONFIG_FILE}' config file!"
        log_warning ">> RCON features will be disabled!"
    fi
}
