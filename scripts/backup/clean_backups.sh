# shellcheck disable=SC2148,SC2012
# shellcheck source=/dev/null

source "${SERVER_DIR}"/scripts/utils/logs.sh
source "${SERVER_DIR}"/scripts/rcon/aliases.sh

# Function: clean_backups
# Description: This function is used to clean up old backup files.
# Parameters: None
# Returns: None
function clean_backups() {
    local num_files_to_keep=${1}

    if [ -z "$(ls -A "${BACKUP_PATH}")" ]; then
        log_info "> No files in the backup directory '${BACKUP_PATH}'. Exiting..."
        exit 0
    fi

    files=$(ls -1t "${BACKUP_PATH}"/saved-*.tar.gz)
    files_to_delete=$(echo "${files}" | tail -n +$((num_files_to_keep + 1)))

    num_files=$(echo -n "${files}" | grep -c '^')
    num_files_to_delete=$(echo -ne "${files_to_delete}" | grep -c '^')

    if [[ ${num_files_to_delete} -gt 0 ]]; then
        echo "$files_to_delete" | xargs -d '\n' rm -f --
        if [[ ${num_files} -lt ${num_files_to_keep} ]]; then
            num_files_to_keep="${num_files}"
        fi
        log_success ">>> ${num_files_to_delete} backup(s) cleaned, keeping ${num_files_to_keep} backups(s)."
    else
        log_info "> No backups to clean."
    fi
}
