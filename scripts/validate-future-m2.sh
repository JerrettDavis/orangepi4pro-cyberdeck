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

root_source="$(findmnt -n -o SOURCE / || true)"
root_uuid="$(blkid -s UUID -o value "$root_source" 2>/dev/null || true)"

check "booted from an NVMe-backed root" bash -c 'findmnt -n -o SOURCE / | grep -q nvme'
check "root UUID available" test -n "$root_uuid"
check "SD recovery device still visible" test -b /dev/mmcblk1
check "NVMe base device visible" test -b /dev/nvme0n1
check "network has a default route" bash -c 'ip route | grep -q "^default "'
check "systemd time sync active or available" bash -c 'timedatectl show -p NTPSynchronized -p CanNTP 2>/dev/null | grep -Eq "yes|true"'

printf '\nRoot source: %s\nRoot UUID: %s\n' "$root_source" "$root_uuid"
printf '\nTouch/input config:\n'
if [ -r /proc/config.gz ]; then
  zgrep -E 'CONFIG_(HID_MULTITOUCH|HIDRAW|UHID|INPUT_UINPUT|USB_HID|INPUT_EVDEV)=' /proc/config.gz || true
fi

printf '\nBlock devices:\n'
lsblk -o NAME,SIZE,MODEL,SERIAL,TYPE,FSTYPE,LABEL,UUID,MOUNTPOINTS

exit "$fail"
