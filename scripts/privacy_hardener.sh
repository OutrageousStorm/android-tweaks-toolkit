#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
#  privacy_hardener.sh
#  Revoke dangerous permissions and disable telemetry
#  across installed apps — no root required.
# ═══════════════════════════════════════════════════════════

BOLD='\033[1m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${BOLD}🔒 Privacy Hardener${NC}"
echo ""

ADB="adb"

# Telemetry packages to disable
TELEMETRY=(
  "com.google.android.gms.policy_sidecar_aps"
  "com.miui.analytics"
  "com.miui.msa.global"
  "com.miui.systemAdSolution"
  "com.samsung.android.rubin.app"
  "com.samsung.android.game.gametools"
  "com.facebook.appmanager"
  "com.facebook.system"
  "com.facebook.services"
)

# Dangerous permissions to revoke from common culprits
PRIVACY_GRANTS=(
  "com.facebook.katana:android.permission.ACCESS_FINE_LOCATION"
  "com.facebook.katana:android.permission.RECORD_AUDIO"
  "com.instagram.android:android.permission.ACCESS_FINE_LOCATION"
  "com.tiktok.android:android.permission.ACCESS_FINE_LOCATION"
  "com.twitter.android:android.permission.ACCESS_FINE_LOCATION"
)

echo -e "${CYAN}Disabling known telemetry packages...${NC}"
for pkg in "${TELEMETRY[@]}"; do
  installed=$($ADB shell pm list packages 2>/dev/null | grep "^package:${pkg}$")
  if [[ -n "$installed" ]]; then
    $ADB shell pm disable-user --user 0 "$pkg" &>/dev/null
    echo -e "${GREEN}  ✓ Disabled:${NC} $pkg"
  fi
done

echo ""
echo -e "${CYAN}Revoking location/audio from known data harvesters...${NC}"
for entry in "${PRIVACY_GRANTS[@]}"; do
  pkg="${entry%%:*}"
  perm="${entry##*:}"
  installed=$($ADB shell pm list packages 2>/dev/null | grep "^package:${pkg}$")
  if [[ -n "$installed" ]]; then
    $ADB shell pm revoke "$pkg" "$perm" 2>/dev/null
    echo -e "${GREEN}  ✓ Revoked${NC} $perm from $pkg"
  fi
done

echo ""
echo -e "${CYAN}Disabling background location for all apps...${NC}"
$ADB shell appops set --user 0 --uid all FINE_LOCATION ignore 2>/dev/null || true
$ADB shell settings put global background_location_throttle_interval_ms 60000 2>/dev/null || true

echo ""
echo -e "${BOLD}✅ Privacy hardening complete!${NC}"
echo ""
echo -e "  💡 For deeper auditing, run:"
echo -e "     python3 audit.py  (from android-permission-auditor)"
