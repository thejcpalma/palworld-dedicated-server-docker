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
#
# Special chars also break RCON usage when fecthing Steam UDIs
# We get a Steam UID with 16 characters, but we need 17 to be valid
# We can add a number at the end of the Steam UID to get a valid one
# but we don't have a way to know which one is the correct

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

check_steam_profile() {
    local clean_output=false
    if [ "$1" = "clean" ]; then
        clean_output=true
        shift
    fi

    link="https://steamcommunity.com/profiles/$1"
    content=$(curl -sL "${link}")
    if echo "$content" | grep -q 'This user has not yet set up their Steam Community profile.'; then
        return
    else
        profile_name=$(echo "$content" | grep -oPm 1 '(?<=<span class="actual_persona_name">).*(?=</span>)')
        if [[ $clean_output = true ]]; then
            echo "- [${profile_name}](<${link}>)"
        else
            log_info -n "> Profile name is: " && log_base -n "${profile_name}" && log_info -n " | Profile link: " && log_base "${link}"
        fi
    fi
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
            local player_uid
            local player_steam_uid
            local possible_steam_ids

            player_name=$(echo "$player" | awk 'BEGIN{FS=OFS=","} {NF-=2; print $0}' | sed 's/,*$//')
            player_uid=$(echo "$player" | awk 'BEGIN{FS=OFS=","} {print $(NF-1)}')
            player_steam_uid=$(echo "$player" | awk 'BEGIN{FS=OFS=","} {print $NF}')

            log_info -n "> Player joined: " && log_base -n "'$player_name' " && \
            log_info -n "| UID: " && log_base -n "$player_uid" && \
            log_info -n "| Steam ID: " && log_base "$player_steam_uid"

            if [ "${#player_steam_uid}" -ne 17 ]; then
                log_warning ">> Invalid Steam ID (Player name has special characters!) - Should have 17 digits but has ${#player_steam_uid} digits!"
                log_warning ">> Possible Steam IDs:"
                for i in {0..9}; do
                    result=$(check_steam_profile "${player_steam_uid}${i}")
                    if [[ -n "$result" ]]; then
                        echo "$result"
                        possible_steam_ids+="$(check_steam_profile "clean" "${player_steam_uid}${i}")\n"
                    fi
                done
                player_steam_uid="###INVALID_STEAM_UID###"
            fi
            player_name=$(echo "$player" | awk 'BEGIN{FS=OFS=","} {NF-=2; print $0}' | sed 's/,*$//' | tr '`' "'" | sed 's/\\\\/\\\\\\\\/g')
            send_player_join_notification "\`$player_name\`" "$player_uid" "$player_steam_uid" "$possible_steam_ids"
        done
    fi

    # Log each player who has left
    if [ ${#left_players[@]} -ne 0 ]; then
        for player in "${left_players[@]}"; do
            local player_name
            local player_uid
            local player_steam_uid
            local possible_steam_ids

            player_name=$(echo "$player" | awk 'BEGIN{FS=OFS=","} {NF-=2; print $0}' | sed 's/,*$//')
            player_uid=$(echo "$player" | awk 'BEGIN{FS=OFS=","} {print $(NF-1)}')
            player_steam_uid=$(echo "$player" | awk 'BEGIN{FS=OFS=","} {print $NF}')

            log_info -n "> Player left: " && log_base -n "'$player_name' " && \
            log_info -n "| UID: " && log_base -n "$player_uid" && \
            log_info -n "| Steam ID: " && log_base "$player_steam_uid"

            if [ "${#player_steam_uid}" -ne 17 ]; then
                log_warning ">> Invalid Steam ID (Player name has special characters!) - Should have 17 digits but has ${#player_steam_uid} digits!"
                log_warning ">> Possible Steam IDs:"
                for i in {0..9}; do
                    result=$(check_steam_profile "${player_steam_uid}${i}")
                    if [[ -n "$result" ]]; then
                        echo "$result"
                        possible_steam_ids+="$(check_steam_profile "clean" "${player_steam_uid}${i}")\n"
                    fi
                done
                player_steam_uid="###INVALID_STEAM_UID###"
            fi
            player_name=$(echo "$player" | awk 'BEGIN{FS=OFS=","} {NF-=2; print $0}' | sed 's/,*$//' | tr '`' "'" | sed 's/\\\\/\\\\\\\\/g')
            send_player_leave_notification "\`$player_name\`" "$player_uid" "$player_steam_uid" "$possible_steam_ids"
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

        # Move the current player list to the previous player list
        previous_players=("${current_players[@]}")

        # Wait for a while before the next iteration
        sleep "${PLAYER_MONITOR_INTERVAL}"
    done

}
