# shellcheck disable=SC2148,SC1091
source "${PWD}"/includes/colors.sh

function check_for_default_credentials() {
    echo_info "> Checking for existence of default credentials"
    if [[ -n ${ADMIN_PASSWORD} ]] && [[ ${ADMIN_PASSWORD} == "adminPasswordHere" ]]; then
        echo_error ">>> Security thread detected: Please change the default admin password. Aborting server start ..."
        exit 1
    fi
    if [[ -n ${SERVER_PASSWORD} ]] && [[ ${SERVER_PASSWORD} == "serverPasswordHere" ]]; then
        echo_error ">>> Security thread detected: Please change the default server password. Aborting server start ..."
        exit 1
    fi
    if [[ "${SERVER_SETTINGS_MODE,,}" == "manual" ]] && [[ -s "${GAME_SETTINGS_FILE}" ]]; then
        admin_password=$(awk -F'AdminPassword="' '{print $2}' "${GAME_SETTINGS_FILE}" | awk -F'"' '{print $1}' | tr -d '\n')
        if [[ "${admin_password}" == "adminPasswordHere" ]]; then
            echo_error ">>> Security thread detected: Please change the default server password. Aborting server start ..."
        fi
    fi
}
