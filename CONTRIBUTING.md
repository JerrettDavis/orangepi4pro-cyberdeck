# Contributing

This repository is the project-level coordination point for the Orange Pi 4 Pro
cyberdeck. Keep hardware-specific implementation in the sibling repos unless a
document genuinely belongs at the integration/runbook level.

## Rules

- Keep SD, NVMe, bootloader, and firmware operations explicit in docs.
- Do not commit private captures, secrets, binary images, rootfs tarballs, or
  downloaded vendor source trees.
- Record source URLs, branches, commits, and verification dates when adding
  external references.
- Run `scripts/ci-checks.sh` before pushing.

