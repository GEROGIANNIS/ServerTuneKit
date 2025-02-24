#!/bin/bash

install_and_configure_fail2ban() {
    print_yellow "Installing and configuring Fail2Ban..."
    if [[ "$OS" == "debian" ]]; then
        apt install -y fail2ban
    else
        dnf install -y fail2ban
    fi
    # Enable and start Fail2Ban
    systemctl enable fail2ban
    systemctl start fail2ban
    print_green "Fail2Ban installed and configured."
}