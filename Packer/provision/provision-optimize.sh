#!/usr/bin/env bash
set -eux

echo "Optimizing image size..."

# Remove temporary files
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# Remove log files
sudo find /var/log -type f -exec truncate -s 0 {} \;

# Remove man pages and documentation
sudo rm -rf /usr/share/doc/*
sudo rm -rf /usr/share/man/*

# Clear bash history if it exists
if [ -f /home/packer/.bash_history ]; then
  cat /dev/null > /home/packer/.bash_history && history -c
fi

# Zero out free space to improve compression
echo "Zeroing free space for better compression..."
sudo dd if=/dev/zero of=/EMPTY bs=1M oflag=direct 2>/dev/null || true
sudo rm -f /EMPTY

# Trim free space (helps qcow2 sparsity + compression)
sudo fstrim -av || true

# Sync to ensure all writes are flushed
sync
