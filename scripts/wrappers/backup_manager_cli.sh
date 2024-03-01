#!/bin/bash
# Wrapper for backup manager for CLI usage
# Makes the usage easier when running the backup manager from the command line
# Usage is supposed to be 'backup [option] [arguments]'

if [[ $(whoami) == "steam" ]]; then
    backup_manager "$@"
elif [[ $(whoami) == "root" ]]; then
    # Use eval to correctly handle argument passing
    su steam -c "eval backup_manager $*" --
else
    echo "This script must be run as steam or root"
fi
