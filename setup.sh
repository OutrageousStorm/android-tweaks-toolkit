#!/bin/bash
# setup.sh -- One-command Android hardening and tweaking
# Sets up the toolkit, configures ADB, and applies baseline privacy settings
set -e

echo "🔧 Android Tweaks Toolkit Setup"
echo "================================"

# Check ADB
if ! command -v adb &> /dev/null; then
    echo "❌ ADB not found. Install Android SDK Platform Tools first."
    echo "   macOS: brew install android-platform-tools"
    echo "   Linux: sudo apt install adb"
    exit 1
fi

# Check device
if ! adb devices | grep -q "device$"; then
    echo "❌ No Android device connected. Enable USB Debugging and try again."
    exit 1
fi

DEVICE=$(adb get-serialno)
MODEL=$(adb shell getprop ro.product.model)
echo "✓ Connected: $MODEL ($DEVICE)"

# Install Python dependencies
echo "✓ Installing Python dependencies..."
pip install rich -q || pip3 install rich -q

# Make scripts executable
chmod +x scripts/*.py scripts/*.sh *.py *.sh 2>/dev/null || true

# Run baseline privacy check
echo ""
echo "📊 Checking current privacy status..."
python3 android-privacy-hardener/check.py 2>/dev/null || echo "  (Privacy checker unavailable)"

echo ""
read -rp "Apply Level 2 privacy hardening? (y/N): " APPLY
if [[ "$APPLY" == "y" ]]; then
    python3 android-privacy-hardener/harden.py --level 2
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Available tools:"
ls -1 scripts/*.py 2>/dev/null | xargs -I {} basename {} | sed 's/^/   - /'
echo ""
echo "Get started:"
echo "   python3 android-toolkit-scripts/device_info.py"
echo "   python3 android-toolkit-scripts/permission_audit.py"
echo "   python3 android-toolkit-scripts/network_monitor.py"
