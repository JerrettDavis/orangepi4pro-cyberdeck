# Validation

## Current SD System

Run:

```bash
../scripts/validate-current-sd.sh
```

Expected current facts:

- Device tree compatible includes `xunlong,orangepi-4-pro`.
- Kernel is an Orange Pi sun60iw2 build.
- Root filesystem is on `/dev/mmcblk1p1`.
- `/dev/nvme0n1` is visible and not mounted.
- Touch fallback bundle exists at `/home/orangepi/touchscreen-fix-src`.

## Future M.2 Boot

Run from the booted target OS:

```bash
../scripts/validate-future-m2.sh
```

Pass criteria:

- Root UUID matches intended Ubuntu or Kali partition.
- SD recovery still boots independently.
- Display reaches stable 1024x600 or better.
- Touch works via native HID multitouch or `qdtech-touch-x11` fallback.
- Networking, SSH, time sync, package manager, USB input, and NVMe are healthy.

