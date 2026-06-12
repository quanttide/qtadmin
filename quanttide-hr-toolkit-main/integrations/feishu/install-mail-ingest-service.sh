#!/bin/bash
# Install mail_ingest systemd service
# Run as root: sudo bash install-mail-ingest-service.sh

set -euo pipefail

SERVICE_NAME="mail-ingest"
SERVICE_SRC="./mail-ingest.service"
SERVICE_DST="/etc/systemd/system/${SERVICE_NAME}.service"

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: must run as root (sudo)"
    exit 1
fi

if [ ! -f "$SERVICE_SRC" ]; then
    echo "ERROR: $SERVICE_SRC not found in current directory"
    exit 1
fi

cp "$SERVICE_SRC" "$SERVICE_DST"
systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
systemctl restart "$SERVICE_NAME"

echo "=== Service status ==="
systemctl status "$SERVICE_NAME" --no-pager

echo ""
echo "Use: systemctl status mail-ingest    # check status"
echo "     journalctl -u mail-ingest -f    # tail logs"
echo "     systemctl stop mail-ingest      # stop"
