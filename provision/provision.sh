#!/usr/bin/env bash
set -eux

echo 'provisioned-by-packer' | sudo tee /etc/provisioned-by-packer

sudo apt-get update
sudo apt-get install -y ca-certificates curl

sudo systemctl enable --now ssh

# Clean up to reduce image size
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# Zero out free space to improve compression
sudo dd if=/dev/zero of=/EMPTY bs=1M || true
sudo rm -f /EMPTY

# Clear bash history
history -c