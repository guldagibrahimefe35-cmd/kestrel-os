#!/usr/bin/env bash
# Kestrel OS - starter build script
# Run on a Debian or Ubuntu machine (a VM is fine) with internet access.
# Usage: sudo ./build-kestrel.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root: sudo ./build-kestrel.sh"
  exit 1
fi

apt-get update
apt-get install -y live-build debootstrap squashfs-tools xorriso

WORKDIR="$HOME/kestrel-build"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

lb clean --purge || true

lb config \
  --distribution trixie \
  --architectures amd64 \
  --archive-areas "main contrib non-free-firmware" \
  --binary-images iso-hybrid \
  --bootappend-live "boot=live components quiet splash username=kestrel hostname=kestrel" \
  --iso-application "Kestrel OS" \
  --iso-publisher "Kestrel OS Project" \
  --iso-volume "KESTREL"

mkdir -p config/package-lists
cat > config/package-lists/kestrel.list.chroot <<'EOF'
live-task-xfce
xfce4
xfce4-goodies
lightdm
network-manager
network-manager-gnome
firefox-esr
ca-certificates
firmware-linux-free
firmware-iwlwifi
firmware-realtek
firmware-atheros
pipewire-audio
file-roller
mousepad
EOF

mkdir -p config/includes.chroot/etc
cat > config/includes.chroot/etc/os-release <<'EOF'
PRETTY_NAME="Kestrel OS 0.1"
NAME="Kestrel OS"
VERSION="0.1"
ID=kestrel
ID_LIKE=debian
HOME_URL="https://example.com/kestrel"
EOF

mkdir -p config/includes.chroot/etc/skel/.config
mkdir -p config/includes.chroot/usr/share/applications

lb build

echo
echo "Done. Your ISO is in: $WORKDIR"
ls -lh "$WORKDIR"/*.iso
echo "Test it with: qemu-system-x86_64 -m 4G -enable-kvm -cdrom $WORKDIR/live-image-amd64.hybrid.iso"
