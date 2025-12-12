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
# Limit to 1GB or fail gracefully to avoid filling disk
sudo dd if=/dev/zero of=/EMPTY bs=1M count=1024 2>/dev/null || true
sudo rm -f /EMPTY

# Clear bash history files safely
sudo find /home -type f -name '.bash_history' -exec rm -f {} + 2>/dev/null || true
sudo rm -f /root/.bash_history 2>/dev/null || true