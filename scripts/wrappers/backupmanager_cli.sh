#!/bin/bash
# Wrapper for backup manager for CLI usage
# Makes the usage easier when running the backup manager from the command line
# Usage is supposed to be 'backup [option] [arguments]'

# Use eval to correctly handle argument passing
su steam -c "eval backupmanager $*" -- 
