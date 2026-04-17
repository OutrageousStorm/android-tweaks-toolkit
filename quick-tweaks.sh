#!/bin/bash
# quick-tweaks.sh -- One-liner ADB tweaks for common tasks
# Usage: ./quick-tweaks.sh [tweak-name]

TWEAKS=(
    "ad-tracking-off:settings put global limit_ad_tracking 1"
    "location-off:settings put secure location_mode 0"
    "wi-fi-scan-off:settings put global wifi_scan_always_enabled 0"
    "ambient-display-off:settings put secure doze_always_on 1"
    "battery-saver-on:settings put global low_power 1"
    "fullscreen-apps:settings put secure hide_gestures_from_edge 1"
    "extend-battery:cmd appops set --all RUN_IN_BACKGROUND deny"
    "restore-permissions:pm reset-permissions"
    "airplane-mode-on:settings put global airplane_mode_on 1"
    "developer-mode-on:settings put global development_settings_enabled 1"
)

if [[ -z "$1" ]]; then
    echo "Available tweaks:"
    for t in "${TWEAKS[@]}"; do
        name="${t%%:*}"
        echo "  ./quick-tweaks.sh $name"
    done
    exit 0
fi

for t in "${TWEAKS[@]}"; do
    name="${t%%:*}"
    cmd="${t##*:}"
    if [[ "$name" == "$1" ]]; then
        echo "Applying: $1"
        adb shell $cmd
        echo "✓ Done"
        exit 0
    fi
done

echo "Unknown tweak: $1"
