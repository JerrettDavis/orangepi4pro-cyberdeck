# Orange Pi 4 Pro Cyberdeck M.2 Multiboot Plan

Status: planning only. Do not implement from this document without first
creating the repos, scripts, backups, and rollback media described below.

Date: 2026-07-02

## 1. Current Known Hardware State

Board identity from the running system:

- Device tree model: `sun60iw2`
- Compatible strings: `xunlong,orangepi-4-pro`, `arm,sun60iw2p1`
- SoC family: Allwinner A733 / `sun60iw2`
- Current OS: Orange Pi Ubuntu Jammy 22.04.5 image
- Current kernel: `5.15.147-sun60iw2`
- Current boot medium: SD card, `/dev/mmcblk1p1`
- M.2 drive: `/dev/nvme0n1`, `Fanxiang S500Pro 256GB`, 238.5 GiB usable
- Display: HDMI panel at `1024x600`
- Touch controller: QDtech/Specialix MPI7003, USB VID:PID `0484:5750`

Important correction: this is not the older RK3399 Orange Pi 4 family. Treat
all RK3399 Orange Pi 4/LTS docs as non-authoritative unless they are explicitly
about the new Orange Pi 4 Pro Allwinner A733 board.

## 2. Design Goals

Primary goals:

- Boot Ubuntu and Kali from the M.2 drive.
- Preserve SD-card boot as first-line recovery.
- Keep the current stock Orange Pi image bootable until the M.2 install is
  independently verified.
- Prefer upstream/mainline Linux distribution userspace over vendor package
  repositories.
- Isolate hardware-specific board enablement in our own repos as patches,
  scripts, configs, and documented binary provenance.
- Make display, touch, networking, storage, power, and input predictable on
  every installed OS.
- Keep the 256 GB NVMe layout conservative enough for future Arch or rescue
  partitions.

Non-goals for the first install:

- Do not replace the board boot firmware blindly.
- Do not make GRUB the only boot path until U-Boot/EFI behavior is proven.
- Do not depend on Huawei mirror package URLs except as temporary mirrors for
  the current stock OS.
- Do not assume multitouch in bootloader menus.

## 3. Source Research To Finalize

Authoritative or useful upstream/vendor sources to track:

- Official Orange Pi 4 Pro support page:
  `https://www.orangepi.org/html/hardWare/computerAndMicrocontrollers/service-and-support/Orange-Pi-4-Pro.html`
- Official Orange Pi 4 Pro A733 user manual PDF:
  `https://orangepi.net/wp-content/uploads/2026/01/OrangePi_4_Pro_A733_User-Manual_v1.4.pdf`
- Vendor kernel source, 6.6 branch:
  `https://github.com/orangepi-xunlong/linux-orangepi/tree/orange-pi-6.6-sun60iw2`
- Vendor kernel source, current 5.15 branch:
  `https://github.com/orangepi-xunlong/linux-orangepi/tree/orange-pi-5.15-sun60iw2`
- Vendor U-Boot source:
  `https://github.com/orangepi-xunlong/u-boot-orangepi/tree/v2018.05-sun60iw2`
- Vendor build scripts:
  `https://github.com/orangepi-xunlong/orangepi-build`
- Mainline U-Boot:
  `https://source.denx.de/u-boot/u-boot`
- Mainline Linux:
  `https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git`
- Armbian build framework:
  `https://github.com/armbian/build`
- Community mainline-oriented A733/Orange Pi 4 Pro work:
  `https://github.com/jonas5/orangepi-4pro-armbian`
- PostmarketOS device notes:
  `https://wiki.postmarketos.org/wiki/Xunlong_Orange_Pi_4_Pro_(xunlong-orangepi4-pro)`
- NVMe Gen1 device-tree workaround:
  `https://github.com/CarterPerez-dev/orangepi-4-pro-nvme-fix`

Known facts to verify again in the new session:

- Vendor Linux 6.6 branch exists for `sun60iw2`.
- Vendor Linux 5.15 branch matches the current stock image lineage.
- Vendor U-Boot is `v2018.05-sun60iw2` and is reported to be 32-bit and legacy
  image oriented, with no normal `booti` workflow.
- Mainline U-Boot has partial A733 work, but not yet enough to treat as a safe
  primary bootloader.
- Community work exists for Armbian/mainline 6.x on Orange Pi 4 Pro, but must
  be audited before trusting it.

