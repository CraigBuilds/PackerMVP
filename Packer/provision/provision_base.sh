#!/usr/bin/env bash
set -eux

echo 'provisioned-by-packer' | sudo tee /etc/provisioned-by-packer


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

# Zero out free space to improve compression
echo "Zeroing free space for better compression..."
sudo dd if=/dev/zero of=/EMPTY bs=1M || true
sudo rm -f /EMPTY

# Trim free space (helps qcow2 sparsity + compression)
fstrim -av || true

# Sync to ensure all writes are flushed
sync