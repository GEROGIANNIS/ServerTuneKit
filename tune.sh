#!/bin/bash
# =============================================================================
# ServerTuneKit - Tune.sh
# Repository: https://github.com/GEROGIANNIS/ServerTuneKit.git
# =============================================================================
#
# This script enhances your server by updating system packages,
# installing essential tools, fixing system configuration files,
# optimizing the firewall (UFW), configuring Fail2Ban, NTP, and tuning kernel parameters.
#
# IMPORTANT: Review and test this script before using it in production.
#

# Clear the screen
clear

####################################
# Colorful Output Functions
####################################
print_green() {
    echo -e "\e[32m[*] $1\e[0m"
}

print_yellow() {
    echo -e "\e[33m[*] $1\e[0m"
}

print_red() {
    echo -e "\e[31m[*] $1\e[0m"
}

prompt_question() {
    echo -ne "\e[34m[?] $1\e[0m "
}

# Check Root Function
check_if_running_as_root() {
    if [[ "$EUID" -ne '0' ]]; then
      echo 
      print_red 'Error: You must run this script as root!'
      echo 
      sleep 0.5
      exit 1
    fi
}

####################################
# Check for Root Privileges
####################################
check_if_running_as_root

####################################
# Intro Message
####################################
print_green "================================================================="
print_green "ServerTuneKit - Tune.sh: Boost your server's performance!"
print_green "Repository: https://github.com/GEROGIANNIS/ServerTuneKit.git"
print_green "Tested on Ubuntu, Debian, CentOS, Fedora"
print_green "================================================================="
echo

####################################
# OS Detection
####################################
OS=""
if grep -qi "ubuntu" /etc/os-release; then
    OS="debian"
    print_yellow "Detected OS: Ubuntu/Debian-based"
elif grep -qi "debian" /etc/os-release; then
    OS="debian"
    print_yellow "Detected OS: Debian"
elif grep -qi "centos" /etc/os-release; then
    OS="rhel"
    print_yellow "Detected OS: CentOS"
elif grep -qi "fedora" /etc/os-release; then
    OS="rhel"
    print_yellow "Detected OS: Fedora"
else
    print_red "Unknown OS. Some features may not work correctly."
fi
echo

####################################
# Dependency Installation
####################################
install_dependencies() {
    print_yellow "Installing basic dependencies..."
    if [[ "$OS" == "debian" ]]; then
        apt update -qq && apt install -yq wget curl sudo jq
    else
        dnf install -y wget curl sudo jq
    fi
    print_green "Dependencies installed."
}
install_dependencies

####################################
# Fix /etc/hosts File
####################################
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
fix_hosts

####################################
# Set Timezone Based on Public IP
####################################
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
set_timezone

####################################
# Install XanMod Kernel (Optional)
####################################
install_xanmod_kernel() {
    print_yellow "Installing XanMod Kernel..."
    if [[ -f /etc/debian_version ]]; then
        # Debian/Ubuntu-based systems
        wget -qO - https://dl.xanmod.org/archive.key | sudo gpg --dearmor -o /etc/apt/keyrings/xanmod-archive-keyring.gpg
        echo 'deb [signed-by=/etc/apt/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-release.list
        sudo apt update && sudo apt install -y linux-xanmod-x64v3
        print_green "XanMod Kernel installed successfully. Please reboot your system."
    else
        print_red "XanMod Kernel installation is only supported on Debian/Ubuntu."
    fi
}


