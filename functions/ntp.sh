#!/bin/bash

install_and_configure_ntp() {
    print_yellow "Installing and configuring NTP..."
    if [[ "$OS" == "debian" ]]; then
        apt install -y ntp
    else
        dnf install -y ntp
    fi
    # Enable and start NTP
    timedatectl set-ntp true
    systemctl restart systemd-timesyncd
    print_green "NTP installed and configured."
}