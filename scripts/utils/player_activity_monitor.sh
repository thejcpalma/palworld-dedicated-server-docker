#!/bin/bash

# shellcheck source=/dev/null
source "${SERVER_DIR}"/scripts/utils/logs.sh
source "${SERVER_DIR}"/scripts/rcon/aliases.sh
source "${SERVER_DIR}"/scripts/webhook/aliases.sh

# Variables to store the current and previous player lists
declare -a current_players
declare -a previous_players

# Format: name,playeruid,steamid
# Function to get the current player list
get_current_players() {
    # Execute the rcon command to get the list of players (supress stderr)
    player_list=$(rcon_get_player_list 2>/dev/null)

    # Remove the first line (header) from the player list
    player_list=$(echo "$player_list" | tail -n +2)

    # Remove lines with ',00000000,' from the player list
    player_list=$(echo "$player_list" | grep -v ',00000000,')

    # Convert the player list to an array
    IFS=$'\n' read -d '' -r -a current_players <<< "$player_list"
}


# Function to compare the current player list with the previous one
compare_players() {
    # Arrays to hold the players who have joined and left
    local joined_players=()
    local left_players=()

    # Convert the player lists to arrays of playeruids
    mapfile -t previous_uids < <(printf "%s\n" "${previous_players[@]}" | cut -d ',' -f 2)
    mapfile -t current_uids < <(printf "%s\n" "${current_players[@]}" | cut -d ',' -f 2)

    # Check for players who have left
    for i in "${!previous_uids[@]}"; do
        if ! [[ " ${current_uids[*]} " =~ ${previous_uids[i]} ]]; then
            left_players+=("$(echo "${previous_players[i]}" | cut -d ',' -f 1)")
        fi
    done

    # Check for players who have joined
    for i in "${!current_uids[@]}"; do
        if ! [[ " ${previous_uids[*]} " =~ ${current_uids[i]} ]]; then
            joined_players+=("$(echo "${current_players[i]}" | cut -d ',' -f 1)")
        fi
    done

    # Log each player who has joined
    if [ ${#joined_players[@]} -ne 0 ]; then
        for player in "${joined_players[@]}"; do
            log_info "> Player joined: '$player'"
            send_player_join_notification "$player"
        done
    fi

    # Log each player who has left
    if [ ${#left_players[@]} -ne 0 ]; then
        for player in "${left_players[@]}"; do
            log_info "> Player left: '$player'"
            send_player_leave_notification "$player"
        done
    fi
}

function start_player_activity_monitor() {

    if [ "${RCON_ENABLED,,}" != true ]; then
        log_error ">>> RCON is not enabled. Player monitoring only works with RCON! Aborting..."
        exit 1
    fi

    if [[ "${PLAYER_MONITOR_ENABLED,,}" != "true" ]]; then
        log_warning ">> Player monitor is disabled."
        exit 1
    fi

    if ! [[ "${PLAYER_MONITOR_INTERVAL}" =~ ^[1-9][0-9]*$ ]] || [ "${PLAYER_MONITOR_INTERVAL}" -lt 1 ]; then
        log_error ">>> Invalid 'PLAYER_MONITOR_INTERVAL' value: '${PLAYER_MONITOR_INTERVAL}' . Please provide a positive integer. Aborting..."
        exit 1
    fi

    log_success ">>> Player activity monitor started"

    # Main loop
    while true; do
        # Get the current player list
        get_current_players
            
        # Compare it with the previous one
        compare_players

        # Move the current player list to the previous player list
        previous_players=("${current_players[@]}")

        # Wait for a while before the next iteration
        sleep "${PLAYER_MONITOR_INTERVAL}"
    done

}
