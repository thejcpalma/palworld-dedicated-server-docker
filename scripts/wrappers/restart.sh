#!/bin/bash

# Wrapper for server manager restart function
# Makes the usage easier when running the restart feature on both cron and cli

if [[ $(whoami) == "steam" ]]; then
    /home/steam/server/scripts/server_manager.sh restart "$@"
elif [[ $(whoami) == "root" ]]; then
    su steam -c "/home/steam/server/scripts/server_manager.sh restart $*"
else
    echo "This script must be run as steam or root"
fi
