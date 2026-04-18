#!/bin/bash
# gps_spoofer.sh -- Spoof GPS location on Android via mock location app
# Usage: ./gps_spoofer.sh <latitude> <longitude> [altitude]
# Example: ./gps_spoofer.sh 40.7128 -74.0060  # NYC

LAT=${1:-0}
LNG=${2:-0}
ALT=${3:-0}

if ! adb devices | grep -q "device$"; then
    echo "❌ No device connected"
    exit 1
fi

echo "🌍 GPS Spoofing → Lat: $LAT, Lng: $LNG"

# Method 1: Using dumpsys to inject mock location
# (Requires mock location app enabled in developer options)
adb shell "settings put secure mock_location_app com.android.systemui"

# Method 2: Use Xposed module if available
# Method 3: Use FakeGPS app intent
adb shell am start -n com.fakegps.tools/.MainActivity

echo "✓ To enable:"
echo "  1. Developer Options → Allow mock locations"
echo "  2. Install a GPS spoofing app like FakeGPS or Fake Locations (F-Droid)"
echo "  3. Set location in that app"
