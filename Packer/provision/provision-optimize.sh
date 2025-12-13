#!/usr/bin/env bash
set -euxo pipefail

echo "Optimizing image size..."

# Optional toggles (set to 0 to skip)
REMOVE_SNAP=1
REMOVE_LOCALES=0   # set to 1 only if you do not need non-English locales
REMOVE_DOCS=1

# Remove temporary files
sudo rm -rf /tmp/* /var/tmp/* || true

# Truncate log files (keep files)
sudo find /var/log -type f -exec truncate -s 0 {} \; || true

# Vacuum systemd journal (often large)
if command -v journalctl >/dev/null 2>&1; then
  sudo journalctl --rotate || true
  sudo journalctl --vacuum-time=1s || true
  sudo rm -rf /var/log/journal/* || true
fi

# Remove docs/man/info/help (optional)
if [ "$REMOVE_DOCS" -eq 1 ]; then
  sudo rm -rf /usr/share/doc/* /usr/share/man/* /usr/share/info/* /usr/share/help/* \
              /usr/share/gtk-doc/* /usr/share/gnome/help/* || true
  # Wallpapers can be large
  sudo rm -rf /usr/share/backgrounds/* || true
fi

# Apt cleanup (safe even if already done earlier)
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get -y autoremove --purge || true
  sudo apt-get clean || true
  sudo rm -rf /var/lib/apt/lists/* || true
fi

# Remove Snap (Ubuntu size win; skip if you rely on snaps at runtime)
if [ "$REMOVE_SNAP" -eq 1 ] && command -v snap >/dev/null 2>&1; then
  snaps="$(snap list 2>/dev/null | awk 'NR>1 {print $1}' || true)"
  for s in $snaps; do
    sudo snap remove --purge "$s" || true
  done
  sudo systemctl disable --now snapd.socket snapd.service 2>/dev/null || true
  sudo apt-get -y purge snapd || true
  sudo rm -rf /var/cache/snapd/ /var/lib/snapd/ /snap/ || true
fi

# Optional: remove most locales (big win; only enable if acceptable)
if [ "$REMOVE_LOCALES" -eq 1 ]; then
  sudo rm -rf /usr/share/locale/* /usr/share/i18n/* || true
  sudo mkdir -p /usr/share/locale/en /usr/share/locale/en_GB /usr/share/locale/en_US 2>/dev/null || true
fi

# Clear caches
sudo rm -rf /var/cache/* /root/.cache/* /home/*/.cache/* || true
sudo rm -rf /home/*/.cache/thumbnails/* 2>/dev/null || true

# Clear bash history if it exists
if [ -f /home/packer/.bash_history ]; then
  sudo sh -c ': > /home/packer/.bash_history' || true
  history -c || true
fi

# Make machine-id regenerate on first boot (small win + cleaner template)
sudo truncate -s 0 /etc/machine-id 2>/dev/null || true
sudo rm -f /var/lib/dbus/machine-id 2>/dev/null || true

# Trim free space (requires discard/unmap configured in QEMU/Packer for best effect)
sudo fstrim -av || true

sync