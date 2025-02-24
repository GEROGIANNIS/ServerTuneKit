#!/bin/bash

fix_hosts() {
    local HOST_FILE="/etc/hosts"
    print_yellow "Backing up $HOST_FILE to ${HOST_FILE}.bak..."
    cp "$HOST_FILE" "${HOST_FILE}.bak"
    if ! grep -q "$(hostname)" "$HOST_FILE"; then
        echo "127.0.1.1 $(hostname)" >> "$HOST_FILE"
        print_green "Hostname added to $HOST_FILE."
    else
        print_green "$HOST_FILE already contains the hostname."
    fi
}