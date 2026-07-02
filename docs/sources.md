# Source Manifest

Verified from Orange Pi 4 Pro SD system on 2026-07-02.

## Hardware Identity

- `/proc/device-tree/model`: `sun60iw2`
- `/proc/device-tree/compatible`: `xunlong,orangepi-4-pro`, `arm,sun60iw2p1`
- Kernel: `5.15.147-sun60iw2`
- NVMe: `/dev/nvme0n1`, `Fanxiang S500Pro 256GB`, 238.5 GiB

## Official / Vendor Sources

| Source | URL | Branch / ref | Commit / result |
| --- | --- | --- | --- |
| Orange Pi 4 Pro support page | https://www.orangepi.org/html/hardWare/computerAndMicrocontrollers/service-and-support/Orange-Pi-4-Pro.html | n/a | 2026-07-02: connection refused from this host on two attempts; retry later |
| Orange Pi 4 Pro A733 user manual v1.4 PDF | https://orangepi.net/wp-content/uploads/2026/01/OrangePi_4_Pro_A733_User-Manual_v1.4.pdf | n/a | HTTP 200, `Content-Length: 14908361`, `Last-Modified: Fri, 23 Jan 2026 03:13:28 GMT`, `ETag: "6972e758-e37bc9"` |
| Vendor Linux 6.6 BSP | https://github.com/orangepi-xunlong/linux-orangepi.git | `orange-pi-6.6-sun60iw2` | `8a9be72c9006a87f786736b3aa4e2dfd971c1429` |
| Vendor Linux 5.15 BSP | https://github.com/orangepi-xunlong/linux-orangepi.git | `orange-pi-5.15-sun60iw2` | `3de7a14a69f9e1fcbfec914c972a5398f0abd6d9` |
| Vendor U-Boot BSP | https://github.com/orangepi-xunlong/u-boot-orangepi.git | `v2018.05-sun60iw2` | `b791be842935b27268ae3d00e943a9075495f30a` |
| Vendor build scripts | https://github.com/orangepi-xunlong/orangepi-build.git | `main` | `f00cd197b4a9873f36093d4f4748b733642059a7` |

## Upstream / Community Sources

| Source | URL | Branch / ref | Commit / result |
| --- | --- | --- | --- |
| Mainline U-Boot | https://source.denx.de/u-boot/u-boot.git | `master` | `f605dcee103c897b6f1a8873549a36949bd4e2a1` |
| Mainline U-Boot next | https://source.denx.de/u-boot/u-boot.git | `next` | `e800cc67f5b6cb50a20f37c993ec1cd4063bdbd3` |
| Linux stable | https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git | `linux-6.6.y` | `d1cfde2d5d15be14123bdd1689162bd27f995a90` |
| Linux mainline | https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git | `master` | `dc59e4fea9d83f03bad6bddf3fa2e52491777482` |
| Armbian build | https://github.com/armbian/build.git | `main` | `8e55c376b11a82183b7d75addc41eb6bc9febf03` |
| Orange Pi 4 Pro Armbian community work | https://github.com/jonas5/orangepi-4pro-armbian.git | `main` | `fe4c31ec0115d3f2493905be07426f36f666aab5` |
| postmarketOS device notes | https://wiki.postmarketos.org/wiki/Xunlong_Orange_Pi_4_Pro_(xunlong-orangepi4-pro) | wiki page | HTTP 200, `Last-Modified: Fri, 26 Jun 2026 17:15:58 GMT` |
| pmaports | https://gitlab.com/postmarketOS/pmaports.git | `master` | `817ed870e92a64963d926354fb74c75090811fcc` |
| NVMe Gen1 workaround | https://github.com/CarterPerez-dev/orangepi-4-pro-nvme-fix.git | `main` | `4874dcda247f69217c1ca8559d6f5f03e485f40e` |

## Next Verification

- Retry the official support page from another network.
- Download the user manual PDF and record SHA256 before relying on pinout or
  boot-media details.
- Clone the vendor 6.6 branch and inspect Orange Pi 4 Pro DTS, HDMI, PCIe/NVMe,
  Wi-Fi/Bluetooth, USB, and touch-related config.
- Confirm vendor U-Boot command support from serial console before assuming
  `booti`, EFI, extlinux, or GRUB.
