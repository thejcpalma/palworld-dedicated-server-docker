# shellcheck disable=SC2148
# shellcheck source=/dev/null

source "${SERVER_DIR}"/scripts/utils/logs.sh
source "${SERVER_DIR}"/scripts/webhook/aliases.sh

steamcmd_dir="/home/steam/steamcmd"

# Function to install the gameserver
function install_server() {

    if [ -f "${GAME_ROOT}/PalServer.sh" ]; then
        return 0
    fi

    # Force a fresh install of all
    log_warning ">> Doing a fresh install of the gameserver..."

    send_install_notification

    "${steamcmd_dir}"/steamcmd.sh +force_install_dir "${GAME_ROOT}" +login anonymous +app_update "${APP_ID}" validate +quit
    log_success ">>> Done installing the gameserver"
}
