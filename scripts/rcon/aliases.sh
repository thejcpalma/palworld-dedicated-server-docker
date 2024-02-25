# shellcheck disable=SC2148
# shellcheck source=/dev/null

source "${SERVER_DIR}"/scripts/webhook/aliases.sh

# Aliases to run RCON commands

### Player management aliases
function rcon_get_player_list() {
    if [ "${RCON_ENABLED,,}" != true ]; then
        log_error ">>> RCON is not enabled. Aborting RCON command ..."
        exit 1
    fi

    local player_list
    player_list=$(rconcli "ShowPlayers")
    echo -n "${player_list}"
}

function rcon_get_player_count() {
    if [ "${RCON_ENABLED,,}" != true ]; then
        log_error ">>> RCON is not enabled. Aborting RCON command ..."
        exit 1
    fi

    local player_list
    player_list=$(rconcli "ShowPlayers")
    echo -n "${player_list}" | wc -l
}

### Server management aliases
function rcon_save_and_shutdown() {
    if [ "${RCON_ENABLED,,}" != true ]; then
        log_error ">>> RCON is not enabled. Aborting RCON command ..."
        exit 1
    fi
    rconcli 'broadcast Server shutdown was requested'
    rconcli 'broadcast Saving before shutdown...'
    rconcli 'save'
    rconcli 'broadcast Saving done'
    
    backup_manager create
    
    rconcli "broadcast Server is shutting down now!"
    
    sleep 1

    rconcli "doExit"
}

# AUTO_RESTART_WARN_MINUTES or AUTO_UPDATE_WARN_MINUTES
function rcon_broadcast_restart() {
    if [ "${RCON_ENABLED,,}" != true ]; then
        log_error ">>> RCON is not enabled. Aborting RCON command ..."
        exit 1
    fi

    local restart_warn_minutes=${1}

    # Check if restart_warn_minutes is not set or is not a valid integer
    if [[ -z "${restart_warn_minutes}" ]] || ! [[ "${restart_warn_minutes}" =~ ^[0-9]+$ ]]; then
        log_error ">>> 'restart_warn_minutes' is not set or is not a valid integer"
        return 1
    fi

    if [[ restart_warn_minutes -gt 0 ]]; then

        rconcli "broadcast Server will restart in ${restart_warn_minutes} minute(s)"
        send_restart_notification "${restart_warn_minutes}"

        i="${restart_warn_minutes}"
        while ((i > 1)); do
            sleep "1m"
            if ((i <= 5)) || ((i % 5 == 0)); then
                rconcli "broadcast Server will restart in ${i} minute(s)"
            fi
            ((i--))
        done

        i=59
        while ((i > 0)); do
            sleep "1s"
            if ((i <= 10)) || ((i % 10 == 0)); then
                rconcli "broadcast Server will restart in ${i} second(s)"
            fi
            ((i--))
        done
    else
        rconcli "broadcast Server is restarting now!"
    fi

    backup_manager create
    sleep 1
    rconcli "broadcast Server is shutting down now!"
    send_restart_notification 0
}

function rcon_restart() {
    if [ "${RCON_ENABLED,,}" != true ]; then
        log_error ">>> RCON is not enabled. Aborting RCON command ..."
        exit 1
    fi

    local restart_warn_minutes=${1}

    players_online=$(rcon_get_player_count)
    if [ "${players_online}" -eq 0 ]; then
        log_info "> No players are online. Restarting the server now..."
        
        rcon_broadcast_restart 0
    else
        log_info "> There are ${players_online} players online. Restarting the server in ${restart_warn_minutes} minute(s)..."

        rcon_broadcast_restart "${restart_warn_minutes}"
    fi
    
    sleep 1
    rconcli "doExit"
}


### Backup management aliases
function rcon_broadcast_backup_start() {
    if [ "${RCON_ENABLED,,}" != true ]; then
        log_error ">>> RCON is not enabled. Aborting RCON command ..."
        exit 1
    fi

    rconcli "broadcast Saving world in 5 seconds"
    sleep 5
    rconcli 'broadcast Saving world...'
    rconcli 'save'
    rconcli 'broadcast Saving done'
    rconcli 'broadcast Creating backup'
}

function rcon_broadcast_backup_success() {
    if [ "${RCON_ENABLED,,}" != true ]; then
        log_error ">>> RCON is not enabled. Aborting RCON command ..."
        exit 1
    fi
    rconcli 'broadcast Backup done'
}

function rcon_broadcast_backup_failed() {
    if [ "${RCON_ENABLED,,}" != true ]; then
        log_error ">>> RCON is not enabled. Aborting RCON command ..."
        exit 1
    fi
    rconcli 'broadcast Backup failed'
}



