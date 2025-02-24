#!/bin/bash

install_docker() {
    print_yellow "Installing Docker..."
    # Download and run the Docker installation script
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    # Start and enable Docker service
    systemctl start docker
    systemctl enable docker
    # Add the current user to the Docker group (optional)
    if [[ "$SUDO_USER" ]]; then
        usermod -aG docker "$SUDO_USER"
        print_yellow "Added $SUDO_USER to the Docker group. Log out and back in for changes to take effect."
    fi
    print_green "Docker installed successfully."
}