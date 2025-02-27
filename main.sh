#!/bin/bash
# =============================================================================
# ServerTuneKit - Main Script with Menu
# =============================================================================

# Clear the screen
clear

# Source utility functions
source functions/utils.sh

# Check for root privileges
check_if_running_as_root

# Intro Message
print_green "================================================================="
print_green "ServerTuneKit - Tune.sh: Boost your server's performance!"
print_green "Repository: https://github.com/GEROGIANNIS/ServerTuneKit.git"
print_green "Tested on Ubuntu, Debian, CentOS, Fedora"
print_green "================================================================="
echo

# Source all function files
for func_file in functions/*.sh; do
    source "$func_file"
done

# Function to display menu
display_menu() {
    echo "Choose an option to run a specific function:" 
    echo "1) Install Dependencies"
    echo "2) Fix /etc/hosts File"
    echo "3) Set Timezone"
    echo "4) Update and Upgrade System"
    echo "5) Install XanMod Kernel (Debian-based)"
    echo "6) Install Essential Tools"
    echo "7) Install Docker"
    echo "8) Install and Configure UFW"
    echo "9) Install and Configure Fail2Ban"
    echo "10) Install and Configure NTP"
    echo "11) Remove Ubuntu Server Ads"
    echo "12) Tune Kernel Parameters"
    echo "13) Setup LVM on Selected Disks"
    echo "14) Exit"
}

while true; do
    display_menu
    read -rp "Enter your choice (1-14): " choice

    case $choice in
        1) install_dependencies ;;
        2) fix_hosts ;;
        3) set_timezone ;;
        4) update_system ;;
        5) [[ "$OS" == "debian" ]] && install_xanmod_kernel || echo "XanMod Kernel is only available for Debian-based systems." ;;
        6) install_essential_tools ;;
        7) install_docker ;;
        8) install_and_configure_ufw ;;
        9) install_and_configure_fail2ban ;;
        10) install_and_configure_ntp ;;
        11) remove_ubuntu_ads ;;
        12) tune_kernel ;;
        13) setup_lvm ;;
        14) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid choice, please select a number between 1-14." ;;
    esac

    echo -e "\nOperation completed. Returning to menu...\n"
done
