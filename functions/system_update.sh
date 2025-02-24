#!/bin/bash

update_system() {
    print_yellow "Updating system packages..."
    if [[ "$OS" == "debian" ]]; then
        apt update -y && apt upgrade -y && apt dist-upgrade -y
    else
        dnf update -y
    fi
    print_green "System packages updated."
}