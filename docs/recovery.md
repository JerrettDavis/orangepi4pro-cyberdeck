# Recovery Plan

The current SD installation is recovery media. Do not overwrite it.

## Before M.2 Install

Create an SD image backup to external storage with enough free space:

```bash
sudo dd if=/dev/mmcblk1 of=/path/to/orangepi4pro-stock-sd-20260702.img bs=16M status=progress conv=fsync
sha256sum /path/to/orangepi4pro-stock-sd-20260702.img > /path/to/orangepi4pro-stock-sd-20260702.img.sha256
sudo sfdisk -d /dev/mmcblk1 > stock-sd.sfdisk
```

Capture live system state:

```bash
mkdir -p recovery-capture
uname -a > recovery-capture/uname.txt
lsblk -o NAME,SIZE,MODEL,SERIAL,TYPE,FSTYPE,LABEL,MOUNTPOINTS > recovery-capture/lsblk.txt
sudo dmesg > recovery-capture/dmesg.txt
cp -a /boot recovery-capture/boot
cp -a /home/orangepi/touchscreen-fix-src recovery-capture/touchscreen-fix-src
```

## Required Recovery Inputs

- Current SD card kept physically labeled and bootable.
- USB keyboard/mouse available.
- Second SD card with stock image if possible.
- Serial console details from the A733 manual before bootloader experiments.
- Checksums for any bootloader, kernel, DTB, rootfs, or image assets.

## Do Not Do Yet

- Do not write `/dev/nvme0n1`.
- Do not write `/dev/mtdblock0`.
- Do not overwrite SD bootloader sectors.
- Do not make GRUB or mainline U-Boot the only boot path.

