#!/usr/bin/env bash
# ╔═══════════════════════════════════════════╗
# ║   🔧 Android Tweaks Toolkit v2.0         ║
# ║   No root required · ADB powered         ║
# ║   github.com/OutrageousStorm/            ║
# ║   android-tweaks-toolkit                 ║
# ╚═══════════════════════════════════════════╝
# MIT License — Use freely, modify openly

set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

VERSION="2.0"
AUTHOR="Tom | Android Intelligence"

# ── Helpers ────────────────────────────────────────────────────────────────

banner() {
  echo -e "${CYAN}"
  echo "  ╔══════════════════════════════════════════╗"
  echo "  ║   🔧 Android Tweaks Toolkit v${VERSION}        ║"
  echo "  ║   No root required · ADB powered         ║"
  echo "  ║   by ${AUTHOR}    ║"
  echo "  ╚══════════════════════════════════════════╝"
  echo -e "${NC}"
}

check_adb() {
  if ! command -v adb &>/dev/null; then
    echo -e "${RED}[ERROR] ADB not found.${NC}"
    echo "  macOS:   brew install android-platform-tools"
    echo "  Windows: winget install Google.PlatformTools"
    echo "  Linux:   sudo apt install adb"
    exit 1
  fi
  DEVICE=$(adb get-state 2>/dev/null || echo "none")
  if [[ "$DEVICE" != "device" ]]; then
    echo -e "${RED}[ERROR] No device connected or USB debugging not enabled.${NC}"
    echo "  → Enable: Settings → Developer Options → USB Debugging"
    exit 1
  fi
  DEVICE_MODEL=$(adb shell getprop ro.product.model 2>/dev/null | tr -d '\r')
  ANDROID_VER=$(adb shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
  echo -e "${GREEN}[✓] Connected: ${BOLD}${DEVICE_MODEL}${NC}${GREEN} (Android ${ANDROID_VER})${NC}"
}

confirm() {
  echo -e "${YELLOW}[?] $1 Continue? (y/N)${NC}"
  read -r ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

# ── Feature: Debloat ───────────────────────────────────────────────────────

debloat() {
  BRAND="${1:-generic}"
  SCRIPT="scripts/debloat_${BRAND}.sh"
  if [[ ! -f "$SCRIPT" ]]; then
    echo -e "${RED}[ERROR] No debloat list for: $BRAND${NC}"
    echo "  Available: samsung, xiaomi, oneplus, generic"
    exit 1
  fi
  echo -e "${CYAN}[*] Brand: ${BOLD}${BRAND}${NC}"
  echo -e "${YELLOW}[!] This will remove apps for user 0 (your profile). They can be reinstalled via Play Store.${NC}"
  confirm "Starting debloat for $BRAND." || exit 0
  source "$SCRIPT"
}

# ── Feature: Performance Tweaks ───────────────────────────────────────────

perf_tweaks() {
  echo -e "${CYAN}[*] Applying performance tweaks...${NC}"

  echo -e "  ${YELLOW}→ Reducing animation scales to 0.5x${NC}"
  adb shell settings put global animator_duration_scale 0.5
  adb shell settings put global transition_animation_scale 0.5
  adb shell settings put global window_animation_scale 0.5

  echo -e "  ${YELLOW}→ Disabling 'Adaptive Battery' aggressive doze for background apps${NC}"
  adb shell dumpsys deviceidle disable 2>/dev/null || true

  echo -e "  ${YELLOW}→ Setting GPU rendering to hardware${NC}"
  adb shell setprop debug.hwui.renderer skiagl 2>/dev/null || true

  echo -e "  ${YELLOW}→ Increasing touch responsiveness${NC}"
  adb shell settings put system pointer_speed 3 2>/dev/null || true

  echo -e "${GREEN}[✓] Performance tweaks applied.${NC}"
  echo -e "${YELLOW}    To revert animations: ./toolkit.sh --perf-reset${NC}"
}

perf_reset() {
  echo -e "${CYAN}[*] Resetting animations to default (1x)...${NC}"
  adb shell settings put global animator_duration_scale 1
  adb shell settings put global transition_animation_scale 1
  adb shell settings put global window_animation_scale 1
  echo -e "${GREEN}[✓] Animations reset.${NC}"
}

# ── Feature: Dark Mode ────────────────────────────────────────────────────

force_dark_mode() {
  echo -e "${CYAN}[*] Forcing dark mode on all apps...${NC}"
  adb shell cmd uimode night yes
  adb shell settings put secure ui_night_mode 2
  echo -e "${GREEN}[✓] Dark mode enabled system-wide.${NC}"
}

disable_dark_mode() {
  adb shell cmd uimode night no
  adb shell settings put secure ui_night_mode 1
  echo -e "${GREEN}[✓] Dark mode disabled.${NC}"
}

# ── Feature: App Backup & Restore ─────────────────────────────────────────

backup_apps() {
  echo -e "${CYAN}[*] Backing up all user-installed apps...${NC}"
  mkdir -p backups/apks backups/data
  
  PKGS=$(adb shell pm list packages -3 | cut -d: -f2 | tr -d '\r')
  COUNT=$(echo "$PKGS" | wc -l)
  echo -e "  Found ${BOLD}$COUNT${NC} user apps"
  
  N=0
  while IFS= read -r pkg; do
    [[ -z "$pkg" ]] && continue
    APK_PATH=$(adb shell pm path "$pkg" 2>/dev/null | head -1 | cut -d: -f2 | tr -d '\r ')
    if [[ -n "$APK_PATH" ]]; then
      adb pull "$APK_PATH" "backups/apks/${pkg}.apk" 2>/dev/null && ((N++)) || true
    fi
  done <<< "$PKGS"
  
  echo -e "${GREEN}[✓] Backed up $N APKs → ./backups/apks/${NC}"
}

restore_apps() {
  echo -e "${CYAN}[*] Restoring apps from ./backups/apks/...${NC}"
  SUCCESS=0; FAIL=0
  for apk in backups/apks/*.apk; do
    [[ -f "$apk" ]] || continue
    RESULT=$(adb install -r "$apk" 2>&1)
    if [[ "$RESULT" == *"Success"* ]]; then
      echo -e "  ${GREEN}✓${NC} $(basename "$apk")"
      ((SUCCESS++))
    else
      echo -e "  ${RED}✗${NC} $(basename "$apk"): $(echo "$RESULT" | tail -1)"
      ((FAIL++))
    fi
  done
  echo -e "${GREEN}[✓] Restored: $SUCCESS | Failed: $FAIL${NC}"
}

# ── Feature: Privacy ──────────────────────────────────────────────────────

privacy_hardening() {
  echo -e "${CYAN}[*] Applying privacy hardening...${NC}"

  echo -e "  ${YELLOW}→ Disabling crash/analytics reporting${NC}"
  adb shell settings put global send_action_app_error 0
  adb shell settings put global dropbox:data_app_crash 0
  adb shell settings put global dropbox:data_app_anr 0

  echo -e "  ${YELLOW}→ Disabling personalization services${NC}"
  adb shell settings put secure package_verifier_user_consent -1 2>/dev/null || true

  echo -e "  ${YELLOW}→ Revoking dangerous permissions from known ad packages${NC}"
  for pkg in com.facebook.katana com.facebook.services com.miui.analytics com.samsung.android.rubin.app; do
    adb shell pm revoke "$pkg" android.permission.READ_CONTACTS 2>/dev/null || true
    adb shell pm revoke "$pkg" android.permission.ACCESS_FINE_LOCATION 2>/dev/null || true
    adb shell pm revoke "$pkg" android.permission.READ_CALL_LOG 2>/dev/null || true
  done

  echo -e "  ${YELLOW}→ Disabling microphone for sensor blocker${NC}"
  adb shell appops set com.google.android.googlequicksearchbox RECORD_AUDIO deny 2>/dev/null || true

  echo -e "${GREEN}[✓] Privacy hardening applied.${NC}"
  echo -e "${YELLOW}    For full privacy audit: ./toolkit.sh --audit${NC}"
}

# ── Feature: Permission Audit ─────────────────────────────────────────────

permission_audit() {
  echo -e "${CYAN}[*] Auditing dangerous permissions...${NC}"
  echo ""
  DANGEROUS="ACCESS_FINE_LOCATION|ACCESS_COARSE_LOCATION|READ_CONTACTS|READ_CALL_LOG|RECORD_AUDIO|CAMERA|READ_SMS|PROCESS_OUTGOING_CALLS|READ_PHONE_STATE"
  
  adb shell pm list packages -3 | cut -d: -f2 | tr -d '\r' | while read -r pkg; do
    [[ -z "$pkg" ]] && continue
    PERMS=$(adb shell dumpsys package "$pkg" 2>/dev/null | grep "permission" | grep -E "($DANGEROUS)" | grep "granted=true" | grep -oE "[A-Z_]+" | sort -u | tr '\n' ',' | sed 's/,$//')
    if [[ -n "$PERMS" ]]; then
      echo -e "  ${YELLOW}${pkg}${NC}"
      echo -e "    → ${RED}$PERMS${NC}"
    fi
  done
  echo ""
  echo -e "${GREEN}[✓] Audit complete. Review flagged apps above.${NC}"
}

# ── Feature: ADB Over WiFi ────────────────────────────────────────────────

wireless_adb() {
  PORT=5555
  echo -e "${CYAN}[*] Setting up ADB over WiFi (Android 11+)...${NC}"
  ANDROID_VER=$(adb shell getprop ro.build.version.release | tr -d '\r')
  
  adb tcpip $PORT
  sleep 1
  IP=$(adb shell ip route | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | tail -1)
  
  echo -e "${GREEN}[✓] ADB listening on TCP. Disconnect USB and run:${NC}"
  echo -e "  ${BOLD}adb connect ${IP}:${PORT}${NC}"
}

# ── Feature: Device Info ──────────────────────────────────────────────────

device_info() {
  echo -e "${CYAN}[*] Device Information${NC}"
  echo ""
  printf "  %-25s %s\n" "Model:"       "$(adb shell getprop ro.product.model | tr -d '\r')"
  printf "  %-25s %s\n" "Manufacturer:" "$(adb shell getprop ro.product.manufacturer | tr -d '\r')"
  printf "  %-25s %s\n" "Android:"     "$(adb shell getprop ro.build.version.release | tr -d '\r')"
  printf "  %-25s %s\n" "Build:"       "$(adb shell getprop ro.build.display.id | tr -d '\r')"
  printf "  %-25s %s\n" "Codename:"    "$(adb shell getprop ro.product.device | tr -d '\r')"
  printf "  %-25s %s\n" "Chipset:"     "$(adb shell getprop ro.hardware | tr -d '\r')"
  printf "  %-25s %s\n" "RAM:"         "$(adb shell cat /proc/meminfo | grep MemTotal | awk '{printf "%.1f GB", $2/1024/1024}' | tr -d '\r')"
  printf "  %-25s %s\n" "Bootloader:"  "$(adb shell getprop ro.bootloader | tr -d '\r')"
  printf "  %-25s %s\n" "Carrier:"     "$(adb shell getprop gsm.operator.alpha | tr -d '\r')"
  printf "  %-25s %s\n" "Serial:"      "$(adb get-serialno)"
  echo ""
}

# ── Usage ─────────────────────────────────────────────────────────────────

usage() {
  echo -e "${BOLD}Usage:${NC} $0 [OPTION] [args]"
  echo ""
  echo -e "${CYAN}Device:${NC}"
  echo "  --info              Show device info (model, Android version, RAM, etc.)"
  echo "  --devices           List connected ADB devices"
  echo "  --wifi              Enable ADB over WiFi"
  echo ""
  echo -e "${CYAN}Debloat:${NC}"
  echo "  --debloat [brand]   Remove bloatware (samsung|xiaomi|oneplus|generic)"
  echo ""
  echo -e "${CYAN}Performance:${NC}"
  echo "  --perf              Apply performance & animation tweaks"
  echo "  --perf-reset        Reset animations to default"
  echo ""
  echo -e "${CYAN}Appearance:${NC}"
  echo "  --dark              Force dark mode system-wide"
  echo "  --light             Disable dark mode"
  echo ""
  echo -e "${CYAN}Backup:${NC}"
  echo "  --backup-apps       Backup all user APKs to ./backups/"
  echo "  --restore-apps      Restore APKs from ./backups/"
  echo ""
  echo -e "${CYAN}Privacy:${NC}"
  echo "  --privacy           Apply privacy hardening tweaks"
  echo "  --audit             Audit dangerous permissions across all apps"
  echo ""
  echo -e "${CYAN}Examples:${NC}"
  echo "  ./toolkit.sh --info"
  echo "  ./toolkit.sh --debloat samsung"
  echo "  ./toolkit.sh --perf"
  echo "  ./toolkit.sh --audit"
}

# ── Main ──────────────────────────────────────────────────────────────────

banner

if [[ $# -eq 0 ]]; then usage; exit 0; fi

case "$1" in
  --info)         check_adb; device_info ;;
  --devices)      adb devices -l ;;
  --wifi)         check_adb; wireless_adb ;;
  --debloat)      check_adb; debloat "${2:-generic}" ;;
  --perf)         check_adb; perf_tweaks ;;
  --perf-reset)   check_adb; perf_reset ;;
  --dark)         check_adb; force_dark_mode ;;
  --light)        check_adb; disable_dark_mode ;;
  --backup-apps)  check_adb; backup_apps ;;
  --restore-apps) check_adb; restore_apps ;;
  --privacy)      check_adb; privacy_hardening ;;
  --audit)        check_adb; permission_audit ;;
  --help|-h|*)    usage ;;
esac
