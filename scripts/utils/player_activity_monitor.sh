#!/bin/bash

# shellcheck source=/dev/null
source "${SERVER_DIR}"/scripts/utils/logs.sh
source "${SERVER_DIR}"/scripts/rcon/aliases.sh
source "${SERVER_DIR}"/scripts/webhook/aliases.sh

# Variables to store the current and previous player lists
declare -a current_players
declare -a previous_players

# An issue arises when players have special characters, commas or spaces in their name.
# The script uses commas to split the player information into separate fields.
# If a player's name contains a comma, it will be incorrectly split into separate fields.
# The same issue occurs with spaces when checking for players who have joined or left.
#
# To fix this, we assume that the player's name is everything before the last
# two commas (which separate the name, player UID, and Steam UID),
# and that the player UID and Steam UID will never contain any commas.
#
# To handle names with multibyte characters, we use 'awk'.
# 'awk' is used to split the lines on commas and extract the player UID (the second-to-last field)
# and the player name (all fields before the last two).
# This ensures that we always split on the last two commas.
# This approach correctly handles player names that contain commas, spaces, and multibyte characters.


# Format: name,playeruid,steamid
# Function to get the current player list
get_current_players() {
    # Clear the current players array
    current_players=()

    # Execute the rcon command to get the list of players (supress stderr)
    player_list=$(rcon_get_player_list 2>/dev/null)

    # Remove the first line (header) from the player list
    player_list=$(echo "$player_list" | tail -n +2)

    # Convert the player list to an array
    while IFS= read -r line; do
        # Skip lines that are empty or contain only commas
        if [[ "$line" =~ ^,*$ ]]; then
            continue
        fi
        # Skip lines that contain the UID '00000000'
        if [[ "$line" =~ ,00000000, ]]; then
            continue
        fi
        current_players+=("$line")
    done <<< "$player_list"
}

# Function to compare the current player list with the previous one
compare_players() {
    # Arrays to hold the players who have joined and left
    local joined_players=()
    local left_players=()

    # Convert the player lists to arrays of playeruids
    mapfile -t previous_uids < <(printf "%s\n" "${previous_players[@]}" | awk -F',' '{if (NF>1) print $(NF-1)}')
    mapfile -t current_uids < <(printf "%s\n" "${current_players[@]}" | awk -F',' '{if (NF>1) print $(NF-1)}')

    # Check for players who have left
    for i in "${!previous_uids[@]}"; do
        if ! [[ " ${current_uids[*]} " =~ ${previous_uids[i]} ]]; then
            left_players+=("${previous_players[i]}")
        fi
    done

    # Check for players who have joined
    for i in "${!current_uids[@]}"; do
        if ! [[ " ${previous_uids[*]} " =~ ${current_uids[i]} ]]; then
            joined_players+=("${current_players[i]}")
        fi
    done

    # Log each player who has joined
    if [ ${#joined_players[@]} -ne 0 ]; then
        for player in "${joined_players[@]}"; do
            local player_name
            player_name=$(echo "$player" | awk 'BEGIN{FS=OFS=","} {NF-=2; print $0}' | sed 's/,*$//')
            log_info -n "> Player joined: " && log_base "'$player_name'"
            player_name=$(echo "$player" | awk 'BEGIN{FS=OFS=","} {NF-=2; print $0}' | sed 's/,*$//' | tr '`' "'" | sed 's/\\\\/\\\\\\\\/g')
            send_player_join_notification "\`$player_name\`"
        done
    fi

    # Log each player who has left
    if [ ${#left_players[@]} -ne 0 ]; then
        for player in "${left_players[@]}"; do
            local player_name
            player_name=$(echo "$player" | awk 'BEGIN{FS=OFS=","} {NF-=2; print $0}' | sed 's/,*$//')
            log_info -n "> Player left: " && log_base "'$player_name'"
            player_name=$(echo "$player" | awk 'BEGIN{FS=OFS=","} {NF-=2; print $0}' | sed 's/,*$//' | tr '`' "'" | sed 's/\\\\/\\\\\\\\/g')
            send_player_leave_notification "\`$player_name\`"
        done
    fi

    # Replace the previous player list with the current player list
    previous_players=("${current_players[@]}")
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

        log_info -n "> Player count: " && log_base "'$(rcon_get_player_count)'"

        # Move the current player list to the previous player list
        previous_players=("${current_players[@]}")

        # Wait for a while before the next iteration
        sleep "${PLAYER_MONITOR_INTERVAL}"
    done

}
