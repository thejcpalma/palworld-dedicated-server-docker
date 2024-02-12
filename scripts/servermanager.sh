#!/bin/bash
# shellcheck disable=SC1091
# IF Bash extension used:
# https://stackoverflow.com/a/13864829
# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02

source "${PWD}"/includes/server.sh
source "${PWD}"/includes/cron.sh
source "${PWD}"/includes/security.sh

### Server Manager Initialization
function start_server_manager() {
    check_for_default_credentials
        
    install_server

    update_server

    setup_crons

    start_server
}

start_server_manager
