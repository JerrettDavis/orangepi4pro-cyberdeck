# M.2 Install Plan

Status: planning only. The third session may turn these notes into an install
after recovery media and source captures are complete.

Target disk:

- Device: `/dev/nvme0n1`
- Model: `Fanxiang S500Pro 256GB`
- Current observed size: 238.5 GiB

Proposed GPT layout:

| Partition | Size | FS | Label | Purpose |
| --- | ---: | --- | --- | --- |
| p1 | 512 MiB | FAT32 | `OPI_EFI` | EFI/GRUB experiments |
| p2 | 2 GiB | ext4 | `OPI_BOOT` | Shared kernels, initrds, DTBs, boot scripts |
| p3 | 50 GiB | ext4 | `UBUNTU_ROOT` | Ubuntu root |
| p4 | 45 GiB | ext4 | `KALI_ROOT` | Kali root |
| p5 | 24 GiB | ext4 | `TOOLS` | Shared tools/cache |
| p6 | 32 GiB | ext4 | `HOME` | Shared data/home |
| p7 | 32 GiB | ext4 | `RESCUE_OR_ARCH` | Future rescue or Arch |
| p8 | rest | ext4 or btrfs | `IMAGES_CACHE` | Build/image cache |

First boot target:

```text
Boot ROM -> stock/vendor U-Boot from SD -> boot script/menu -> kernel/initrd/DTB
from shared boot partition -> Ubuntu or Kali rootfs on M.2
```

GRUB/EFI is an experiment until vendor U-Boot command support is proven.

