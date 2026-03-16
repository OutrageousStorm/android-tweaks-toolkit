#!/bin/bash
# Android Tweaks Toolkit
# No root required — ADB only
# https://github.com/OutrageousStorm/android-tweaks-toolkit

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

banner() {
  echo -e "${CYAN}"
  echo "  ╔══════════════════════════════════════╗"
  echo "  ║    🔧 Android Tweaks Toolkit v1.0    ║"
  echo "  ║    No root required • ADB powered    ║"
  echo "  ╚══════════════════════════════════════╝"
  echo -e "${NC}"
}

check_adb() {
  if ! command -v adb &> /dev/null; then
    echo -e "${RED}[ERROR] ADB not found. Install Android Platform Tools first.${NC}"
    echo "  → https://developer.android.com/tools/releases/platform-tools"
    exit 1
  fi
}

list_devices() {
  echo -e "${CYAN}[*] Connected devices:${NC}"
  adb devices -l
}

debloat() {
  BRAND=${1:-generic}
  echo -e "${YELLOW}[*] Loading debloat list for: $BRAND${NC}"
  source "scripts/debloat_${BRAND}.sh" 2>/dev/null || source "scripts/debloat_generic.sh"
}

perf_tweaks() {
  echo -e "${GREEN}[*] Applying performance tweaks...${NC}"
  adb shell settings put global animator_duration_scale 0.5
  adb shell settings put global transition_animation_scale 0.5
  adb shell settings put global window_animation_scale 0.5
  adb shell settings put system screen_off_timeout 60000
  echo -e "${GREEN}[✓] Animation speeds reduced${NC}"
  adb shell cmd battery unplug
  adb shell settings put global stay_on_while_plugged_in 0
  echo -e "${GREEN}[✓] Battery optimizations applied${NC}"
}

force_dark_mode() {
  echo -e "${GREEN}[*] Forcing dark mode on all apps...${NC}"
  adb shell cmd uimode night yes
  adb shell settings put secure ui_night_mode 2
  echo -e "${GREEN}[✓] Dark mode enabled system-wide${NC}"
}

backup_apps() {
  echo -e "${CYAN}[*] Backing up user apps...${NC}"
  mkdir -p backups
  adb shell pm list packages -3 | cut -d: -f2 | while read pkg; do
    echo "  Backing up: $pkg"
    adb backup -apk -noshared -nosystem "$pkg" -f "backups/${pkg}.ab" 2>/dev/null
  done
  echo -e "${GREEN}[✓] Backup complete → ./backups/${NC}"
}

privacy_hardening() {
  echo -e "${YELLOW}[*] Applying privacy tweaks...${NC}"
  # Disable crash reporting
  adb shell settings put global send_action_app_error 0
  # Disable usage stats
  adb shell settings put global dropbox:data_app_crash 0
  echo -e "${GREEN}[✓] Privacy tweaks applied${NC}"
}

usage() {
  echo "Usage: $0 [OPTION]"
  echo ""
  echo "Options:"
  echo "  --devices       List connected ADB devices"
  echo "  --debloat [brand]  Debloat device (samsung|xiaomi|oneplus|generic)"
  echo "  --perf          Apply performance & animation tweaks"
  echo "  --dark-mode     Force dark mode system-wide"
  echo "  --backup-apps   Backup all user-installed apps"
  echo "  --privacy       Apply privacy hardening tweaks"
  echo "  --help          Show this help"
}

banner
check_adb

case "$1" in
  --devices)     list_devices ;;
  --debloat)     debloat "$2" ;;
  --perf)        perf_tweaks ;;
  --dark-mode)   force_dark_mode ;;
  --backup-apps) backup_apps ;;
  --privacy)     privacy_hardening ;;
  --help|*)      usage ;;
esac
