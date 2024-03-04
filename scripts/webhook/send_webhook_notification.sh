# shellcheck disable=SC2148
# Function to generate JSON data for the Discord message
# Webpage for COLOR-Calculation - https://www.spycolor.com/
# IMPORTANT: Don't use Hex-Colors! Go to the page search for the Hex-Color.
# After that add the DECIMAL-Representation to the color field or it will break!

# Function to check if the webhook is enabled
function check_webhook_enabled() {
  [[ -n "${WEBHOOK_ENABLED}" && "${WEBHOOK_ENABLED,,}" == "true" ]]
}


# Function to send a notification to a webhook
function send_webhook_notification() {

  if ! check_webhook_enabled; then
    return
  fi

  local notification_title="$1"
  local notification_description="$2"
  local notification_color_code="$3"
  local additional_info_field_name="$4"
  local additional_info_field_value="$5"

  # Generate the JSON data
  data=$(generate_post_data "$notification_title" "$notification_description" "$notification_color_code" "$additional_info_field_name" "$additional_info_field_value")

  # Debug Curl
  #curl --ssl-no-revoke -H "Content-Type: application/json" -X POST -d "$data" "$WEBHOOK_URL"
  # Prod Curl
  curl -sfSL --ssl-no-revoke -H "Content-Type: application/json" -X POST -d "$data" "$WEBHOOK_URL"
}

# Function to generate JSON data for the Discord message
generate_post_data() {
  if [ -z "$4" ] && [ -z "$5" ]; then
    jq -n \
      --arg title "$1" \
      --arg description "$2" \
      --argjson color "$3" \
      '{
        "content": "",
        "embeds": [{
          "title": $title,
          "description": $description,
          "color": $color
        }]
      }'
elif [ -n "$4" ] && [ -n "$5" ]; then
    local additional_info_field_name_json
    local additional_info_field_value_json

    additional_info_field_name_json=$(echo -e "$4")
    additional_info_field_value_json=$(echo -e "$5")

    jq -n \
      --arg title "$1" \
      --arg description "$2" \
      --argjson color "$3" \
      --arg additional_info_field_name "$additional_info_field_name_json" \
      --arg additional_info_field_value "$additional_info_field_value_json" \
      '{
        "content": "",
        "embeds": [{
          "title": $title,
          "description": $description,
          "color": $color,
          "fields": [{
            "name": $additional_info_field_name,
            "value": $additional_info_field_value,
          }]
        }]
      }'
  else
    log_error ">>> Invalid arguments for 'generate_post_data'"
  fi
}

# generate_post_data() {
#   cat <<EOF
# {
#   "content": "",
#   "embeds": [{
#     "title": "$1",
#     "description": "$2",
#     "color": $3
#   }]
# }
# EOF
# }