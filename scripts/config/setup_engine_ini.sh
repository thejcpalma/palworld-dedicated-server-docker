#shellcheck disable=SC2148
#shellcheck source=/dev/null

source "${SERVER_DIR}"/scripts/utils/logs.sh
source "${SERVER_DIR}"/scripts/config/utils.sh

function setup_engine_ini() {
    # Setup the engine config file

    # Create the config directory if it doesn't exist
    mkdir -p "${GAME_CONFIG_PATH}/"

    if [[ -n ${ENGINE_CONFIG_MODE} ]] && { [[ ${ENGINE_CONFIG_MODE,,} == "full" ]] || [[ ${ENGINE_CONFIG_MODE,,} == "modular" ]]; }; then
        log_warning ">> 'ENGINE_CONFIG_MODE' is set to '${ENGINE_CONFIG_MODE}', environment variables will be used to configure the server!"
        log_warning ">> Setting up Engine.ini ..."

        template_file=${SERVER_DIR}/scripts/config/templates/Engine.ini.template

        cp "${template_file}" "${GAME_ENGINE_FILE}.tmp"

        check_and_export_if_not_empty "int"   "LanServerMaxTickRate" "${LAN_SERVER_MAX_TICK_RATE}" "120"
        check_and_export_if_not_empty "int"   "NetServerMaxTickRate" "${NET_SERVER_MAX_TICK_RATE}" "120"

        check_and_export_if_not_empty "int"   "ConfiguredInternetSpeed" "${CONFIGURED_INTERNET_SPEED}" "104857600"
        check_and_export_if_not_empty "int"   "ConfiguredLanSpeed"      "${CONFIGURED_LAN_SPEED}"      "104857600"

        check_and_export_if_not_empty "int"   "MaxClientRate"         "${MAX_CLIENT_RATE}"          "104857600"
        check_and_export_if_not_empty "int"   "MaxInternetClientRate" "${MAX_INTERNET_CLIENT_RATE}" "104857600"

        check_and_export_if_not_empty "bool"  "bSmoothFrameRate"        "${SMOOTH_FRAME_RATE}"           "true"
        check_and_export_if_not_empty "float" "SmoothedFrameRateRangeLowerBound"  "${SMOOTH_FRAME_RATE_UPPER_BOUND}"  "30.000000"
        check_and_export_if_not_empty "float" "SmoothedFrameRateRangeUpperBound"  "${SMOOTH_FRAME_RATE_LOWER_BOUND}"  "120.000000"
        check_and_export_if_not_empty "float" "MinDesiredFrameRate"     "${MIN_DESIRED_FRAME_RATE}"      "60.000000"
        check_and_export_if_not_empty "bool"  "bUseFixedFrameRate"      "${USE_FIXED_FRAME_RATE}"        "false"
        check_and_export_if_not_empty "float" "FixedFrameRate"          "${FIXED_FRAME_RATE}"            "120.000000"
        check_and_export_if_not_empty "int"   "NetClientTicksPerSecond" "${NET_CLIENT_TICKS_PER_SECOND}" "120"

        check_and_export_if_not_empty "int"   "TimeBetweenPurgingPendingKillObjects" "${TIME_BETWEEN_PURGING_PENDING_KILL_OBJECTS}" "30"

        check_and_export_if_not_empty "bool"  "rThreadedRendering" "${THREADED_RENDERING}" "true"
        check_and_export_if_not_empty "bool"  "rThreadedPhysics"   "${THREADED_PHYSICS}"   "true"

        envsubst < "${GAME_ENGINE_FILE}.tmp" > "${GAME_ENGINE_FILE}" && rm "${GAME_ENGINE_FILE}.tmp"

        log_success ">>> Finished setting up Engine.ini!"

        trim_file "${GAME_ENGINE_FILE}"
    else
        log_warning ">> 'ENGINE_CONFIG_MODE' is set to '${ENGINE_CONFIG_MODE}', skipping '${GAME_ENGINE_FILE}' configuration!"
    fi

}