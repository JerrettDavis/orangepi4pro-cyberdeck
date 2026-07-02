# Orange Pi 4 Pro Cyberdeck

Planning and runbooks for the Allwinner A733 / sun60iw2 Orange Pi 4 Pro
cyberdeck.

Current target board:

- Device tree compatible: `xunlong,orangepi-4-pro`, `arm,sun60iw2p1`
- Current primary OS: Orange Pi Ubuntu Jammy cloned to NVMe
- Current kernel: `5.15.147-sun60iw2-cyberdeck`
- M.2 target: `/dev/nvme0n1`, Fanxiang S500Pro 256GB

This repository is intentionally documentation-first. Rootfs/image operations
belong in `orangepi4pro-images`; kernel, DTS, display, touch, and hardware
support belong in `orangepi4pro-board-support`.

## Repositories

- `orangepi4pro-cyberdeck`: top-level plans, runbooks, decisions, inventory.
- `orangepi4pro-board-support`: kernel config, DTS workflow, touch/display
  support, board validation.
- `orangepi4pro-images`: Ubuntu/Kali rootfs and boot-asset assembly scripts.

## Safety Rules

- Keep the SD card usable as removable recovery media when practical.
- Do not write bootloader sectors, SPI, or MTD firmware without a verified
  backup and rollback path.
- Treat vendor U-Boot as legacy until `booti`, EFI, extlinux, and boot scripts
  are tested on removable/recoverable media.
- Prefer official distro repositories for userspace.

## Validation

Run before pushing:

```bash
scripts/ci-checks.sh
```

## Releases

Push a `v*` tag after CI passes to publish a GitHub release containing a source
archive of this repo.
