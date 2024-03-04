# shellcheck disable=SC2148
# shellcheck source=/dev/null

source "${SERVER_DIR}"/scripts/utils/logs.sh
source "${SERVER_DIR}"/scripts/config/setup_palworld_settings_ini.sh
source "${SERVER_DIR}"/scripts/config/setup_engine_ini.sh
source "${SERVER_DIR}"/scripts/config/setup_rcon_yaml.sh


# Function to setup the server configs
function setup_configs() {
    if [[ -n ${SERVER_SETTINGS_MODE} ]] && [[ ${SERVER_SETTINGS_MODE,,} == "auto" ]]; then
        log_warning ">> 'SERVER_SETTINGS_MODE' is set to '${SERVER_SETTINGS_MODE}', environment variables used to configure the server!"
        setup_engine_ini
        setup_palworld_settings_ini
    else
        log_warning ">> 'SERVER_SETTINGS_MODE' is set to '${SERVER_SETTINGS_MODE}', environment variables NOT used to configure the server!"

        # Copy default-config, which comes with SteamCMD to gameserver save location
        cp "${GAME_ROOT}/DefaultPalWorldSettings.ini" "${GAME_SETTINGS_FILE}"

        log_warning ">> File '${GAME_ENGINE_FILE}' has to be manually set by user."
        log_warning ">> File '${GAME_SETTINGS_FILE}' has to be manually set by user."
    fi
    setup_rcon_yaml
}
