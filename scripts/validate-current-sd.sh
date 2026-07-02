#!/usr/bin/env bash
set -euo pipefail

fail=0

check() {
  local name=$1
  shift
  if "$@"; then
    printf '[OK] %s\n' "$name"
  else
    printf '[FAIL] %s\n' "$name"
    fail=1
  fi
}

compat="$(tr '\0' '\n' < /proc/device-tree/compatible 2>/dev/null || true)"
root_source="$(findmnt -n -o SOURCE / || true)"

check "Orange Pi 4 Pro compatible string" grep -qx 'xunlong,orangepi-4-pro' <<<"$compat"
check "sun60iw2 compatible string" grep -qx 'arm,sun60iw2p1' <<<"$compat"
check "sun60iw2 kernel" bash -c 'uname -r | grep -q sun60iw2'
check "root filesystem on SD partition" test "$root_source" = "/dev/mmcblk1p1"
check "NVMe device visible" test -b /dev/nvme0n1
check "NVMe not mounted" bash -c '! findmnt -S /dev/nvme0n1 >/dev/null 2>&1 && ! lsblk -nr -o MOUNTPOINT /dev/nvme0n1 | grep -q .'
check "touch fallback source present" test -f /home/orangepi/touchscreen-fix-src/README.md

printf '\nKernel config touch-related state:\n'
if [ -r /proc/config.gz ]; then
  zgrep -E 'CONFIG_(HID_MULTITOUCH|HIDRAW|UHID|INPUT_UINPUT)=' /proc/config.gz || true
else
  printf '  /proc/config.gz is not readable\n'
fi

exit "$fail"

