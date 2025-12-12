#!/usr/bin/env bash
set -eux

echo 'provisioned-by-packer' | sudo tee /etc/provisioned-by-packer

sudo apt-get update
sudo apt-get install -y ca-certificates curl

sudo systemctl enable --now ssh

# Clean up to reduce image size
echo "Cleaning up to reduce image size..."

# Remove package manager caches
sudo apt-get clean
sudo apt-get autoclean
sudo apt-get autoremove -y

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

# Sync to ensure all writes are flushed
sync