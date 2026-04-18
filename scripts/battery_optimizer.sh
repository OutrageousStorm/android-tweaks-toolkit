#!/bin/bash
# battery_optimizer.sh -- One-command battery optimization
# Usage: ./battery_optimizer.sh [aggressive]

set -e
MODE="${1:-balanced}"

adb shell settings put global low_power_sticky 1
adb shell settings put global wifi_scan_always_enabled 0
adb shell settings put global ble_scan_always_enabled 0

if [[ "$MODE" == "aggressive" ]]; then
    adb shell dumpsys deviceidle enable deep
    adb shell dumpsys deviceidle step deep
    adb shell settings put global screen_off_timeout 60000
    adb shell settings put global wifi_on 0
fi

echo "✓ Battery optimized ($MODE mode)"
