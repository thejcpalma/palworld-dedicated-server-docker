# shellcheck disable=SC2148
# shellcheck source=/dev/null

source "${SERVER_DIR}"/scripts/utils/logs.sh

# Verifies that default admin and server passwords are not in use.
# If default credentials are found, an error message is displayed and the server start process is halted.
function check_default_credentials() {
    log_info "> Checking for existence of default credentials"

    if [[ -f "${GAME_SETTINGS_FILE}" ]]; then
        admin_password=$(awk -F'AdminPassword="' '{print $2}' "${GAME_SETTINGS_FILE}" | awk -F'"' '{print $1}' | tr -d '\n')
        if [[ "${admin_password}" == "adminPasswordHere" ]]; then
            log_error ">>> Security thread detected: Please change the default admin password. Aborting server start..."
            exit 1
        fi
        server_password=$(awk -F'ServerPassword="' '{print $2}' "${GAME_SETTINGS_FILE}" | awk -F'"' '{print $1}' | tr -d '\n')
        if [[ "${server_password}" == "serverPasswordHere" ]]; then
            log_error ">>> Security thread detected: Please change the default server password. Aborting server start..."
            exit 1
        fi
    fi
}
