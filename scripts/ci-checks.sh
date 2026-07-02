#!/usr/bin/env bash
set -euo pipefail

printf 'Checking shell syntax...\n'
while IFS= read -r -d '' script; do
  bash -n "$script"
done < <(find scripts -type f -name '*.sh' -print0)

if command -v shellcheck >/dev/null 2>&1; then
  printf 'Running shellcheck...\n'
  shellcheck scripts/*.sh
else
  printf 'shellcheck not installed; skipping optional shell lint\n'
fi

printf 'Scanning for obvious secret patterns...\n'
if grep -RInE '(BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY|ghp_[A-Za-z0-9_]+|github_pat_[A-Za-z0-9_]+|AKIA[0-9A-Z]{16}|password[[:space:]]*=|token[[:space:]]*=|secret[[:space:]]*=)' \
  --exclude-dir=.git .; then
  printf 'ERROR: possible secret pattern found\n' >&2
  exit 1
fi

printf 'Checking for committed binary artifacts...\n'
if find . -type f -not -path './.git/*' -exec file {} + | grep -E 'ELF|PE32 executable|Mach-O|ISO 9660|filesystem data'; then
  printf 'ERROR: binary artifact found\n' >&2
  exit 1
fi

printf 'CI checks passed.\n'

