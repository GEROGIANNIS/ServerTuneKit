#!/bin/bash

# Colorful Output Functions
print_green() {
    echo -e "\e[32m[*] $1\e[0m"
}

print_yellow() {
    echo -e "\e[33m[*] $1\e[0m"
}

print_red() {
    echo -e "\e[31m[*] $1\e[0m"
}

prompt_question() {
    echo -ne "\e[34m[?] $1\e[0m "
}

# Check Root Function
check_if_running_as_root() {
    if [[ "$EUID" -ne '0' ]]; then
        echo
        print_red 'Error: You must run this script as root!'
        echo
        sleep 0.5
        exit 1
    fi
}