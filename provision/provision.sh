#!/usr/bin/env bash
set -eux

# ============================================================================
# Environment variables passed from Packer:
# ============================================================================
# - VM_NAME: Name of the VM
# - VM_HOSTNAME: Hostname of the VM  
# - SSH_USERNAME: SSH username configured for the VM
# - INSTALL_DESKTOP: Whether to install Ubuntu Desktop (true/false)
# - AGGRESSIVE_CLEANUP: Whether to perform aggressive size reduction (true/false)

echo "=== Provisioning Configuration ==="
echo "VM Name: ${VM_NAME:-unknown}"
echo "Hostname: ${VM_HOSTNAME:-unknown}"
echo "User: ${SSH_USERNAME:-unknown}"
echo "Install Desktop: ${INSTALL_DESKTOP:-false}"
echo "Aggressive Cleanup: ${AGGRESSIVE_CLEANUP:-false}"
echo "==================================="

echo 'provisioned-by-packer' | sudo tee /etc/provisioned-by-packer

# ============================================================================
# Desktop Environment Installation
# ============================================================================
if [ "${INSTALL_DESKTOP}" = "true" ]; then
  echo "Installing Ubuntu Desktop environment..."
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ubuntu-desktop-minimal
  
  # Enable graphical target
  sudo systemctl set-default graphical.target
else
  echo "Skipping Ubuntu Desktop installation (INSTALL_DESKTOP=${INSTALL_DESKTOP})"
fi

# ============================================================================
# Aggressive Cleanup (optional - reduces image size significantly)
# ============================================================================
if [ "${AGGRESSIVE_CLEANUP}" = "true" ]; then
  echo "Performing aggressive cleanup to reduce image size..."
  
  # Remove snap packages to save significant space
  echo "Removing snap packages..."
  sudo systemctl stop snapd || true
  sudo systemctl disable snapd || true
  for snap in $(snap list | awk 'NR>1 {print $1}'); do
      sudo snap remove --purge "$snap" || true
  done
  sudo apt-get purge -y snapd gnome-software-plugin-snap || true
  sudo rm -rf /snap /var/snap /var/lib/snapd ~/snap || true
  
  # Remove old kernels (keep only current)
  echo "Removing old kernels..."
  sudo apt-get purge -y $(dpkg -l 'linux-image-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d') || true
  
  # Install and configure localepurge to remove unnecessary locale files
  echo "Removing unnecessary locales..."
  echo 'localepurge localepurge/nopurge multiselect en_US.UTF-8' | sudo debconf-set-selections
  echo 'localepurge localepurge/use-dpkg-feature boolean false' | sudo debconf-set-selections
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends localepurge
  sudo localepurge
  
  # Remove unnecessary packages
  echo "Removing unnecessary packages..."
  sudo apt-get purge -y \
      ubuntu-wallpapers* \
      gnome-games \
      aisleriot \
      gnome-mahjongg \
      gnome-mines \
      gnome-sudoku \
      thunderbird* \
      libreoffice* \
      rhythmbox* \
      shotwell* \
      totem* \
      transmission* \
      cheese* || true
  
  # Remove man pages and documentation
  sudo rm -rf /usr/share/doc/*
  sudo rm -rf /usr/share/man/*
  sudo rm -rf /usr/share/info/*
  sudo rm -rf /usr/share/lintian/*
  sudo rm -rf /usr/share/linda/*
  
  # Remove cached files
  sudo rm -rf /var/cache/*
  
  # Zero out free space for better compression
  echo "Zeroing free space for better compression..."
  sudo dd if=/dev/zero of=/EMPTY bs=1M || true
  sudo rm -f /EMPTY
else
  echo "Skipping aggressive cleanup (AGGRESSIVE_CLEANUP=${AGGRESSIVE_CLEANUP})"
fi

# ============================================================================
# Standard Cleanup (always performed)
# ============================================================================
echo "Performing standard cleanup..."

# Clean up package manager
sudo apt-get -y autoremove --purge
sudo apt-get -y clean
sudo apt-get -y autoclean
sudo rm -rf /var/lib/apt/lists/*

# Remove temporary files
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# Remove log files
sudo find /var/log -type f -exec truncate -s 0 {} \;

# Clear bash history
if [ -f ~/.bash_history ]; then
  cat /dev/null > ~/.bash_history && history -c
fi
if [ -f /root/.bash_history ]; then
  sudo rm -f /root/.bash_history
fi

# Trim free space (helps qcow2 sparsity + compression)
fstrim -av || true

# Sync to ensure all writes are flushed
sync

echo "=== Provisioning Complete ==="
