#!/bin/bash

# Variables
NVIDIA_KEYRING="/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg"
NVIDIA_LIST="/etc/apt/sources.list.d/nvidia-container-toolkit.list"

# Function to add the NVIDIA package repository
add_nvidia_repo() {
  # Add the GPG key for the NVIDIA package repository
  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o "$NVIDIA_KEYRING"
  
  # Add the repository to the APT sources list
  curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by='$NVIDIA_KEYRING'] https://#g' | \
    sudo tee "$NVIDIA_LIST"
  
  # Update package lists
  sudo apt-get update
}

# Function to install the NVIDIA container toolkit
install_nvidia_toolkit() {
  sudo apt-get install -y nvidia-container-toolkit
}

# Function to configure Docker to use the GPU runtime
configure_docker_gpu() {
  sudo nvidia-ctk runtime configure --runtime=docker
  
  # Restart Docker to apply the changes
  sudo systemctl restart docker
}

# Execute functions
add_nvidia_repo
install_nvidia_toolkit
configure_docker_gpu

# Verify the installation
echo "Docker GPU setup complete. Verifying installation..."
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
