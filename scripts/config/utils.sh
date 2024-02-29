#!/bin/bash

# Function to check if a number is an integer
#
# Arguments:
#   $1 - The number to check
#   $2 - The default value to return if the number is not valid
#
# Description:
#   This function checks if the given number is an integer.
#   If the argument is an integer, it will return that argument.
#   If the argument is not a valid integer, it will return the default value.
function is_integer() {
    local number="$1"
    local default="$2"

    if [[ ${number} =~ ^-?[0-9]+$ ]]; then
        echo "$1"
    else
        echo "${default}"
    fi
}

# Function to check if a number is a float with six decimals
#
# Arguments:
#   $1 - The number to check
#   $2 - The default value to return if the number is not valid
#
# Description:
#   This function checks if the given number is a float with six decimals.
#   If the argument is a float with six decimals, it will return that argument.
#   If the argument is a valid integer or float with less than six decimals, it will return the
#   argument with six decimals by appending zeros or rounding it.
#   If the argument is not a valid number, it will return an error message and exit with status 1.
function is_float_with_six_decimals() {
    local number="$1"
    local default="$2"

    if [[ ${number} =~ ^?[0-9]+\.[0-9]{6}$ ]]; then
        echo "$1"
    elif [[ ${number} =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        printf "%.*f\n" 6 "$1"
    else
        echo "${default}"
    fi
}

# Function to check if a string is in a list
#
# Arguments:
#   $1 - The string to search for
#   $2 - The default value to return if the string is not in the list
#   $3 - The list of strings
#
# Description:
#   This function checks if the given string is in the list of strings.
#   If the string is in the list, it will return that string.
#   If the string is not in the list or the list is empty, it will return the default value.
# Usage:
#     list=("string1" "string2" "string3")
#     is_in_list "myString" "${list[@]}"
function is_in_list() {
    local search_string="$1"
    local default="$2"

    shift
    shift

    local array=("$@")

    for element in "${array[@]}"; do
        if [[ "${element,,}" == "${search_string,,}" ]]; then
            echo "$search_string"
            return
        fi
    done
    echo "$default"
}

# Function to check if a string is a boolean
#
# Arguments:
#   $1 - The string to check
#   $2 - The default value to return if the string is not a boolean
#
# Description:
#   This function checks if the given string is a boolean.
#   If the string is a boolean, it will return that string.
#   If the string is not a boolean, it will return the default value.
function is_bool() {
    local value="$1"
    local default="$2"

    list=("true" "false")
    is_in_list "$value" "$default" "${list[@]}"
}

# Function to check if a port is valid
#
# Arguments:
#   $1 - The port to check
#   $2 - The default value to return if the port is not valid
#
# Description:
#   This function checks if the given port is a valid port number.
#   If the port is valid, it will return that port.
#   If the port is not valid, it will return the default value.
function is_valid_port() {
    local port="$1"
    local default="$2"

    # Check if the port is a number and in the valid range
    if [[ "$port" =~ ^[0-9]+$ && $port -gt 1024 && $port -lt 49151 ]]; then
        echo "$port"
    else
        echo "$default"
    fi
}


function check_and_export() {
    local type=$1
    local name=$2
    local env_var=$3
    local default=$4
    local array=("${@:5}")

    case "$type" in
        int)
            to_export="$(is_integer "$env_var" "$default")"
            log_base "> Setting $name to '$to_export'"
            export "$name"="$to_export"
            ;;
        float)
            to_export="$(is_float_with_six_decimals "$env_var" "$default")"
            log_base "> Setting $name to '$to_export'"
            export "$name"="$to_export"
            ;;
        bool)
            to_export="$(is_bool "$env_var" "$default")"
            log_base "> Setting $name to '$to_export'"
            export "$name"="$to_export"
            ;;
        list)
            to_export="$(is_in_list "$env_var" "$default" "${array[@]}")"
            log_base "> Setting $name to '$to_export'"
            export "$name"="$to_export"
            ;;
        hidden)
            to_export="${env_var:-$default}"
            log_base "> Setting $name to '████████████████'"
            export "$name"="\"${to_export}\""
            ;;
        *)
            to_export="${env_var:-$default}"
            to_export="${to_export/"###RANDOM###"/$RANDOM}"
            log_base "> Setting $name to '$to_export'"
            export "$name"="\"${to_export}\""
    esac
}