####################################
# Remove Ubuntu Server Ads (MOTD, Unattended Upgrades, Snap Messages)
####################################
remove_ubuntu_ads() {
    print_yellow "Disabling Ubuntu ads and messages..."
    chmod -x /etc/update-motd.d/*
    sed -i 's/ENABLED=1/ENABLED=0/g' /etc/default/motd-news
    systemctl disable --now motd-news.timer
    systemctl disable --now unattended-upgrades.service
    snap set system refresh.retain=2
    print_green "Ubuntu server ads disabled."
}

####################################
# Interactive Optimization Steps
####################################

# Step 1: Update and Upgrade System Packages
prompt_question "Update and upgrade system packages? [y/N]: "
read -r update_choice
if [[ "$update_choice" =~ ^[Yy]$ ]]; then
    print_yellow "Updating system packages..."
    if [[ "$OS" == "debian" ]]; then
        apt update -y && apt upgrade -y && apt dist-upgrade -y
    else
        dnf update -y
    fi
    print_green "System packages updated."
else
    print_yellow "Skipping system update."
fi

# Step 2: Install XanMod Kernel (Debian/Ubuntu only)
if [[ "$OS" == "debian" ]]; then
    prompt_question "Install XanMod Kernel for better performance? [y/N]: "
    read -r xanmod_choice
    if [[ "$xanmod_choice" =~ ^[Yy]$ ]]; then
        install_xanmod_kernel
    else
        print_yellow "Skipping XanMod Kernel installation."
    fi
fi

# Step 3: Install Essential Tools & Networking Utilities
prompt_question "Install essential tools and networking utilities? [y/N]: "
read -r tools_choice
if [[ "$tools_choice" =~ ^[Yy]$ ]]; then
    print_yellow "Installing essential tools..."
    if [[ "$OS" == "debian" ]]; then
        apt install -y htop nload iotop iftop tmux curl wget git unzip ufw fail2ban sysstat net-tools iputils-ping traceroute
    else
        dnf install -y htop nload iotop iftop tmux curl wget git unzip ufw fail2ban sysstat net-tools iputils traceroute
    fi
    print_green "Essential tools installed."
else
    print_yellow "Skipping tool installation."
fi

# Step 4: Configure UFW (Firewall) with Optimizations
optimize_ufw() {
    print_yellow "Applying UFW optimizations..."
    # Open common ports (SSH, HTTP, HTTPS)
    ufw allow 21/tcp
    ufw allow 21/udp
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    # Adjust UFW to use the system sysctl configuration
    sed -i 's|/etc/ufw/sysctl.conf|/etc/sysctl.conf|Ig' /etc/default/ufw
    ufw reload
    print_green "UFW firewall optimized."
}

prompt_question "Configure UFW firewall with optimizations? [y/N]: "
read -r ufw_choice
if [[ "$ufw_choice" =~ ^[Yy]$ ]]; then
    ufw --force enable
    optimize_ufw
else
    print_yellow "Skipping UFW configuration."
fi

# Step 5: Configure Fail2Ban
prompt_question "Configure Fail2Ban for intrusion prevention? [y/N]: "
read -r fail2ban_choice
if [[ "$fail2ban_choice" =~ ^[Yy]$ ]]; then
    systemctl enable fail2ban
    systemctl start fail2ban
    print_green "Fail2Ban configured."
else
    print_yellow "Skipping Fail2Ban configuration."
fi

# Step 6: Configure Time Synchronization
prompt_question "Configure time synchronization? [y/N]: "
read -r ntp_choice
if [[ "$ntp_choice" =~ ^[Yy]$ ]]; then
    timedatectl set-ntp true
    systemctl restart systemd-timesyncd
    print_green "Time synchronization configured."
else
    print_yellow "Skipping time synchronization."
fi


# Step 7: Remove MODT Ads Ubuntu Server

prompt_question "Remove Ubuntu server ads and messages? [y/N]: "
read -r ubuntu_ads_choice
if [[ "$ubuntu_ads_choice" =~ ^[Yy]$ ]]; then
    remove_ubuntu_ads
else
    print_yellow "Skipping Ubuntu ad removal."
fi

# Step 7: Tune Kernel Parameters for Performance
tune_kernel() {
    print_yellow "Tuning kernel parameters..."
    cat <<'EOF' >> /etc/sysctl.conf
# Increase file descriptors limit
fs.file-max = 65535
# Increase maximum network connections queue
net.core.somaxconn = 65535
# Increase network buffer sizes
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
# Adjust TCP buffer sizes
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
# Enable TCP optimizations
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_fastopen = 3
# Optimize TCP timeouts and connection reuse
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_tw_reuse = 1
# Optimize TIME_WAIT backlog and limits
net.ipv4.tcp_max_tw_buckets = 1440000
net.ipv4.ip_local_port_range = 2000 65000
net.ipv4.tcp_max_syn_backlog = 3240000
net.ipv4.tcp_max_orphans = 3240000
net.core.netdev_max_backlog = 3240000
EOF
    sysctl -p
    print_green "Kernel parameters tuned."
}

prompt_question "Tune kernel parameters for better performance? [y/N]: "
read -r kernel_choice
if [[ "$kernel_choice" =~ ^[Yy]$ ]]; then
    tune_kernel
else
    print_yellow "Skipping kernel tuning."
fi

print_green "All selected optimizations have been applied. Enjoy your optimized server!"
