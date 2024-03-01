# shellcheck disable=SC2148,SC2012
# shellcheck source=/dev/null

source "${SERVER_DIR}"/scripts/utils/logs.sh
source "${SERVER_DIR}"/scripts/rcon/aliases.sh

# Function: list_backups
# Description: This function lists all the backups available.
# Parameters: None
# Returns: None
function list_backups() {
    local num_backup_entries=${1}

    if [ -z "$(ls -A "${BACKUP_PATH}")" ]; then
        log_warning ">> No backups in the backup directory '${BACKUP_PATH}'."
        exit 0
    fi

    files=$(ls -1t "${BACKUP_PATH}"/saved-*.tar.gz)
    total_file_count=$(echo "${files}" | wc -l)

    if [ -z "${num_backup_entries}" ]; then
        file_list=${files}
        log_success ">>> Listing ${total_file_count} backup file(s)!"
    else
        file_list=$(echo "${files}" | head -n "${num_backup_entries}")
        log_success ">>> Listing ${num_backup_entries} out of backup ${total_file_count} file(s)."
    fi

    for file in $file_list; do
        filename=$(basename "${file}")

        # get date from filename
        date_str=${filename#saved-}    # Remove 'saved-' prefix
        date_str=${date_str%.tar.gz}   # Remove '.tar.gz' suffix

        # Reformat the date string
        date=$(date -d "${date_str:0:8} ${date_str:9:2}:${date_str:11:2}:${date_str:13:2}" +'%Y-%m-%d %H:%M:%S')

        log_info -n "${date} | " && log_base "${filename}"
    done
}
