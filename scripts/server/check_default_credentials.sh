# shellcheck disable=SC2148
# shellcheck source=/dev/null

source "${SERVER_DIR}"/scripts/utils/logs.sh

# Verifies that default admin and server passwords are not in use.
# If default credentials are found, an error message is displayed and the server start process is halted.
function check_default_credentials() {
    log_info "> Checking for existence of default credentials"

    # If the 'ADMIN_PASSWORD' environment variable is set to 'adminPasswordHere', an error message is displayed and the function exits.
    if [[ -n ${ADMIN_PASSWORD} ]] && [[ ${ADMIN_PASSWORD} == "adminPasswordHere" ]]; then
        log_error ">>> Security thread detected: Please change the default admin password. Aborting server start ..."
        exit 1
    fi

    # If the 'SERVER_PASSWORD' environment variable is set to 'serverPasswordHere', an error message is displayed and the function exits.
    if [[ -n ${SERVER_PASSWORD} ]] && [[ ${SERVER_PASSWORD} == "serverPasswordHere" ]]; then
        log_error ">>> Security thread detected: Please change the default server password. Aborting server start ..."
        exit 1
    fi

    # If 'SERVER_SETTINGS_MODE' is set to 'manual' and the 'GAME_SETTINGS_FILE' exists and is not empty, the function extracts the admin password from the 'GAME_SETTINGS_FILE'. 
    # If the password is 'adminPasswordHere', an error message is displayed.
    if [[ "${SERVER_SETTINGS_MODE,,}" == "manual" ]] && [[ -s "${GAME_SETTINGS_FILE}" ]]; then
        admin_password=$(awk -F'AdminPassword="' '{print $2}' "${GAME_SETTINGS_FILE}" | awk -F'"' '{print $1}' | tr -d '\n')
        if [[ "${admin_password}" == "adminPasswordHere" ]]; then
            log_error ">>> Security thread detected: Please change the default server password. Aborting server start ..."
            exit 1
        fi
    fi
}
