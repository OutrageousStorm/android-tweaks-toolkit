#!/bin/bash
# Xiaomi / MIUI / HyperOS Debloat List — android-tweaks-toolkit
# Targets: MIUI 13/14, HyperOS 1.x (Redmi, POCO, Mi series)

XIAOMI_BLOAT=(
  # GetApps & Ads
  "com.miui.analytics"
  "com.miui.msa.global"
  "com.miui.global.providence"
  "com.xiaomi.mipicks"                     # GetApps
  "com.miui.daemon"
  # Xiaomi Browser & Search (replaceable)
  "com.mi.globalbrowser"
  # Xiaomi Finance & Shopping
  "com.mipay.wallet.in"
  "com.mipay.wallet.id"
  "com.xiaomi.payment"
  "com.miui.hybrid"
  "com.miui.hybrid.accessory"
  # Social bloatware
  "com.facebook.katana"
  "com.facebook.appmanager"
  "com.facebook.services"
  "com.facebook.system"
  "com.linkedin.android"
  # Xiaomi services you probably don't need
  "com.miui.bugreport"
  "com.miui.cloudbackup"                   # Optional: remove if not using MIUI Cloud
  "com.miui.cloudservice"
  "com.miui.cloudservice.sysbase"
  "com.miui.backup"                        # Optional
  "com.miui.yellowpage"                    # MIUI Yellow Pages (caller ID)
  "com.xiaomi.joyose"                      # Game Turbo analytics
  "com.xiaomi.glgm"
  "com.miui.videoplayer"                   # Optional — if you use another player
  "com.miui.player"                        # Optional — Music player
  # Ads specifically
  "com.google.android.marvin.talkback"     # Only if you don't need accessibility
)

echo -e "${YELLOW}[Xiaomi Debloat] Targeting ${#XIAOMI_BLOAT[@]} packages...${NC}"
SUCCESS=0; FAIL=0

for pkg in "${XIAOMI_BLOAT[@]}"; do
  [[ "$pkg" == \#* ]] && continue
  [[ -z "$pkg" ]] && continue
  RESULT=$(adb shell pm uninstall --user 0 "$pkg" 2>&1)
  if [[ "$RESULT" == *"Success"* ]]; then
    echo -e "  ${GREEN}✓${NC} Removed: $pkg"
    ((SUCCESS++))
  else
    echo -e "  ${RED}✗${NC} Not found (skip): $pkg"
    ((FAIL++))
  fi
done

echo ""
echo -e "${GREEN}[✓] Done. Removed: $SUCCESS | Skipped: $FAIL${NC}"
