# shellcheck disable=SC2148,SC2012
# shellcheck source=/dev/null

source "${SERVER_DIR}"/scripts/utils/logs.sh
source "${SERVER_DIR}"/scripts/rcon/aliases.sh

# Function: create_backup
# Description: This function is used to create a backup of the Palworld dedicated server.
# Parameters: None
# Returns: None
function create_backup() {
    date=$(date +%Y%m%d_%H%M%S)

    backup_file_name="saved-${date}.tar.gz"

    # RCON broadcast backup start
    rcon_broadcast_backup_start

    # Create backup
    if ! tar cfz "${BACKUP_PATH}/${backup_file_name}" -C "${GAME_PATH}/" "Saved" ; then
        rcon_broadcast_backup_failed
        log_error ">>> Backup failed."
    else
        rcon_broadcast_backup_success
        log_success ">>> Backup '${backup_file_name}' created successfully."
    fi 

    # If retention policy is enabled, clean old backups
    if [[ -n ${BACKUP_AUTO_CLEAN} ]] && [[ ${BACKUP_AUTO_CLEAN,,} == "true" ]] && [[ ${BACKUP_AUTO_CLEAN_AMOUNT_TO_KEEP} =~ ^[0-9]+$ ]]; then
        ls -1t "${BACKUP_PATH}"/saved-*.tar.gz | tail -n +$((BACKUP_AUTO_CLEAN_AMOUNT_TO_KEEP + 1)) | xargs -d '\n' rm -f --
    fi
}
