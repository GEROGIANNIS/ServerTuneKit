#!/bin/bash

install_xanmod_kernel() {
    print_yellow "Installing XanMod Kernel..."
    if [[ -f /etc/debian_version ]]; then
        # Add XanMod repository
        wget -qO - https://dl.xanmod.org/archive.key | sudo gpg --dearmor -o /etc/apt/keyrings/xanmod-archive-keyring.gpg
        echo 'deb [signed-by=/etc/apt/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-release.list
        # Install XanMod Kernel
        sudo apt update && sudo apt install -y linux-xanmod-x64v3
        print_green "XanMod Kernel installed successfully. Please reboot your system."
    else
        print_red "XanMod Kernel installation is only supported on Debian/Ubuntu."
    fi
}