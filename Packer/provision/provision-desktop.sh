#!/usr/bin/env bash
set -eux

echo "Installing desktop environment..."

# Update package lists
sudo apt-get update

# Install XFCE desktop environment (minimal)
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    xfce4 \
    lightdm

# Enable display manager
sudo systemctl enable lightdm

# Create a marker file to indicate desktop provisioning
echo 'desktop-provisioned-by-packer' | sudo tee /etc/desktop-provisioned-by-packer

# Clean up package caches
echo "Cleaning up package caches..."
sudo apt-get -y autoremove --purge
sudo apt-get -y clean
sudo rm -rf /var/lib/apt/lists/*
