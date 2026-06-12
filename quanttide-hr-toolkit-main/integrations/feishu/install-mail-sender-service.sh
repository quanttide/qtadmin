#!/bin/bash
# Install mail_sender systemd service
# Run as root: sudo bash install-mail-sender-service.sh

set -euo pipefail

SERVICE_NAME="mail-sender"
SERVICE_SRC="./mail_sender.service"
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
echo "Use: systemctl status mail-sender    # check status"
echo "     journalctl -u mail-sender -f    # tail logs"
echo "     systemctl stop mail-sender      # stop"
