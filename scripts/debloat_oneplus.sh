#!/bin/bash
# OnePlus / OxygenOS Debloat List — android-tweaks-toolkit
# Targets: OxygenOS 13/14 (Android 13/14 base)

ONEPLUS_BLOAT=(
  "com.oneplus.brickmode"
  "com.oneplus.gameservice"                # Optional
  "com.nearme.gamecenter"
  "com.oplus.games"
  "com.heliplus.oplus"
  "com.oppo.market"                        # OPPO App Market
  "net.oneplus.odm"
  "com.oneplus.euactivationservice"
  "com.oneplus.account"
  # Social
  "com.facebook.katana"
  "com.facebook.services"
  "com.facebook.appmanager"
  "com.netflix.partner.activation"
  "com.spotify.music"
  # Diagnostics
  "com.oneplus.bugreport"
)

echo -e "${YELLOW}[OnePlus Debloat] Targeting ${#ONEPLUS_BLOAT[@]} packages...${NC}"
SUCCESS=0; FAIL=0
for pkg in "${ONEPLUS_BLOAT[@]}"; do
  [[ "$pkg" == \#* ]] && continue; [[ -z "$pkg" ]] && continue
  RESULT=$(adb shell pm uninstall --user 0 "$pkg" 2>&1)
  if [[ "$RESULT" == *"Success"* ]]; then echo -e "  ${GREEN}✓${NC} $pkg"; ((SUCCESS++))
  else echo -e "  ${RED}✗${NC} skip: $pkg"; ((FAIL++)); fi
done
echo -e "${GREEN}[✓] Removed: $SUCCESS | Skipped: $FAIL${NC}"
