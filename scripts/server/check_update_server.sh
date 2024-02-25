# shellcheck disable=SC2148
# shellcheck source=/dev/null

source "${SERVER_DIR}"/scripts/utils/logs.sh

# Function: check_update_server
# Description: Checks if a new update is available for the server.
# Parameters: None
# Returns: 0 (true) if a new update is available
#          1 (false) if server is up-to-date
function check_update_server() {
    temp_file=$(mktemp)
    http_code=$(curl https://api.steamcmd.net/v1/info/"${APP_ID}" --output "$temp_file" --silent --location --write-out "%{http_code}")

    CURRENT_MANIFEST=$(awk '/manifest/{count++} count==2 {print $2; exit}' /palworld/steamapps/appmanifest_"${APP_ID}".acf)
    TARGET_MANIFEST=$(grep -Po '"2394012".*"gid": "\d+"' <"$temp_file" | sed -r 's/.*("[0-9]+")$/\1/')

    rm "$temp_file"

    # Check if the server is reachable
    if [ "$http_code" -ne 200 ]; then
        log_warning ">> There was a problem reaching the Steam API. Unable to check for updates!"
        exit 1
    fi

    # Check if the server response contains the expected ManifestID
    if [ -z "$TARGET_MANIFEST" ]; then
        log_warning ">> The server response does not contain the expected ManifestID. Unable to check for updates!"
        exit 1
    fi

    # Check if the server is up to date
    if [ "$CURRENT_MANIFEST" != "$TARGET_MANIFEST" ]; then
        log_warning ">> New build was found! Current: '$CURRENT_MANIFEST'; New: '$TARGET_MANIFEST' ."
        return 0
    else
        log_info "> The server is up-to-date!"
        return 1
    fi
}
