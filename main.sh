#!/bin/bash
# =============================================================================
# ServerTuneKit - Main Script
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

# OS Detection
detect_os

# Install Dependencies
install_dependencies

# Fix /etc/hosts File
fix_hosts

# Set Timezone
set_timezone

# Interactive Optimization Steps
prompt_question "Update and upgrade system packages? [y/N]: "
read -r update_choice
if [[ "$update_choice" =~ ^[Yy]$ ]]; then
    update_system
fi

if [[ "$OS" == "debian" ]]; then
    prompt_question "Install XanMod Kernel for better performance? [y/N]: "
    read -r xanmod_choice
    if [[ "$xanmod_choice" =~ ^[Yy]$ ]]; then
        install_xanmod_kernel
    fi
fi

prompt_question "Install essential tools and networking utilities? [y/N]: "
read -r tools_choice
if [[ "$tools_choice" =~ ^[Yy]$ ]]; then
    install_essential_tools
fi

prompt_question "Install and configure UFW firewall? [y/N]: "
read -r ufw_choice
if [[ "$ufw_choice" =~ ^[Yy]$ ]]; then
    install_and_configure_ufw
fi

prompt_question "Install and configure Fail2Ban for intrusion prevention? [y/N]: "
read -r fail2ban_choice
if [[ "$fail2ban_choice" =~ ^[Yy]$ ]]; then
    install_and_configure_fail2ban
fi

prompt_question "Install and configure NTP for time synchronization? [y/N]: "
read -r ntp_choice
if [[ "$ntp_choice" =~ ^[Yy]$ ]]; then
    install_and_configure_ntp
fi

prompt_question "Remove Ubuntu server ads and messages? [y/N]: "
read -r ubuntu_ads_choice
if [[ "$ubuntu_ads_choice" =~ ^[Yy]$ ]]; then
    remove_ubuntu_ads
fi

prompt_question "Tune kernel parameters for better performance? [y/N]: "
read -r kernel_choice
if [[ "$kernel_choice" =~ ^[Yy]$ ]]; then
    tune_kernel
fi

print_green "All selected optimizations have been applied. Enjoy your optimized server!"