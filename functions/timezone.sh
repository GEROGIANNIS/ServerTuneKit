#!/bin/bash

set_timezone() {
    print_yellow "Determining server location to set timezone..."
    local ip
    ip=$(curl -s https://api.ipify.org)
    local location
    location=$(curl -s "http://ip-api.com/json/${ip}")
    local tz
    tz=$(echo "$location" | jq -r '.timezone')
    if [[ -n "$tz" && "$tz" != "null" ]]; then
        timedatectl set-timezone "$tz"
        print_green "Timezone set to $tz."
    else
        print_red "Failed to determine timezone. Defaulting to UTC."
        timedatectl set-timezone UTC
    fi
}