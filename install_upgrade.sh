#!/bin/bash

# Function to check if Docker is installed
check_docker() {
    command -v docker &> /dev/null
}

# Function to install Docker
install_docker() {
    echo "Installing Docker..."

    # Update package list and install prerequisites
    sudo apt-get update -y
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Add Docker's official repository
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    # Start and enable Docker service
    sudo systemctl start docker
    sudo systemctl enable docker

    # Verify Docker installation
    if check_docker; then
        echo "Docker successfully installed."
    else
        echo "Docker installation failed."
        exit 1
    fi
}

# Function to upgrade Docker
upgrade_docker() {
    echo "Upgrading Docker..."

    # Update package list and upgrade Docker
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    # Restart Docker service
    sudo systemctl restart docker

    # Verify Docker installation
    if check_docker; then
        echo "Docker successfully upgraded."
    else
        echo "Docker upgrade failed."
        exit 1
    fi
}

# Function to install or upgrade Docker Compose
install_or_upgrade_docker_compose() {
    echo "Installing or upgrading Docker Compose..."

    # Get the latest version of Docker Compose
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')

    # Download and install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

    # Apply executable permissions to the binary
    sudo chmod +x /usr/local/bin/docker-compose

    # Verify Docker Compose installation
    if command -v docker-compose &> /dev/null; then
        echo "Docker Compose successfully installed/upgraded."
    else
        echo "Docker Compose installation/upgrade failed."
        exit 1
    fi
}

# Function to add the current user to the docker group
add_user_to_docker_group() {
    sudo groupadd -f docker
    sudo usermod -aG docker $USER

    # Change the current shell to new group
    newgrp docker <<EONG
    echo "Current user is now part of the docker group."
    # Verify docker without sudo
    docker --version
    docker-compose --version
EONG
}

# Function to install additional software
install_additional_software() {
    echo "Installing additional software..."

    sudo apt update
    sudo apt upgrade -y
    sudo apt install --no-install-recommends -y build-essential nvidia-driver-535 nvidia-headless-535 nvidia-utils-535 nvidia-cuda-toolkit
    sudo apt install net-tools -y
    sudo apt install openssh-server -y
    sudo apt-get install ca-certificates curl -y

    # Start SSH service
    sudo systemctl start ssh
}

# Main script logic
# Install additional software
install_additional_software

if check_docker; then
    upgrade_docker
else
    install_docker
fi

# Install or upgrade Docker Compose
install_or_upgrade_docker_compose

# Add the current user to the docker group
add_user_to_docker_group

echo "All tasks completed successfully."
