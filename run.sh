#!/bin/bash

# Define services
SERVICES=("nginx-proxy-manager" "ollama")

# Function to create directory if it doesn't exist
create_directory() {
  local dir=$1
  if [ ! -d "$dir" ]; then
    echo "Directory $dir does not exist. Creating..."
    sudo mkdir -p "$dir"
    echo "Directory $dir created."
  else
    echo "Directory $dir already exists. Skipping creation."
  fi
}

# Function to create Docker network if it doesn't exist
create_docker_network() {
  local network=$1
  if ! docker network ls | grep -q "$network"; then
    echo "Docker network $network does not exist. Creating..."
    docker network create "$network"
    echo "Docker network $network created."
  else
    echo "Docker network $network already exists. Skipping creation."
  fi
}

# Function to create Docker volume if it doesn't exist
create_docker_volume() {
  local volume=$1
  if ! docker volume ls | grep -q "$volume"; then
    echo "Docker volume $volume does not exist. Creating..."
    docker volume create "$volume"
    echo "Docker volume $volume created."
  else
    echo "Docker volume $volume already exists. Skipping creation."
  fi
}

# Function to remove directory if it exists
remove_directory() {
  local dir=$1
  if [ -d "$dir" ]; then
    echo "Removing directory $dir..."
    sudo rm -rf "$dir"
    echo "Directory $dir removed."
  else
    echo "Directory $dir does not exist. Skipping removal."
  fi
}

# Function to remove Docker network if it exists
remove_docker_network() {
  local network=$1
  if docker network ls | grep -q "$network"; then
    echo "Removing Docker network $network..."
    docker network rm "$network"
    echo "Docker network $network removed."
  else
    echo "Docker network $network does not exist. Skipping removal."
  fi
}

# Function to remove Docker volume if it exists
remove_docker_volume() {
  local volume=$1
  if docker volume ls | grep -q "$volume"; then
    echo "Removing Docker volume $volume..."
    docker volume rm "$volume"
    echo "Docker volume $volume removed."
  else
    echo "Docker volume $volume does not exist. Skipping removal."
  fi
}

# Main script logic
if [ "$1" == "cleanup" ]; then
  # Cleanup process
  for service in "${SERVICES[@]}"; do
    MOUNT_DIR="/mnt/$service"
    DOCKER_NETWORK="$service"
    DOCKER_VOLUME="$service"
    
    remove_directory "$MOUNT_DIR"
    remove_docker_network "$DOCKER_NETWORK"
    remove_docker_volume "$DOCKER_VOLUME"
  done
  echo "Cleanup complete."
else
  # Setup process
  for service in "${SERVICES[@]}"; do
    MOUNT_DIR="/mnt/$service"
    DOCKER_NETWORK="$service"
    DOCKER_VOLUME="$service"
    
    create_directory "$MOUNT_DIR"
    create_docker_network "$DOCKER_NETWORK"
    create_docker_volume "$DOCKER_VOLUME"
  done
  echo "Setup complete."
fi
