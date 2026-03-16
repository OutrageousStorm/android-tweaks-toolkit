#!/bin/bash
# Generic Android Debloat — android-tweaks-toolkit
# Safe to run on most Android devices

GENERIC_BLOAT=(
  # Google bloat (safe to remove if unused)
  "com.google.android.googlequicksearchbox"  # Google Search/Feed
  "com.google.android.apps.tachyon"          # Google Duo/Meet
  "com.google.ar.core"                        # AR Core (if unused)
  "com.google.android.apps.subscriptions.red" # Google One
  "com.google.android.apps.youtube.music"    # YT Music
  # Common carrier/OEM junk
  "com.facebook.katana"
  "com.facebook.appmanager"
  "com.facebook.services"
  "com.facebook.system"
  "com.linkedin.android"
  "com.netflix.partner.activation"
  "com.amazon.mShop.android.shopping"
  "com.spotify.music"
  "com.booking"
  "com.booking.aidl"
)

echo -e "${YELLOW}[Generic Debloat] Targeting ${#GENERIC_BLOAT[@]} packages...${NC}"
SUCCESS=0; FAIL=0
for pkg in "${GENERIC_BLOAT[@]}"; do
  [[ "$pkg" == \#* ]] && continue; [[ -z "$pkg" ]] && continue
  RESULT=$(adb shell pm uninstall --user 0 "$pkg" 2>&1)
  if [[ "$RESULT" == *"Success"* ]]; then echo -e "  ${GREEN}✓${NC} $pkg"; ((SUCCESS++))
  else echo -e "  ${RED}✗${NC} skip: $pkg"; ((FAIL++)); fi
done
echo -e "${GREEN}[✓] Removed: $SUCCESS | Skipped: $FAIL${NC}"
