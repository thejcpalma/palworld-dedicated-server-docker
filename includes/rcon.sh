# shellcheck disable=SC2148

# Aliases to run RCON commands


function rcon_broadcast_save_and_shutdown() {
    rconcli 'broadcast Server-shutdown-was-requested'
    rconcli 'broadcast Saving-before-shutdown...'
    rconcli 'save'
    rconcli 'broadcast Saving-done'
    rconcli 'broadcast Server-shutting-down...'
    sleep 5
}
# AUTO_RESTART_WARN_MINUTES or AUTO_UPDATE_WARN_MINUTES
function rcon_broadcast_restart() {
    local restart_warn_minutes=${1}

    # Check if restart_warn_minutes is not set or is not a valid integer
    if [[ -z "${restart_warn_minutes}" ]] || ! [[ "${restart_warn_minutes}" =~ ^[0-9]+$ ]]; then
        echo "Error: restart_warn_minutes is not set or is not a valid integer"
        return 1
    fi

    rconcli "broadcast Server-will-restart-in-${restart_warn_minutes}-minute(s)"

    i="${restart_warn_minutes}"
    while ((i > 1)); do
        sleep "1m"
        if ((i <= 5)) || ((i % 5 == 0)); then
            rconcli "broadcast Server-will-reboot-in-${i}-minute(s)"
        fi
        ((i--))
    done

    i=59
    while ((i > 0)); do
        sleep "1s"
        if ((i <= 5)) || ((i % 10 == 0)); then
            rconcli "broadcast Server-will-restart-in-${i}-second(s)"
        fi
        ((i--))
    done

    rconcli "broadcast Server-is-shutting-down-now!"
    rconcli save
    sleep 1
    backupmanager create
    sleep 1
}

function rcon_restart() {
    local restart_warn_minutes=${1}

    if [ "$(rcon_get_player_count)" = "0" ]; then
        echo_info "> No players are online. Restarting the server now..."
        rcon_broadcast_restart 0
    else
        rcon_broadcast_restart "${restart_warn_minutes}"
    fi
    sleep 1
    rconcli "shutdown 1"
}

function rcon_broadcast_backup_start() {
    time=$(date '+%H:%M:%S')

    rconcli "broadcast ${time}-Saving-in-5-seconds"
    sleep 5
    rconcli 'broadcast Saving-world...'
    rconcli 'save'
    rconcli 'broadcast Saving-done'
    rconcli 'broadcast Creating-backup'
}

function rcon_broadcast_backup_success() {
    rconcli 'broadcast Backup-done'
}

function rcon_broadcast_backup_failed() {
    rconcli 'broadcast Backup-failed'
}

function rcon_get_player_count() {
    local player_list
    if [ "${RCON_ENABLED,,}" != true ]; then
        echo 0
        return 0
    fi
    player_list=$(rconcli "ShowPlayers")
    echo -n "${player_list}" | wc -l
}
