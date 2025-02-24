#!/bin/bash

install_docker() {
    print_yellow "Installing Docker..."

    # Update the package index
    print_yellow "Updating package index..."
    sudo apt-get update -qq

    # Install prerequisites
    print_yellow "Installing prerequisites..."
    sudo apt-get install -yqq ca-certificates curl

    # Create the directory for Docker's GPG key
    print_yellow "Setting up Docker's GPG key..."
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add Docker's repository to Apt sources
    print_yellow "Adding Docker's repository..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update the package index again
    print_yellow "Updating package index with Docker repository..."
    sudo apt-get update -qq

    # Install Docker packages
    print_yellow "Installing Docker packages..."
    sudo apt-get install -yqq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Start and enable Docker service
    print_yellow "Starting Docker service..."
    sudo systemctl start docker
    sudo systemctl enable docker

    # Add the current user to the Docker group (optional)
    if [[ "$SUDO_USER" ]]; then
        print_yellow "Adding $SUDO_USER to the Docker group..."
        sudo usermod -aG docker "$SUDO_USER"
        print_yellow "User $SUDO_USER added to the Docker group. Log out and back in for changes to take effect."
    fi

    print_green "Docker installed successfully."
}