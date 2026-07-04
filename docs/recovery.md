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

## Codex Resume After Reboot

This machine starts a detached `tmux` session for the active Codex thread at
boot through `orangepi-codex-resume.service`. Install or refresh the service
and XFCE terminal attach helper with:

```bash
sudo scripts/install-codex-resume-autostart.sh
```

After reboot, the XFCE autostart should open a terminal attached to the tmux
session. If it does not, attach manually:

```bash
/usr/local/bin/codex-attach
```

The desktop autostart runs as user `orangepi`, while the Codex tmux session is
root-owned so it can continue the same privileged recovery workflow. The
installer adds `/etc/sudoers.d/orangepi-codex-resume` with passwordless access
only for the exact `tmux has-session`, `tmux attach`, and service-start
commands needed by `/usr/local/bin/codex-attach`. The terminal launcher uses
`xfce4-terminal --hold` so attach failures remain visible instead of closing
the window immediately.

If the service did not start, run:

```bash
sudo systemctl start orangepi-codex-resume.service
/usr/local/bin/codex-attach
```

The service uses:

```text
/usr/local/bin/orangepi-codex-resume
/usr/local/bin/codex-attach
/usr/local/bin/codex-terminal-autostart
/etc/systemd/system/orangepi-codex-resume.service
/etc/sudoers.d/orangepi-codex-resume
/home/orangepi/.config/autostart/codex-orange.desktop
tmux session: codex-orange
```

## Do Not Do Yet

- Do not write `/dev/nvme0n1`.
- Do not write `/dev/mtdblock0`.
- Do not overwrite SD bootloader sectors.
- Do not make GRUB or mainline U-Boot the only boot path.
