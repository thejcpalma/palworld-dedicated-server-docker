#shellcheck disable=SC2148
#shellcheck source=/dev/null

source "${SERVER_DIR}"/scripts/utils/logs.sh
source "${SERVER_DIR}"/scripts/config/utils.sh


function setup_rcon_yaml () {
    if [[ -n ${RCON_ENABLED+x} ]] && [ "${RCON_ENABLED,,}" == "true" ] ; then
        log_info "> RCON is enabled, setting 'rcon.yaml' config file..."

        mkdir -p "$(dirname "${RCON_CONFIG_FILE}")"
        cp "${SERVER_DIR}/scripts/config/templates/rcon.yaml.template" "${RCON_CONFIG_FILE}"

        if [[ "${SERVER_SETTINGS_MODE,,}" == "auto" ]]; then
            # Use environment variables
            log_warning ">> Using environment variables to configure 'rcon.yaml' config file."
            log_info -n "> Admin Password: " && log_base "'██████████'"
            log_info -n "> RCON Port: " && log_base "'██████████'"

            if [[ -n ${RCON_PORT+x} ]]; then
                sed -i "s/###RCON_PORT###/$RCON_PORT/" "$RCON_CONFIG_FILE"
            else
                log_error ">>> RCON_PORT is not set, please set it for RCON functionality to work!"
            fi
            if [[ -n ${ADMIN_PASSWORD+x} ]]; then
                sed -i "s/###ADMIN_PASSWORD###/$ADMIN_PASSWORD/" "$RCON_CONFIG_FILE"
            else
                log_error ">>> ADMIN_PASSWORD is not set, please set it for RCON functionality to work!"
            fi
        else
            log_warning ">> Using file '$GAME_SETTINGS_FILE' to configure..."

            # Use file information
            admin_password=$(awk -F'AdminPassword="' '{print $2}' "$GAME_SETTINGS_FILE" | awk -F'"' '{print $1}' | tr -d '\n')
            rcon_port=$(awk -F'RCONPort=' '{print $2}' "$GAME_SETTINGS_FILE" | awk -F',' '{print $1}' | tr -d '\n')

            log_info -n "> Admin Password: " && log_base "'██████████'"
            log_info -n "> RCON Port: " && log_base "'██████████'"

            if [[ -n ${rcon_port+x} ]]; then
                sed -i "s/###RCON_PORT###/$rcon_port/" "$RCON_CONFIG_FILE"
            else
                log_error ">>> RCON_PORT is not set in the file, please set it for RCON functionality to work!"
            fi
            if [[ -n ${admin_password+x} ]]; then
                sed -i "s/###ADMIN_PASSWORD###/$admin_password/" "$RCON_CONFIG_FILE"
            else
                log_error ">>> ADMIN_PASSWORD is not set in the file, please set it for RCON functionality to work!"
            fi
        fi

        log_success ">>> Finished setting up 'rcon.yaml' config file."
    else
        log_warning ">> RCON is disabled, skipping 'rcon.yaml' config file!"
    fi
}
