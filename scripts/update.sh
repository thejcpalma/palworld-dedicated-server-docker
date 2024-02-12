#!/bin/bash

source "${PWD}/includes/colors.sh"
source "${PWD}/includes/webhook.sh"
source "${PWD}/includes/rcon.sh"

# Check if the always auto update on boot feature is enabled
if [ "${ALWAYS_UPDATE_ON_BOOT}" = false ]; then
    error_message="ALWAYS_UPDATE_ON_BOOT is disabled. Auto updating feature is disabled"
    echo_warning ">> ${error_message}"
    send_auto_update_fail_notification "${error_message}"
    exit 0
fi

temp_file=$(mktemp)
http_code=$(curl https://api.steamcmd.net/v1/info/2394010 --output "$temp_file" --silent --location --write-out "%{http_code}")

CURRENT_MANIFEST=$(awk '/manifest/{count++} count==2 {print $2; exit}' /palworld/steamapps/appmanifest_2394010.acf)
TARGET_MANIFEST=$(grep -Po '"2394012".*"gid": "\d+"' <"$temp_file" | sed -r 's/.*("[0-9]+")$/\1/')

rm "$temp_file"

# Check if the server is reachable
if [ "$http_code" -ne 200 ]; then
    error_message="There was a problem reaching the Steam api. Unable to check for updates!"
    echo_warning ">> ${error_message}"
    send_auto_update_fail_notification "${error_message}"
    exit 1
fi

# Check if the server response contains the expected ManifestID
if [ -z "$TARGET_MANIFEST" ]; then
    error_message="The server response does not contain the expected ManifestID. Unable to check for updates!"
    echo_warning ">> ${error_message}"
    send_auto_update_fail_notification "${error_message}"
    exit 1
fi

# Check if the server is up to date
if [ "$CURRENT_MANIFEST" != "$TARGET_MANIFEST" ]; then
    # Only update if RCON is enabled
    if [ "${RCON_ENABLED,,}" = true ]; then
        message="New build was found. Updating the server from $CURRENT_MANIFEST to $TARGET_MANIFEST."
        echo_warning ">> ${message}"
        send_auto_update_start_notification "${message}"        

        message="Server will update in ${AUTO_UPDATE_WARN_MINUTES} minutes!"
        echo_warning ">> ${message}"
        send_auto_update_start_notification "${message}"

        rm /palworld/steamapps/appmanifest_2394010.acf

        rcon_restart "${AUTO_UPDATE_WARN_MINUTES}"
    else
        error_message="An update is available, however auto updating without RCON is not supported!"
        echo_warning ">> ${error_message}"
        send_auto_update_fail_notification
    fi
else
    echo_info "> The server is up-to-date!"
fi