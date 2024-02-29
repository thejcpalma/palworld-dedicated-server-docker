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


    check_and_export "int"   "LanServerMaxTickRate" "${LANSERVERMAXTICKRATE}" "240"
    check_and_export "int"   "NetServerMaxTickRate" "${NETSERVERMAXTICKRATE}" "120"

    check_and_export "int"   "ConfiguredInternetSpeed" "${CONFIGUREDINTERNETSPEED}" "104857600"
    check_and_export "int"   "ConfiguredLanSpeed"      "${CONFIGUREDLANSPEED}"      "104857600"

    check_and_export "int"   "MaxClientRate"         "${MAXCLIENTRATE}"         "104857600"
    check_and_export "int"   "MaxInternetClientRate" "${MAXINTERNETCLIENTRATE}" "104857600"

    check_and_export "bool"  "bSmoothFrameRate"        "${BSMOOTHFRAMERATE}"        "true"
    check_and_export "bool"  "bUseFixedFrameRate"      "${BUSEFIXEDFRAMERATE}"      "false"
    check_and_export "float" "MinDesiredFrameRate"     "${MINDESIREDFRAMERATE}"     "60.000000"
    check_and_export "float" "FixedFrameRate"          "${FIXEDFRAMERATE}"          "120.000000"
    check_and_export "int"   "NetClientTicksPerSecond" "${NETCLIENTTICKSPERSECOND}" "120"

    check_and_export "int"   "TimeBetweenPurgingPendingKillObjects" "${TIMEBETWEENPURGINGPENDINGKILLOBJECTS}" "30"

    check_and_export "bool"  "rThreadedRendering" "${RTHREADEDRENDERING}" "true"
    check_and_export "bool"  "rThreadedPhysics"   "${RTHREADEDPHYSICS}"   "true"


    envsubst < "${GAME_ENGINE_FILE}" > "${GAME_ENGINE_FILE}.tmp" && mv "${GAME_ENGINE_FILE}.tmp" "${GAME_ENGINE_FILE}"

    log_success ">>> Finished setting up Engine.ini!"
}