# shellcheck disable=SC2148
# Idea from https://colors.sh/
# ANSI Color Codes - https://www.shellhacks.com/bash-colors/
# Ansi Default Color Codes https://hyperskill.org/learn/step/18193#terminal-support
# Use ANSI whenever possible. Makes logs compatible with almost all systems.

# Aliases for colorful echos with newlines
function log_base() {
    colorful_echos --base "${@}" # to remove
}

function log_error() {
    colorful_echos --error "${@}"
}

function log_info() {
    colorful_echos --info "${@}"
}

function log_success() {
    colorful_echos --success "${@}"
}

function log_warning() {
    colorful_echos --warning "${@}"
}


# This creates a wrapper for echo to add colors
function colorful_echos() {
    # Set color constants
    BASE="\e[97m"              # Base color
    CLEAN="\e[0m"              # Clean color
    ERROR="\e[91m"       # Red color for error
    INFO="\e[94m"         # Blue color for info
    SUCCESS="\e[92m"      # Green color for success
    WARNING="\e[93m"      # Yellow color for warning

    if [ $# -gt 3 ]; then
        echo "Usage: $0 [--success|--error|--info|--warning|--base] [-n] <message>"
        echo "  --success: Print a success message"
        echo "  --error: Print an error message"
        echo "  --info: Print an info message"
        echo "  --warning: Print a warning message"
        echo "  --base: Print a base message"
        echo "  -n: Do not print a newline at the end of the message"
        exit 1
    fi


    # Parse arguments
    level=$1

    shift

    nl_flag="\n"
    if [ "$1" == "-n" ]; then
        nl_flag=""
        shift
    fi

    message="${*}"

    # Set color based on argument
    if [ "$level" == "--success" ]; then
        color="$SUCCESS"
    elif [ "$level" == "--error" ]; then
        color="$ERROR"
    elif [ "$level" == "--info" ]; then
        color="$INFO"
    elif [ "$level" == "--warning" ]; then
        color="$WARNING"
    elif [ "$level" == "--base" ]; then
        color="$BASE"
    else
        echo -ne "$message"
        return 0
    fi

    # print newlines in the beginning of the message
    while [ "${message:0:2}" = "\\n" ]; do
        # Print a newline
        echo ""
        # Remove the first two characters from the message
        message="${message:2}"
    done

    # Print message with the specified color
    echo -ne "${color}${message}${CLEAN}${nl_flag}"

}
