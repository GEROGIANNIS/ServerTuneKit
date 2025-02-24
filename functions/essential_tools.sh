#!/bin/bash

install_essential_tools() {
    print_yellow "Installing essential tools..."
    if [[ "$OS" == "debian" ]]; then
        apt install -y htop nload iotop iftop tmux curl wget git unzip ufw fail2ban sysstat net-tools iputils-ping traceroute
    else
        dnf install -y htop nload iotop iftop tmux curl wget git unzip ufw fail2ban sysstat net-tools iputils traceroute
    fi
    print_green "Essential tools installed."
}