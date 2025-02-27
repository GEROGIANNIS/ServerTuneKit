#!/bin/bash

# Function to generate PPK key
generate_ppk_key() {
    # Ensure puttygen is installed, install if missing
    if ! command -v puttygen &> /dev/null; then
        echo "puttygen is not installed. Installing..."
        sudo apt update && sudo apt install -y putty-tools
    fi

    # Create the /keys directory if it doesn't exist
    KEYS_DIR="/keys"
    mkdir -p "$KEYS_DIR"

    # Generate a new key pair
    KEY_NAME="server_key"
    PRIVATE_KEY="$KEYS_DIR/$KEY_NAME.ppk"
    OPENSSH_KEY="$KEYS_DIR/$KEY_NAME.pem"

    # Generate SSH private key
    ssh-keygen -t rsa -b 4096 -m PEM -f "$OPENSSH_KEY" -N ""

    # Convert to PPK format
    puttygen "$OPENSSH_KEY" -O private -o "$PRIVATE_KEY"

    # Set permissions
    chmod 600 "$PRIVATE_KEY" "$OPENSSH_KEY"

    echo "Keys generated successfully:"
    echo "  - OpenSSH Private Key: $OPENSSH_KEY"
    echo "  - PuTTY PPK Key: $PRIVATE_KEY"
}