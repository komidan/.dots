#!/usr/bin/env bash

set -euo pipefail

AGE_DAYS=1
echo "[$0] /tmp/ usage:"
df -h /tmp
echo

if ! mountpoint -q /tmp && ! [[ -d /tmp ]]; then
    echo "[$0] error: /tmp does not appear valid"
    exit 1
fi

read -rp "[$0] delete items ${AGE_DAYS} day(s) old? [y/N] " confirm

case "$confirm" in
    [yY]|[yY][eE][sS]) ;;
    *)
        echo "[$0] cancelled"
        exit 0 ;;
esac

echo "[$0] removing files..."
sudo find /tmp \
    -xdev \
    -mindepth 1 \
    -type f \
    -mtime +"$AGE_DAYS" \
    -delete

echo "[$0] removing dirs..."
sudo find /tmp \
    -xdev \
    -mindepth 1 \
    -type d \
    -mtime +"$AGE_DAYS" \
    -exec rm -rf {} + 2>/dev/null

echo "[$0] system cleanup"
command -v systemd-tmpfiles >/dev/null && \
    sudo systemd-tmpfiles --clean

echo "[$0] after-clean usage:"
df -h /tmp

echo "[$0] done."
