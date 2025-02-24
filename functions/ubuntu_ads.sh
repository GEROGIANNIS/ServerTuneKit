#!/bin/bash

remove_ubuntu_ads() {
    print_yellow "Disabling Ubuntu ads and messages..."
    # Disable MOTD
    chmod -x /etc/update-motd.d/*
    # Disable motd-news
    sed -i 's/ENABLED=1/ENABLED=0/g' /etc/default/motd-news
    systemctl disable --now motd-news.timer
    # Disable unattended upgrades
    systemctl disable --now unattended-upgrades.service
    # Limit Snap refresh retention
    snap set system refresh.retain=2
    print_green "Ubuntu server ads disabled."
}