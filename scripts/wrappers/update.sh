#!/bin/bash

# Wrapper for server manager update function
# Makes the usage easier when running the update feature on both cron and cli

if [[ $(whoami) == "steam" ]]; then
    /home/steam/server/scripts/server_manager.sh update "$@"
elif [[ $(whoami) == "root" ]]; then
    su steam -c "/home/steam/server/scripts/server_manager.sh update $*"
else
    echo "This script must be run as steam or root"
fi
