# shellcheck disable=SC2148,SC1091
# IF Bash extension used:
# https://stackoverflow.com/a/13864829
# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02

source "${PWD}"/includes/config.sh
source "${PWD}"/includes/cron.sh
source "${PWD}"/includes/security.sh
source "${PWD}"/includes/webhook.sh
source "${PWD}"/includes/colors.sh
source "${PWD}"/includes/rcon.sh

steamcmd_dir="/home/steam/steamcmd"

# Function to install the gameserver
function install_server() {

    if [ -f "${GAME_ROOT}/PalServer.sh" ]; then
        return 0
    fi

    # Force a fresh install of all
    echo_warning ">> Doing a fresh install of the gameserver..."

    send_install_notification

    "${steamcmd_dir}"/steamcmd.sh +force_install_dir "${GAME_ROOT}" +login anonymous +app_update 2394010 validate +quit
    echo_success ">>> Done installing the gameserver"
}

# Function to update the gameserver
function update_server() {

    if [ "${ALWAYS_UPDATE_ON_START,,}" == "false" ]; then
        return 1
    fi

    if [[ -n ${STEAMCMD_VALIDATE_FILES} ]] && [[ ${STEAMCMD_VALIDATE_FILES,,} == "true" ]]; then
        echo_warning ">> Doing an update and validate of the gameserver files..."
        
        send_update_and_validate_notification

        "${steamcmd_dir}"/steamcmd.sh +force_install_dir "${GAME_ROOT}" +login anonymous +app_update 2394010 validate +quit
        echo_success ">>> Done updating and validating the gameserver files"

    else
        echo_warning ">> Doing an update of the gameserver files..."

        send_update_notification

        "${steamcmd_dir}"/steamcmd.sh +force_install_dir "${GAME_ROOT}" +login anonymous +app_update 2394010 +quit
        echo_success ">>> Done updating the gameserver files"
    fi
}

# Function to start the gameserver
function start_server() {
    echo_success ">>> Starting the gameserver"
    pushd "${GAME_ROOT}" > /dev/null || exit
    setup_configs
    START_OPTIONS=()
    if [[ -n ${COMMUNITY_SERVER} ]] && [[ ${COMMUNITY_SERVER,,} == "true" ]]; then
        echo_info "> Setting Community-Mode to enabled"
        START_OPTIONS+=("EpicApp=PalServer")
    fi
    if [[ -n ${MULTITHREAD_ENABLED} ]] && [[ ${MULTITHREAD_ENABLED,,} == "true" ]]; then
        echo_info "> Setting Multi-Core-Enhancements to enabled"
        START_OPTIONS+=("-useperfthreads" "-NoAsyncLoadingThread" "-UseMultithreadForDS")
    fi

    send_start_notification

    ./PalServer.sh "${START_OPTIONS[@]}"

    popd > /dev/null || exit
}

# Function to stop the gameserver
function stop_server() {
    echo_warning ">>> Stopping server..."

    rcon_broadcast_save_and_shutdown

    send_stop_notification

	kill -SIGTERM "$(pidof PalServer-Linux-Test)"
	tail --pid="$(pidof PalServer-Linux-Test)" -f 2>/dev/null
}

# Function to restart the gameserver
function restart_server() {
    local warn_minutes=${1}

    if [ "${RCON_ENABLED,,}" = true ]; then
        if [[ -n "${warn_minutes}" ]] && [[ "${warn_minutes}" =~ ^[0-9]+$ ]]; then
            send_start_notification "${warn_minutes}"
            rcon_restart "${warn_minutes}"
        else
            echo_error ">>> Unable to restart, warn_minutes is not a positive number: ${warn_minutes}"
        fi
    else
        echo_warning ">> Rebooting server without RCON might cause data loss! Feature is disabled."
    fi
}