## 4. Repository Plan Under github.com/jerrettdavis

Create these repos or equivalent names:

1. `orangepi4pro-cyberdeck`
   - Top-level docs, issue tracker, hardware inventory, install runbooks.
   - Holds this plan and final decision records.

2. `orangepi4pro-board-support`
   - Board support package overlay.
   - Kernel config fragments.
   - Device-tree patches.
   - U-Boot/boot script patches.
   - Touch bridge source and packaging.
   - Display setup scripts.
   - Recovery scripts.

3. `orangepi4pro-images`
   - Image/rootfs assembly scripts.
   - Debootstrap/mmdebstrap scripts for Ubuntu and Kali.
   - Partition layout generator.
   - GRUB/U-Boot boot asset generator.
   - No large binary images committed.

4. Optional later: `orangepi4pro-cyberdeck-packages`
   - Debian package sources for `qdtech-touch-x11`, config packages, metapackage,
     and convenience tools.
   - This can also be a subdirectory in `orangepi4pro-board-support`.

Each repo needs:

- `README.md`
- `LICENSE`
- `docs/sources.md` with URLs, commit IDs, checksums, and date verified.
- `docs/recovery.md`
- `docs/install-to-m2.md`
- `docs/validation.md`
- `scripts/`
- `configs/`
- `.gitignore`

## 5. Boot Architecture

Recommended boot architecture for first M.2 milestone:

```text
Boot ROM
  -> stock/vendor bootloader from SD or board flash path
  -> U-Boot legacy boot menu / boot.scr
  -> per-OS kernel + initrd + DTB from shared boot partition
  -> rootfs on M.2 partitions
```

Reasoning:

- The current stock image already boots reliably.
- Vendor U-Boot is old but known to load `uImage`/`uInitrd`.
- Reports indicate vendor U-Boot may not support a clean modern `booti` flow.
- Mainline U-Boot should be researched, but not made mandatory for first M.2
  boot.

Second-stage experiment:

```text
stock/vendor U-Boot
  -> EFI payload or GRUB EFI if supported
  -> GRUB menu
  -> Ubuntu/Kali kernels
```

Research tasks for GRUB:

- Determine whether current vendor U-Boot has EFI loader support.
- Determine whether it can load `grubaa64.efi` from FAT/ext4.
- Test GRUB from removable media first, never as sole boot path.
- Confirm whether GRUB can load the needed DTB and pass it to Linux.
- Confirm whether GRUB can boot legacy `uImage` if needed, or whether it needs
  standard uncompressed/Image kernels.

Touch in GRUB:

- Treat integrated touch in GRUB as unlikely for this hardware.
- GRUB generally expects keyboard/serial input; USB HID touchscreen handling is
  not a safe assumption.
- For recovery, require one of:
  - USB keyboard/mouse,
  - serial console,
  - timeout/default boot,
  - SD-card fallback.
- If touch in boot UI is still desired, investigate a later custom U-Boot menu
  or a tiny Linux-based boot chooser, not first-stage GRUB.

## 6. M.2 Partition Layout Proposal

Target disk: `/dev/nvme0n1`, 238.5 GiB usable.

Use GPT. Proposed conservative layout:

| Partition | Size | FS | Label | Purpose |
| --- | ---: | --- | --- | --- |
| p1 | 512 MiB | FAT32 | `OPI_EFI` | EFI/GRUB experiments and portable boot assets |
| p2 | 2 GiB | ext4 | `OPI_BOOT` | Shared kernels, initrds, DTBs, boot scripts |
| p3 | 50 GiB | ext4 | `UBUNTU_ROOT` | Ubuntu root |
| p4 | 45 GiB | ext4 | `KALI_ROOT` | Kali root |
| p5 | 24 GiB | ext4 | `TOOLS` | Shared cyberdeck tools/data cache |
| p6 | 32 GiB | ext4 | `HOME` | Shared or bind-mounted home/data, optional |
| p7 | 32 GiB | ext4 | `RESCUE_OR_ARCH` | Future Arch/rescue OS |
| p8 | rest | ext4 or btrfs | `IMAGES_CACHE` | installers, package caches, image staging |

Swap:

- Prefer zram in each OS.
- Avoid fixed swap partition unless hibernation is required.

Alternative:

