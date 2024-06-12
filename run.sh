#!/bin/bash

# Define variables
MOUNT_DIR="/mnt/nginx-proxy-manager"
DOCKER_NETWORK="reverse-proxy"

# Function to create directory if it doesn't exist
create_directory() {
  if [ ! -d "$MOUNT_DIR" ]; then
    echo "Directory $MOUNT_DIR does not exist. Creating..."
    sudo mkdir -p "$MOUNT_DIR"
    echo "Directory $MOUNT_DIR created."
  else
    echo "Directory $MOUNT_DIR already exists. Skipping creation."
  fi
}

# Function to create Docker network if it doesn't exist
create_docker_network() {
  if ! docker network ls | grep -q "$DOCKER_NETWORK"; then
    echo "Docker network $DOCKER_NETWORK does not exist. Creating..."
    docker network create "$DOCKER_NETWORK"
    echo "Docker network $DOCKER_NETWORK created."
  else
    echo "Docker network $DOCKER_NETWORK already exists. Skipping creation."
  fi
}

# Execute functions
create_directory
create_docker_network

echo "Setup complete."
