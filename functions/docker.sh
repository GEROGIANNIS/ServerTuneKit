#!/bin/bash

install_docker() {
    print_yellow "Installing Docker..."

    # Step 1: Update the package index
    print_yellow "Updating package index..."
    sudo apt update -qq

    # Step 2: Install prerequisite packages
    print_yellow "Installing prerequisite packages..."
    sudo apt install -yqq apt-transport-https ca-certificates curl software-properties-common

    # Step 3: Add Docker's GPG key
    print_yellow "Adding Docker's GPG key..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    # Step 4: Add Docker repository to APT sources
    print_yellow "Adding Docker repository to APT sources..."
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    # Step 5: Update the package database
    print_yellow "Updating package database..."
    sudo apt update -qq

    # Step 6: Verify installation source
    print_yellow "Verifying installation source..."
    apt-cache policy docker-ce

    # Step 7: Install Docker
    print_yellow "Installing Docker..."
    sudo apt install -yqq docker-ce

    # Step 8: Start and enable Docker service
    print_yellow "Starting and enabling Docker service..."
    sudo systemctl start docker
    sudo systemctl enable docker

    # Step 9: Add the current user to the Docker group (optional)
    if [[ "$SUDO_USER" ]]; then
        print_yellow "Adding $SUDO_USER to the Docker group..."
        sudo usermod -aG docker "$SUDO_USER"
        print_yellow "User $SUDO_USER added to the Docker group. Log out and back in for changes to take effect."
    fi

    # Step 10: Verify Docker is running
    print_yellow "Verifying Docker status..."
    sudo systemctl status docker --no-pager

    print_green "Docker installed successfully."
}