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

# Zero out free space to improve compression (limit to avoid excessive time)
sudo dd if=/dev/zero of=/EMPTY bs=1M count=1024 || true
sudo rm -f /EMPTY

# Clear bash history files
sudo rm -f ~/.bash_history /root/.bash_history /home/*/.bash_history