- Use separate `/boot` per distro if shared boot becomes fragile.
- Use Btrfs subvolumes only after first stable ext4 boot path is proven.

## 7. OS Base Strategy

Ubuntu:

- Prefer official Ubuntu arm64 rootfs/minimal via `mmdebstrap` or `debootstrap`.
- Candidate releases:
  - Ubuntu 24.04 LTS noble for current LTS.
  - Ubuntu 26.04 LTS only if released and package compatibility is acceptable.
- Avoid relying on Orange Pi/Huawei package mirrors except for extracting
  board-specific files from the current stock image.

Kali:

- Use official Kali arm64 rootfs / debootstrap path.
- Keep Kali lean:
  - base system,
  - networking,
  - terminal tools,
  - selected wireless/security tools,
  - no giant default metapackages at first.
- Add cyberdeck tool profile incrementally.

Arch later:

- Treat as third milestone.
- Use Arch Linux ARM only if AArch64 rootfs and kernel packaging are practical
  for this board.

## 8. Kernel Strategy

Milestone 1 kernel:

- Start from vendor `orange-pi-6.6-sun60iw2` if it boots and contains enough
  board support.
- Fallback to current vendor `5.15.147-sun60iw2` with our required config
  additions if 6.6 is not ready.

Required kernel config additions over current stock:

- `CONFIG_HID_MULTITOUCH=y` or `m`
- `CONFIG_HIDRAW=y`
- `CONFIG_UHID=y`
- `CONFIG_INPUT_UINPUT=y`
- `CONFIG_USB_HID=y`
- `CONFIG_INPUT_EVDEV=y`
- `CONFIG_DRM=y`
- HDMI/display pipeline options required by A733 BSP/mainline status
- `CONFIG_NVME_CORE=y/m`
- `CONFIG_BLK_DEV_NVME=y/m`
- `CONFIG_PCIE_DW*` and Allwinner PCIe driver options as applicable
- `CONFIG_TUN=m/y`
- `CONFIG_OVERLAY_FS=y`
- `CONFIG_CGROUPS`, namespaces, nftables, bridge, veth for containers/tools
- Wi-Fi/Bluetooth drivers for the board module, if known
- Common USB serial adapters for recovery
- Filesystems: ext4, vfat, exfat, btrfs optional

Device-tree tasks:

- Extract current DTB:
  `/boot/dtb/allwinner/sun60i-a733-orangepi-4-pro.dtb`
- Decompile and store as reference in private research artifacts, not as a
  hand-edited binary.
- Track DTS patches only.
- Validate HDMI mode, USB topology, M.2 PCIe, regulators, Wi-Fi/BT, LEDs,
  thermal zones, fans if present, and input devices.
- Add optional PCIe Gen1 override if this specific Fanxiang NVMe exhibits link
  instability.

Known touch issue:

- Current kernel lacks `HID_MULTITOUCH`, `HIDRAW`, and `UHID`, causing the
  QDtech touchscreen to pin at `1024,600`.
- Current workaround is `/usr/local/bin/qdtech-touch-x11`, stored at:
  `/home/orangepi/touchscreen-fix-src`
- The proper future fix is kernel HID multitouch support.
- Keep the X11 bridge packaged as fallback for any OS/kernel combination where
  HID multitouch still fails.

## 9. Display and Touch Strategy

Display:

- First target is known-good HDMI `1024x600`.
- Capture EDID and xrandr output from current system.
- Store any required modeline or Xorg snippet in board support repo.
- Prefer kernel DRM/KMS + Xorg/Wayland standard paths.

Touch:

- Preferred future path:
  - kernel `hid-multitouch`,
  - libinput,
  - standard Xorg/Wayland touch.
- Fallback path:
  - `qdtech-touch-x11` for Xorg only.
- Calibration file:
  `/etc/qdtech-touch-x11.conf`
- Current tuned fallback values:
  - `MIN_X=22`
  - `MAX_X=994`
  - `MIN_Y=-5`
  - `MAX_Y=544`

Wayland note:

- The current X11 bridge uses XTest and will not solve Wayland globally.
- For Wayland fallback, implement a uinput bridge after kernel `UINPUT` exists.

## 10. Recovery Strategy

Before touching the M.2:

- Create a full SD card image backup:
  `dd if=/dev/mmcblk1 of=/path/to/orangepi4pro-stock-sd-YYYYMMDD.img bs=16M status=progress conv=fsync`
