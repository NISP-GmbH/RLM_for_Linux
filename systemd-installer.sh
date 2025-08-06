#!/bin/bash

# This script installs a systemd service.

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

SERVICE_FILE=$1

if [ -z "$SERVICE_FILE" ]; then
    echo "Usage: $0 <service-file>"
    exit 1
fi

if [ ! -f "$SERVICE_FILE" ]; then
    echo "Service file not found: $SERVICE_FILE"
    exit 1
fi

SERVICE_NAME=$(basename "$SERVICE_FILE")

echo "Installing $SERVICE_NAME..."
cp "$SERVICE_FILE" "/usr/lib/systemd/system/$SERVICE_NAME"

echo "Reloading systemd daemon..."
systemctl daemon-reload

echo "Enabling and starting $SERVICE_NAME..."
systemctl enable --now "$SERVICE_NAME"

echo "Done."
