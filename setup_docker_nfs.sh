#!/bin/bash

# Variables
NFS_SERVER="192.168.0.233"  # Replace with your Synology NAS IP address
NFS_SHARE="/volume1/docker"  # Replace with the path to your NFS share
MOUNT_POINT="/mnt"  # Replace with your desired mount point
DOCKER_DATA_DIR="$MOUNT_POINT/docker"

# Function to install necessary packages
install_packages() {
  sudo apt update
  sudo apt install -y nfs-common
}

# Function to mount the NFS share
mount_nfs_share() {
  # Create mount point if it doesn't exist
  if [ ! -d "$MOUNT_POINT" ]; then
    sudo mkdir -p "$MOUNT_POINT"
  fi

  # Mount the NFS share
  sudo mount -t nfs "$NFS_SERVER:$NFS_SHARE" "$MOUNT_POINT"

  # Verify the mount
  if mountpoint -q "$MOUNT_POINT"; then
    echo "NFS share mounted successfully at $MOUNT_POINT"
  else
    echo "Failed to mount NFS share"
    exit 1
  fi

  # Add entry to /etc/fstab for persistent mount
  FSTAB_ENTRY="$NFS_SERVER:$NFS_SHARE  $MOUNT_POINT  nfs  defaults  0  0"
  grep -qF -- "$FSTAB_ENTRY" /etc/fstab || echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab
  echo "NFS share added to /etc/fstab for persistent mount"
}

# Function to configure Docker to use the NFS mount for its data storage
configure_docker() {
  # Stop Docker service
  sudo systemctl stop docker

  # Create Docker directory on NFS share if it doesn't exist
  if [ ! -d "$DOCKER_DATA_DIR" ]; then
    sudo mkdir -p "$DOCKER_DATA_DIR"
  fi

  # Set ownership and permissions on the Docker directory
  sudo chown -R ubuntu22:ubuntu22 "$DOCKER_DATA_DIR"
  sudo chmod -R 755 "$DOCKER_DATA_DIR"

  # Move existing Docker data to NFS share (optional)
  if [ -d "/var/lib/docker" ]; then
    sudo rsync -aP /var/lib/docker/ "$DOCKER_DATA_DIR/"
  fi

  # Update Docker daemon configuration
  DOCKER_CONFIG_FILE="/etc/docker/daemon.json"
  sudo mkdir -p "$(dirname "$DOCKER_CONFIG_FILE")"
  echo "{
    \"data-root\": \"$DOCKER_DATA_DIR\"
  }" | sudo tee "$DOCKER_CONFIG_FILE"

  # Start Docker service
  sudo systemctl start docker

  # Verify Docker configuration
  if docker info | grep -q "Docker Root Dir: $DOCKER_DATA_DIR"; then
    echo "Docker successfully configured to use $DOCKER_DATA_DIR"
  else
    echo "Failed to configure Docker to use $DOCKER_DATA_DIR"
    sudo journalctl -u docker.service
    exit 1
  fi
}

# Execute functions
install_packages
mount_nfs_share
configure_docker
