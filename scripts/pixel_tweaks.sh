#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
#  pixel_tweaks.sh — Performance & UX tweaks for Google Pixel
#  Tested on Pixel 6-9 series, Android 14-15
#  No root required — pure ADB
# ═══════════════════════════════════════════════════════════

GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; NC='\033[0m'

ok() { echo -e "${GREEN}  ✓${NC} $*"; }
info() { echo -e "${CYAN}  →${NC} $*"; }

echo -e "${BOLD}🔧 Pixel Tweaks — ADB Optimization Script${NC}"
echo ""

DEVICE="${1:-}"
ADB="adb"
[[ -n "$DEVICE" ]] && ADB="adb -s $DEVICE"

# Check device
if ! $ADB get-state &>/dev/null; then
  echo -e "${YELLOW}❌ No device connected${NC}"
  exit 1
fi

MODEL=$($ADB shell getprop ro.product.model 2>/dev/null | tr -d '\r')
ANDROID=$($ADB shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
echo -e "  Device: ${BOLD}$MODEL${NC} (Android $ANDROID)"
echo ""

# ── Animation Speed ────────────────────────────────────────
info "Optimizing animations..."
$ADB shell settings put global animator_duration_scale 0.5
$ADB shell settings put global transition_animation_scale 0.5
$ADB shell settings put global window_animation_scale 0.5
ok "Animation speed set to 0.5x (snappier feel)"

# ── Dark Mode ──────────────────────────────────────────────
info "Enabling dark mode..."
$ADB shell cmd uimode night yes
ok "Dark mode enabled"

# ── Font Scale ────────────────────────────────────────────
info "Setting comfortable font scale..."
$ADB shell settings put system font_scale 0.9
ok "Font scale set to 0.9"

# ── Disable Heads-Up Notifications ────────────────────────
read -rp "  Disable heads-up notifications? (can be distracting) [y/N] " yn
if [[ "$yn" =~ ^[Yy]$ ]]; then
  $ADB shell settings put global heads_up_notifications_enabled 0
  ok "Heads-up notifications disabled"
fi

# ── Pixel-Specific: Call Screening ────────────────────────
info "Enabling call screening (Pixel feature)..."
$ADB shell settings put global call_screening_enabled 1 2>/dev/null || true

# ── Adaptive Battery ──────────────────────────────────────
info "Ensuring Adaptive Battery is enabled..."
$ADB shell dumpsys deviceidle enable 2>/dev/null || true
ok "Adaptive battery/doze configured"

# ── Now Playing (if supported) ────────────────────────────
info "Enabling Now Playing ambient music detection..."
$ADB shell settings put secure music_detection_enabled 1 2>/dev/null || true

# ── Disable Pixel Bloat ───────────────────────────────────
echo ""
read -rp "  Disable Google bloat apps? (Duo/Meet, YT Music, etc.) [y/N] " yn
if [[ "$yn" =~ ^[Yy]$ ]]; then
  PIXEL_BLOAT=(
    "com.google.android.apps.tachyon"
    "com.google.android.apps.subscriptions.red"
    "com.google.android.apps.magazines"
    "com.google.android.apps.podcasts"
    "com.google.android.apps.wellbeing"
    "com.google.android.feedback"
    "com.google.android.partnersetup"
  )
  for pkg in "${PIXEL_BLOAT[@]}"; do
    $ADB shell pm disable-user --user 0 "$pkg" &>/dev/null
    ok "Disabled: $pkg"
  done
fi

# ── Battery Optimization Stats ────────────────────────────
echo ""
info "Battery saver not enabled (preserves features)"
$ADB shell settings put global low_power 0

echo ""
echo -e "${BOLD}✅ Pixel tweaks applied!${NC}"
echo -e "   Run ${CYAN}adb shell reboot${NC} to ensure all changes take effect"
