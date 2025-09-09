#!/usr/bin/env bash
set -e

SERVICE_FILE=remap-per-app.service
TARGET_DIR="$HOME/.config/systemd/user"

echo "Installing systemd user service..."

mkdir -p "$TARGET_DIR"
cp ../systemd/$SERVICE_FILE "$TARGET_DIR/"

echo "Reloading user systemd daemon..."
systemctl --user daemon-reload

echo "Enabling and starting service..."
systemctl --user enable --now remap-per-app.service

echo "Done! The service is now active."

