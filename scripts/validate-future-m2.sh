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
if timedatectl show -p NTPSynchronized -p CanNTP >/tmp/orangepi4pro-timedatectl.$$ 2>/tmp/orangepi4pro-timedatectl.err.$$; then
  if grep -Eq "yes|true" /tmp/orangepi4pro-timedatectl.$$; then
    printf '[OK] systemd time sync active or available\n'
  else
    printf '[WARN] systemd time sync not active yet\n'
  fi
else
  printf '[WARN] timedatectl unavailable: %s\n' "$(tr '\n' ' ' < /tmp/orangepi4pro-timedatectl.err.$$)"
fi
rm -f /tmp/orangepi4pro-timedatectl.$$ /tmp/orangepi4pro-timedatectl.err.$$

printf '\nRoot source: %s\nRoot UUID: %s\n' "$root_source" "$root_uuid"
printf '\nTouch/input config:\n'
if [ -r /proc/config.gz ]; then
  zgrep -E 'CONFIG_(HID_MULTITOUCH|HIDRAW|UHID|INPUT_UINPUT|USB_HID|INPUT_EVDEV)=' /proc/config.gz || true
fi

printf '\nBlock devices:\n'
lsblk -o NAME,SIZE,MODEL,SERIAL,TYPE,FSTYPE,LABEL,UUID,MOUNTPOINTS

exit "$fail"