- Save partition table:
  `sfdisk -d /dev/mmcblk1 > stock-sd.sfdisk`
- Save `/boot`, `/etc`, kernel config, DTB, and current touch bundle.
- Verify the backup image can be mounted.

Recovery media:

- Keep current SD card bootable and physically labeled.
- Prepare a second SD card with stock Orange Pi image if available.
- Keep USB keyboard available.
- If UART pins are accessible, prepare USB-UART serial cable and document baud
  rate/pinout from manual before bootloader work.

Bootloader safety:

- Do not write bootloader sectors to the M.2 until the partitioned rootfs boot
  path works from SD-controlled boot.
- Do not overwrite SPI/eMMC boot firmware unless the board has a documented
  recovery path and the exact original image is backed up.
- Any bootloader experiment gets a rollback command and checksum.

## 11. Build/Install Workflow For Next Session

Phase A: repo preparation

- Create repos under `github.com/jerrettdavis`.
- Add this plan.
- Add `touchscreen-fix-src` content to board support repo.
- Add source manifest with URLs, branches, commits, and checksums.
- Add scripts that only inspect/report at first.

Phase B: source acquisition

- Clone vendor kernel 6.6 and 5.15.
- Clone vendor U-Boot.
- Clone Armbian build and community A733/4 Pro references.
- Mirror or vendor only patch files, not large source dumps.
- Record exact commit IDs.

Phase C: stock extraction

- Extract current:
  - `/boot`
  - `/proc/config.gz` or `/boot/config-*`
  - DTB
  - `orangepiEnv.txt`
  - `boot.cmd`, `boot.scr`
  - current modules list
  - `dmesg`
  - `lsusb -v`, `lspci -vvv`, `lsblk`, `xrandr`, `libinput list-devices`

Phase D: image assembly scripts

- Write `scripts/mk-partitions.sh` but make it dry-run by default.
- Write `scripts/bootstrap-ubuntu.sh`.
- Write `scripts/bootstrap-kali.sh`.
- Write `scripts/install-board-support.sh`.
- Write `scripts/build-kernel.sh`.
- Write `scripts/build-boot-assets.sh`.
- Write `scripts/validate-live.sh`.

Phase E: boot design implementation, still off-device

- Generate `uImage`/`uInitrd` assets if vendor U-Boot requires legacy format.
- Generate extlinux or boot scripts if supported.
- Generate optional GRUB EFI tree under `OPI_EFI`, but do not rely on it.
- Produce a printed boot menu design and timeout defaults.

Phase F: install readiness review

- Confirm every destructive command is behind an explicit prompt.
- Confirm all target devices are matched by stable identifiers.
- Confirm scripts refuse to run if `/dev/nvme0n1` is mounted unexpectedly.
- Confirm SD backup exists and has checksum.
- Confirm rootfs tarballs and kernels have checksums.

## 12. Validation Matrix

Pre-install validation:

- `lsblk` sees `/dev/nvme0n1`.
- `smartctl` or `nvme smart-log` works if available.
- `dmesg` has no repeated NVMe resets.
- Current SD system still boots after udev/touch changes.
- Touch works via bridge.
- HDMI mode is stable at `1024x600`.

First M.2 boot validation:

- Board boots into selected Ubuntu root from M.2.
- SD remains removable recovery boot.
- Kernel command line points root at expected UUID.
- `/boot` assets match selected OS.
- Networking works.
- SSH works.
- Display works.
- Touch works by native HID multitouch or fallback bridge.
- USB keyboard/mouse works.
- Time sync works.
- Package manager uses official distro repositories.

Kali validation:

- Boots from M.2 root.
- Same board support package installed.
- Touch/display/network are equivalent to Ubuntu.
- Cyberdeck tools install from selected minimal profile.
- Disk usage stays within budget.

Bootloader validation:

- Default boots Ubuntu.
- Boot menu can select Kali.
- Timeout fallback works without keyboard.
- Failed boot can be recovered by SD card.
- Optional GRUB path can boot at least one kernel before it is used for both.

Kernel validation:

- `zgrep HID_MULTITOUCH /proc/config.gz`
- `zgrep HIDRAW /proc/config.gz`
- `zgrep UINPUT /proc/config.gz`
- `libinput list-devices`
- `evtest` shows moving touch coordinates.
- `dmesg` has no HDMI, USB, NVMe, regulator, or thermal errors requiring action.

