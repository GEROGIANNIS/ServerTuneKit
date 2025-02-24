#!/bin/bash

install_dependencies() {
    print_yellow "Installing basic dependencies..."
    if [[ "$OS" == "debian" ]]; then
        apt update -qq && apt install -yq wget curl sudo jq
    else
        dnf install -y wget curl sudo jq
    fi
    print_green "Dependencies installed."
}