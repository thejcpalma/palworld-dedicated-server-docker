#!/bin/bash
# shellcheck disable=SC2012,SC2004
# shellcheck source=/dev/null


source "${SERVER_DIR}"/scripts/utils/logs.sh
source "${SERVER_DIR}"/scripts/rcon/aliases.sh
for file in "${SERVER_DIR}"/scripts/backup/*.sh; do
    source "$file"
done


# Environment variables for reference
# BACKUP_PATH: Directory where the backup files are stored
# GAME_PATH: Directory where the game save files are stored
# GAME_SAVE_PATH: Directory where the game save files are stored
# BACKUP_AUTO_CLEAN: Enable or disable the automatic backup cleaning
# BACKUP_AUTO_CLEAN_AMOUNT_TO_KEEP: Number of backup files to keep

function print_usage() {
    script_name=$(basename "$0")
    echo "Usage:"
    echo "  ${script_name} create"
    echo "  ${script_name} list [number_of_entries]"
    echo "  ${script_name} clean [number_to_keep]"
    echo "  ${script_name} help"
    echo ""
    echo "Options:"
    echo "  create                        Create a backup"
    echo "  list [number_to_list]         List the backup files. If number_to_list isn't"
    echo "                                provided, all backup files will be listed"
    echo "  clean [number_to_keep]        Deletes old backups keeping the number_to_keep"
    echo "                                most recent backups. If number_to_keep isn't"
    echo "                                provided, keep 30 most recent backups"
    echo "  help                          Display this help message"
    echo ""
    echo "Arguments:"
    echo "  number_to_list (optional)     The number of backup files to list."
    echo "                                If not provided, all backup files will be listed"
    echo "  number_to_keep (optional)     The number of the most recent backup files to keep."
    echo "                                If not provided, the value of the BACKUP_AUTO_CLEAN_AMOUNT_TO_KEEP"
    echo "                                environment variable will be used if it exists."
    echo "                                Defaults to the 30 most recent backups otherwise."
}

function parse_arguments() {
    if [ ${#} -lt 1 ]; then
        log_warning ">> Not enough arguments"
        print_usage
        exit 1
    fi

    # Evaluate the command
    case "$1" in
        create)
            if [ ${#} -ne 1 ]; then
                log_error ">>> Invalid number of arguments for 'create'"
                print_usage
                exit 1
            fi
            create_backup
            ;;
        list)
            if [ ${#} -gt 2 ]; then
                log_error ">>> Invalid number of arguments for 'list'"
                print_usage
                exit 1
            fi

            local number_to_list=${2:-""}

            if [[ -n "${number_to_list}" ]] && [[ ! "${number_to_list}" =~ ^[0-9]+$ ]]; then
                log_warning ">> Invalid argument '${number_to_list}'. Please provide a positive integer."
                exit 1
            fi

            list_backups "${number_to_list}"
            ;;
        clean)
            if [ ${#} -gt 2 ]; then
                log_error ">>> Invalid number of arguments for 'clean'"
                print_usage
                exit 1
            fi

            local num_backup_entries=${2:-${BACKUP_AUTO_CLEAN_AMOUNT_TO_KEEP}}

            if ! [[ "${num_backup_entries}" =~ ^[0-9]+$ ]]; then
                log_warning ">> Invalid argument '${num_backup_entries}'. Please provide a positive integer."
                exit 1
            fi

            clean_backups "${num_backup_entries}"
            ;;
        restore)
            if [ ${#} -ne 2 ]; then
                log_error ">>> Invalid number of arguments for 'restore'"
                print_usage
                exit 1
            fi

            local restore_file="${2}"
            restore_backup "${restore_file}"
            ;;
        help)
            if [ ${#} -ne 1 ]; then
                log_error ">>> Invalid number of arguments for 'help'"
                print_usage
                exit 1
            fi
            print_usage
            ;;
        *)
            log_error ">>> Illegal option '${1}'"
            print_usage
            exit 1
            ;;
    esac
}

function check_required_directories() {

    if [ -z "${GAME_PATH}" ]; then
        log_error ">>> GAME_PATH environment variable not set.\n Exiting..."
        exit 1
    elif [ ! -d "${GAME_PATH}" ]; then
        log_error ">>> Game directory '${GAME_PATH}' doesn't exist yet."
        exit 1
    fi

    if [ -z "${GAME_SAVE_PATH}" ]; then
        log_error ">>> GAME_SAVE_PATH environment variable not set.\n Exiting..."
        exit 1
    elif [ ! -d "${GAME_SAVE_PATH}" ]; then
        log_error ">>> Game save directory '${GAME_SAVE_PATH}' doesn't exist yet."
        exit 1
    fi

    if [ ! -d "${BACKUP_PATH}" ]; then
        log_warning ">> Backup directory ${BACKUP_PATH} doesn't exist. Creating it..."
        mkdir -p "${BACKUP_PATH}"
    fi
}

function start_backup_manager() {
    check_required_directories
    parse_arguments "${@}"
}

start_backup_manager "${@}"
