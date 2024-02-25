# shellcheck disable=SC2148

# shellcheck source=/dev/null
source "${SERVER_DIR}"/scripts/webhook/send_webhook_notification.sh

# Aliases to use in scripts

### Server notifications

function send_start_notification() {
  send_webhook_notification "${WEBHOOK_START_TITLE}" "${WEBHOOK_START_DESCRIPTION}" "${WEBHOOK_START_COLOR}"
}

function send_stop_notification() {
  send_webhook_notification "${WEBHOOK_STOP_TITLE}" "${WEBHOOK_STOP_DESCRIPTION}" "${WEBHOOK_STOP_COLOR}"
}

function send_install_notification() {
  send_webhook_notification "${WEBHOOK_INSTALL_TITLE}" "${WEBHOOK_INSTALL_DESCRIPTION}" "${WEBHOOK_INSTALL_COLOR}"
}

function send_update_notification() {
  send_webhook_notification "${WEBHOOK_UPDATE_TITLE}" "${WEBHOOK_UPDATE_DESCRIPTION}" "${WEBHOOK_UPDATE_COLOR}"
}

function send_update_and_validate_notification() {
  send_webhook_notification "${WEBHOOK_UPDATE_VALIDATE_TITLE}" "${WEBHOOK_UPDATE_VALIDATE_DESCRIPTION}" "${WEBHOOK_UPDATE_VALIDATE_COLOR}"
}

function send_restart_notification() {
  local restart_time=${1}
  # Replace the placeholder with the actual restart time using parameter expansion
  send_webhook_notification "${WEBHOOK_RESTART_TITLE}" "${WEBHOOK_RESTART_DESCRIPTION/X_MINUTES/$restart_time}" "${WEBHOOK_RESTART_COLOR}"
}


### Player notifications

function send_player_join_notification() {
  local player_name="$1"
  send_webhook_notification "${WEBHOOK_PLAYER_JOIN_TITLE}" "${WEBHOOK_PLAYER_JOIN_DESCRIPTION/PLAYER_NAME/$player_name}" "${WEBHOOK_PLAYER_JOIN_COLOR}"
}

function send_player_leave_notification() {
  local player_name="$1"
  send_webhook_notification "${WEBHOOK_PLAYER_LEAVE_TITLE}" "${WEBHOOK_PLAYER_LEAVE_DESCRIPTION/PLAYER_NAME/$player_name}" "${WEBHOOK_PLAYER_LEAVE_COLOR}"
}
