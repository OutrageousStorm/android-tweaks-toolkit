#!/bin/bash
# install_magisk.sh -- Download and install Magisk APK
set -e
MAGISK_URL="https://github.com/topjohnwu/Magisk/releases/download/v27.0/Magisk-v27.0.apk"
APK="Magisk.apk"
echo "Downloading Magisk..."
curl -L -o "$APK" "$MAGISK_URL"
echo "Installing Magisk..."
adb install "$APK"
echo "✅ Done. Open Magisk app on device and follow setup."
