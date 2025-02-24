install_docker() {
    print_yellow "Installing Docker..."

    # Step 1: Update the package index
    print_yellow "Updating package index..."
    sudo apt update -qq

    # Step 2: Install prerequisite packages
    print_yellow "Installing prerequisite packages..."
    sudo apt install -yqq apt-transport-https ca-certificates curl software-properties-common gnupg

    # Step 3: Add Docker's GPG key
    print_yellow "Adding Docker's GPG key..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Step 4: Add Docker repository to APT sources
    print_yellow "Adding Docker repository to APT sources..."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Step 5: Update the package database
    print_yellow "Updating package database..."
    sudo apt update -qq

    # Step 6: Verify installation source
    print_yellow "Verifying installation source..."
    apt-cache policy docker-ce

    # Step 7: Install Docker (if available)
    print_yellow "Installing Docker..."
    if sudo apt install -yqq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
        print_green "Docker installed successfully."
    else
        echo -e "\e[31mError: Docker could not be installed. Ensure your system is compatible and repository is correctly added.\e[0m"
        exit 1
    fi

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

    print_green "Docker installation complete."
}
