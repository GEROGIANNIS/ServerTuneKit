#!/bin/bash

install_and_configure_ufw() {
    print_yellow "Installing and configuring UFW..."
    if [[ "$OS" == "debian" ]]; then
        apt install -y ufw
    else
        dnf install -y ufw
    fi
    # Enable UFW
    ufw --force enable
    # Open common ports
    ufw allow 21/tcp
    ufw allow 21/udp
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    # Adjust UFW to use the system sysctl configuration
    sed -i 's|/etc/ufw/sysctl.conf|/etc/sysctl.conf|Ig' /etc/default/ufw
    ufw reload
    print_green "UFW installed and configured."
}