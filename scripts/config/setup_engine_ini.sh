#shellcheck disable=SC2148
#shellcheck source=/dev/null

source "${SERVER_DIR}"/scripts/utils/logs.sh
source "${SERVER_DIR}"/scripts/config/utils.sh

function setup_engine_ini() {
    # Setup the engine config file
    log_warning ">> Setting up Engine.ini ..."

    # Create the config directory if it doesn't exist
    mkdir -p "${GAME_CONFIG_PATH}/"

    template_file=${SERVER_DIR}/scripts/config/templates/Engine.ini.template

    cp "${template_file}" "${GAME_ENGINE_FILE}"


    check_and_export "int"   "LanServerMaxTickRate" "${LAN_SERVER_MAX_TICK_RATE}" "120"
    check_and_export "int"   "NetServerMaxTickRate" "${NET_SERVER_MAX_TICK_RATE}" "120"

    check_and_export "int"   "ConfiguredInternetSpeed" "${CONFIGURED_INTERNET_SPEED}" "104857600"
    check_and_export "int"   "ConfiguredLanSpeed"      "${CONFIGURED_LAN_SPEED}"      "104857600"

    check_and_export "int"   "MaxClientRate"         "${MAX_CLIENT_RATE}"          "104857600"
    check_and_export "int"   "MaxInternetClientRate" "${MAX_INTERNET_CLIENT_RATE}" "104857600"

    check_and_export "bool"  "bSmoothFrameRate"        "${SMOOTH_FRAME_RATE}"           "true"
    check_and_export "float" "SmoothedFrameRateRangeLowerBound"  "${SMOOTH_FRAME_RATE_UPPER_BOUND}"  "30.000000"
    check_and_export "float" "SmoothedFrameRateRangeUpperBound"  "${SMOOTH_FRAME_RATE_LOWER_BOUND}"  "120.000000"
    check_and_export "float" "MinDesiredFrameRate"     "${MIN_DESIRED_FRAME_RATE}"      "60.000000"
    check_and_export "bool"  "bUseFixedFrameRate"      "${USE_FIXED_FRAME_RATE}"        "false"
    check_and_export "float" "FixedFrameRate"          "${FIXED_FRAME_RATE}"            "120.000000"
    check_and_export "int"   "NetClientTicksPerSecond" "${NET_CLIENT_TICKS_PER_SECOND}" "120"

    check_and_export "int"   "TimeBetweenPurgingPendingKillObjects" "${TIME_BETWEEN_PURGING_PENDING_KILL_OBJECTS}" "30"

    check_and_export "bool"  "rThreadedRendering" "${THREADED_RENDERING}" "true"
    check_and_export "bool"  "rThreadedPhysics"   "${THREADED_PHYSICS}"   "true"

    envsubst < "${GAME_ENGINE_FILE}" > "${GAME_ENGINE_FILE}.tmp" && mv "${GAME_ENGINE_FILE}.tmp" "${GAME_ENGINE_FILE}"

    log_success ">>> Finished setting up Engine.ini!"
}