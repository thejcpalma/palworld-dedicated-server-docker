#!/bin/bash
# shellcheck source=/dev/null

source "${SERVER_DIR}"/scripts/utils/cron.sh
source "${SERVER_DIR}"/scripts/config/setup_configs.sh
for file in "${SERVER_DIR}"/scripts/server/*.sh; do
    source "$file"
done

function print_usage() {
    script_name=$(basename "$0")
    echo "Usage:"
    echo "  ${script_name} init"
    echo "  ${script_name} restart [restart_warn_time]"
    echo "  ${script_name} update [update_warn_time]"
    echo "  ${script_name} help"
    echo ""
    echo "Options:"
    echo "  init                          Initializes the server"
    echo "  restart [restart_warn_time]   Restarts the server. If restart_warn_time isn't"
    echo "                                provided, the server will restart with fallback value"
    echo "  update [update_warn_time]     Updates the server. If update_warn_time isn't"
    echo "                                provided, the server will update with fallback value"
    echo "  help                          Display this help message"
    echo ""
    echo "Arguments:"
    echo "  restart_warn_time (optional)  The time in seconds before the server restarts."
    echo "                                If not provided, the server will restart with fallback value"
    echo "  update_warn_time (optional)   The time in seconds before the server updates."
    echo "                                If not provided, the server will update with fallback value"
}

function parse_arguments() {
    if [ ${#} -lt 1 ]; then
        log_warning ">> Not enough arguments"
        print_usage
        exit 1
    fi

    # Evaluate the command
    case "$1" in
        init)
            check_default_credentials

            install_server
            update_server

            setup_configs
            setup_crons

            start_server
            ;;
        restart)
            if [ ${#} -gt 2 ]; then
                log_error ">>> Invalid number of arguments for 'restart'"
                print_usage
                exit 1
            fi

            local restart_warn_time=${2}

            if [[ -n "${restart_warn_time}" ]] && [[ ! "${restart_warn_time}" =~ ^[0-9]+$ ]]; then
                log_warning ">> Invalid argument '${restart_warn_time}'. Please provide a positive integer."
                log_warning ">> Restarting server with fallback warn time..."
                restart_server
            fi

            restart_server "${restart_warn_time}"
            ;;
        update)
            if [ "${ALWAYS_UPDATE_ON_START,,}" == "false" ]; then
                log_error ">>> Update only works if 'ALWAYS_UPDATE_ON_START' is set to 'true'! Aborting..."
                exit 1
            fi

            if [ ${#} -gt 2 ]; then
                log_error ">>> Invalid number of arguments for 'update'"
                print_usage
                exit 1
            fi

            local update_warn_time=${2}

            if check_update_server > /dev/null 2>&1; then
                log_success ">>> New update available."

                if [[ -n "${update_warn_time}" ]] && [[ ! "${update_warn_time}" =~ ^[0-9]+$ ]]; then
                    log_warning ">> Invalid argument '${update_warn_time}'. Please provide a positive integer."
                    log_warning ">> Restarting server with fallback warn time..."
                    restart_server
                fi

                restart_server "${update_warn_time}"
            else
                log_info "> The server is up-to-date!"
            fi
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

function start_server_manager() {
    parse_arguments "${@}"
}

start_server_manager "${@}"
