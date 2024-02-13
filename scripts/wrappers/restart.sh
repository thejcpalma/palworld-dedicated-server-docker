#!/bin/bash
# In /wrappers folder because it uses functions from includes/server.sh
# and it's not a standalone script


# shellcheck disable=SC1091
source "${PWD}"/includes/server.sh

if [ $# -gt 1 ]; then
    exit
elif [ $# -eq 0 ]; then
    # Fallback in case no argument is provided
    echo_warning ">> Restarting server in 30 minutes..."
    restart_server 30 &
else
    if ! [[ $1 =~ ^[0-9]+$ ]]; then
        echo_warning ">>> Invalid argument: ${1}"
        exit
    fi

    if [ "${1}" -eq 0 ]; then
        echo_warning ">> Restarting server now..."
        restart_server 0 &
    else
        echo_warning ">> Restarting server in ${1} minute(s)..."
        restart_server "${1}" &
    fi
fi
