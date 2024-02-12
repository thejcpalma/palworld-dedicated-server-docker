# shellcheck disable=SC2148,SC2012,SC1091

source "${PWD}"/includes/colors.sh
source "${PWD}"/includes/rcon.sh

### Backup functions

function create_backup() {
    date=$(date +%Y%m%d_%H%M%S)

    backup_file_name="saved-${date}.tar.gz"

    # RCON broadcast backup start
    rcon_broadcast_backup_start

    # Create backup
    if ! tar cfz "${BACKUP_PATH}/${backup_file_name}" -C "${GAME_PATH}/" "Saved" ; then
        rcon_broadcast_backup_failed
        echo_error ">>> Backup failed."
    else
        rcon_broadcast_backup_success
        echo_success ">>> Backup '${backup_file_name}' created successfully."
    fi 

    # If retention policy is enabled, clean old backups
    if [[ -n ${BACKUP_AUTO_CLEAN} ]] && [[ ${BACKUP_AUTO_CLEAN,,} == "true" ]] && [[ ${BACKUP_AUTO_CLEAN_AMOUNT_TO_KEEP} =~ ^[0-9]+$ ]]; then
        ls -1t "${BACKUP_PATH}"/saved-*.tar.gz | tail -n +$((BACKUP_AUTO_CLEAN_AMOUNT_TO_KEEP + 1)) | xargs -d '\n' rm -f --
    fi
}

function list_backups() {
    local num_backup_entries=${1}

    if [ -z "$(ls -A "${BACKUP_PATH}")" ]; then
        echo_warning ">> No backups in the backup directory '${BACKUP_PATH}'."
        exit 0
    fi

    files=$(ls -1t "${BACKUP_PATH}"/saved-*.tar.gz)
    total_file_count=$(echo "${files}" | wc -l)

    if [ -z "${num_backup_entries}" ]; then
        file_list=${files}
        echo_success ">>> Listing ${total_file_count} backup file(s)!"
    else
        file_list=$(echo "${files}" | head -n "${num_backup_entries}")
        echo_success ">>> Listing ${num_backup_entries} out of backup ${total_file_count} file(s)."
    fi

    for file in $file_list; do
        filename=$(basename "${file}")

        # get date from filename
        date_str=${filename#saved-}    # Remove 'saved-' prefix
        date_str=${date_str%.tar.gz}   # Remove '.tar.gz' suffix

        # Reformat the date string
        date=$(date -d "${date_str:0:8} ${date_str:9:2}:${date_str:11:2}:${date_str:13:2}" +'%Y-%m-%d %H:%M:%S')

        echo_info -n "${date} | " && echo_base "${filename}"
    done
}

function clean_backups() {
    local num_files_to_keep=${1}

    if [ -z "$(ls -A "${BACKUP_PATH}")" ]; then
        echo_info "> No files in the backup directory '${BACKUP_PATH}'. Exiting..."
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
        echo_success ">>> ${num_files_to_delete} backup(s) cleaned, keeping ${num_files_to_keep} backups(s)."
    else
        echo_info "> No backups to clean."
    fi
}

function restore_backup() {
    echo "Not implemented yet."
}