## 13. Cyberdeck Tooling Budget

Initial shared tool profile:

- Shell/dev: git, curl, jq, ripgrep, vim/neovim, tmux, build-essential.
- Network: nmap, tcpdump, tshark or wireshark-cli, iperf3, socat, netcat-openbsd.
- Wireless/bluetooth only after onboard adapters are validated.
- Containers only if overlayfs/cgroups are confirmed.
- Avoid huge Kali metapackages initially.

Space targets:

- Ubuntu root under 25 GiB initially.
- Kali root under 25 GiB initially.
- Shared tools/cache under 24 GiB.
- Keep at least 40 GiB unallocated or easily reclaimable until Arch/rescue plan
  is finalized.

## 14. Open Questions For New Session

- Does Orange Pi 4 Pro A733 have usable SPI flash or only SD/eMMC-style boot
  on this model?
- Does vendor U-Boot on this board support EFI loader, extlinux, or only
  `boot.scr` + legacy images?
- Does the vendor 6.6 kernel boot and support HDMI/NVMe/USB reliably?
- Is the Fanxiang S500Pro stable at Gen3, or should we force PCIe Gen1 in DT?
- Can mainline 6.10+ or newer boot far enough with patched DTS?
- Is a custom U-Boot practical, or should stock U-Boot remain the first-stage
  indefinitely?
- Is Wayland required, or is Xorg acceptable for the cyberdeck UI?

## 15. Handoff Prompt For New Session

Use the prompt below to start the next session.

```text
We are continuing the Orange Pi 4 Pro cyberdeck project. The board is the new
Allwinner A733 / sun60iw2 Orange Pi 4 Pro, confirmed by device tree compatible
strings `xunlong,orangepi-4-pro` and `arm,sun60iw2p1`. The current system boots
from SD on Orange Pi Ubuntu Jammy with kernel `5.15.147-sun60iw2`; the M.2 NVMe
drive is `/dev/nvme0n1`, model `Fanxiang S500Pro 256GB`, 238.5 GiB usable.

Read this plan first:
`/home/orangepi/orangepi4pro-m2-multiboot-plan.md`

Also read the current touch/display compatibility bundle:
`/home/orangepi/touchscreen-fix-src/README.md`

Goal for this session: do not install to the M.2 yet. Prepare personal repos
under `github.com/jerrettdavis` for the Orange Pi 4 Pro cyberdeck board support
and image build system. Finalize source research, capture exact source URLs,
branches, and commits, and create scripts/docs that make the third session ready
to install Ubuntu and Kali onto the M.2 safely.

Required repos or equivalent structure:
- `orangepi4pro-cyberdeck`
- `orangepi4pro-board-support`
- `orangepi4pro-images`

Must include:
- source manifest with official/vendor/upstream/community URLs and commit IDs
- recovery plan and SD backup instructions
- M.2 GPT partition plan
- Ubuntu and Kali rootfs build plan using official distro repositories
- kernel config fragments enabling HID_MULTITOUCH, HIDRAW, UHID, UINPUT, NVMe,
  overlayfs, TUN, containers, USB input, and needed display/input support
- DTB patch workflow, including optional NVMe PCIe Gen1 workaround
- boot strategy using stock/vendor U-Boot first, with GRUB/EFI as an experiment
- touch/display fallback package from `/home/orangepi/touchscreen-fix-src`
- dry-run scripts only; no destructive writes to `/dev/nvme0n1`
- validation scripts for current SD and future M.2 installs

Important findings:
- Current kernel lacks CONFIG_HID_MULTITOUCH, CONFIG_HIDRAW, CONFIG_UHID, and
  CONFIG_INPUT_UINPUT, so the QDtech MPI7003 touchscreen is handled by a local
  X11 libusb bridge until a better kernel is built.
- Vendor U-Boot is reported to be old/32-bit and legacy-image oriented; do not
  assume normal `booti` or GRUB EFI support until tested.
- Keep SD boot as recovery. Do not overwrite firmware or bootloader sectors in
  this session.

Start by inspecting local files, then browse/check upstream sources as needed,
then create the repo skeletons and planning/build scripts. Commit locally if a
git repo is initialized, but do not push unless credentials and remote ownership
are confirmed.
```
