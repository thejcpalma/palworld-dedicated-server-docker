# shellcheck disable=SC2148
# Function to generate JSON data for the Discord message
# Webpage for COLOR-Calculation - https://www.spycolor.com/
# IMPORTANT: Don't use Hex-Colors! Go to the page search for the Hex-Color.
# After that add the DECIMAL-Representation to the color field or it will break!


### Aliases to use in scripts
function send_start_notification() {
  send_webhook_notification "$WEBHOOK_START_TITLE" "$WEBHOOK_START_DESCRIPTION" "$WEBHOOK_START_COLOR"
}

function send_stop_notification() {
  send_webhook_notification "$WEBHOOK_STOP_TITLE" "$WEBHOOK_STOP_DESCRIPTION" "$WEBHOOK_STOP_COLOR"
}

function send_install_notification() {
  send_webhook_notification "$WEBHOOK_INSTALL_TITLE" "$WEBHOOK_INSTALL_DESCRIPTION" "$WEBHOOK_INSTALL_COLOR"
}

function send_update_notification() {
  send_webhook_notification "$WEBHOOK_UPDATE_TITLE" "$WEBHOOK_UPDATE_DESCRIPTION" "$WEBHOOK_UPDATE_COLOR"
}

function send_update_and_validate_notification() {
  send_webhook_notification "$WEBHOOK_UPDATE_VALIDATE_TITLE" "$WEBHOOK_UPDATE_VALIDATE_DESCRIPTION" "$WEBHOOK_UPDATE_VALIDATE_COLOR"
}

function send_restart_notification() {
  send_webhook_notification "$WEBHOOK_RESTART_TITLE" "$WEBHOOK_RESTART_DESCRIPTION" "$WEBHOOK_RESTART_COLOR"
}

function send_auto_update_start_notification() {
  local message=${1}
  send_webhook_notification "Server Auto Update Started" "${message}" "$WEBHOOK_UPDATE_COLOR"
}

function send_auto_update_fail_notification() {
  local fail_message="$1"
  send_webhook_notification "Server Auto Update Failed" "Reason: $fail_message" "$WEBHOOK_UPDATE_COLOR"
}


### Webhook Functions

# Function to send a notification to a webhook
function send_webhook_notification() {

  if ! check_webhook_enabled; then
    return
  fi

  local notification_title="$1"
  local notification_description="$2"
  local notification_color_code="$3"

  # Generate the JSON data
  data=$(generate_post_data "$notification_title" "$notification_description" "$notification_color_code")

  # Debug Curl
  #curl --ssl-no-revoke -H "Content-Type: application/json" -X POST -d "$data" "$WEBHOOK_URL"
  # Prod Curl
  curl --silent --ssl-no-revoke -H "Content-Type: application/json" -X POST -d "$data" "$WEBHOOK_URL"
}

# Function to generate JSON data for the Discord message
generate_post_data() {
  cat <<EOF
{
  "content": "",
  "embeds": [{
    "title": "$1",
    "description": "$2",
    "color": $3
  }]
}
EOF
}

# Function to check if the webhook is enabled
function check_webhook_enabled() {
  [[ -n "${WEBHOOK_ENABLED}" && "${WEBHOOK_ENABLED,,}" == "true" ]]
}
