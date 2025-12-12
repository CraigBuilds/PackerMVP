#!/usr/bin/env bash
set -eux

echo "Installing desktop environment..."

# Update package lists
sudo apt-get update

# Install XFCE desktop environment (lightweight)
# Feel free to change to ubuntu-desktop, kubuntu-desktop, etc.
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    xfce4 \
    xfce4-goodies \
    lightdm \
    firefox

# Enable display manager
sudo systemctl enable lightdm

# Create a marker file to indicate desktop provisioning
echo 'desktop-provisioned-by-packer' | sudo tee /etc/desktop-provisioned-by-packer

# Clean up to reduce image size
echo "Cleaning up to reduce image size..."

# Remove package manager caches
sudo apt-get -y autoremove --purge
sudo apt-get -y clean
sudo rm -rf /var/lib/apt/lists/*

# Remove temporary files
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# Remove log files
sudo find /var/log -type f -exec truncate -s 0 {} \;

# Remove man pages and documentation (optional, saves space)
sudo rm -rf /usr/share/doc/*
sudo rm -rf /usr/share/man/*

# Clear bash history if it exists
if [ -f ~/.bash_history ]; then
  cat /dev/null > ~/.bash_history && history -c
fi

# Trim free space (helps qcow2 sparsity + compression)
fstrim -av || true

# Sync to ensure all writes are flushed
sync
