# Orange Pi 4 Pro Cyberdeck

Planning and runbooks for the Allwinner A733 / sun60iw2 Orange Pi 4 Pro
cyberdeck.

Current target board:

- Device tree compatible: `xunlong,orangepi-4-pro`, `arm,sun60iw2p1`
- Current recovery OS: Orange Pi Ubuntu Jammy on SD
- Current kernel: `5.15.147-sun60iw2`
- M.2 target: `/dev/nvme0n1`, Fanxiang S500Pro 256GB

This repository is intentionally documentation-first. Installation to M.2 is
not performed from this repo; destructive actions belong in reviewed scripts in
`orangepi4pro-images` and must remain disabled until the recovery checklist is
complete.

## Repositories

- `orangepi4pro-cyberdeck`: top-level plans, runbooks, decisions, inventory.
- `orangepi4pro-board-support`: kernel config, DTS workflow, touch/display
  support, board validation.
- `orangepi4pro-images`: Ubuntu/Kali rootfs and boot-asset assembly scripts.

## Safety Rules

- Keep the current SD card bootable as recovery.
- Do not write bootloader sectors, SPI, eMMC, or NVMe in planning sessions.
- Treat vendor U-Boot as legacy until `booti`, EFI, extlinux, and boot scripts
  are tested on removable/recoverable media.
- Prefer official distro repositories for userspace.

