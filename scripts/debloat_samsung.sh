#!/bin/bash
# Samsung Debloat List — android-tweaks-toolkit
# Targets: Samsung One UI 4.x, 5.x, 6.x (Galaxy S/A/Note series)
# Usage: sourced by toolkit.sh with `--debloat samsung`

SAMSUNG_BLOAT=(
  # Samsung "Experience" apps (mostly useless)
  "com.samsung.android.bixby.agent"
  "com.samsung.android.bixby.wakeup"
  "com.samsung.android.bixby.service"
  "com.samsung.android.bixbyvision.framework"
  "com.samsung.android.app.assistant"
  "com.samsung.android.app.spage"          # Samsung Free / Bixby Home
  "com.samsung.android.app.routines"       # Bixby Routines
  # Samsung Ads & Analytics
  "com.samsung.android.privateshare"
  "com.samsung.android.rubin.app"
  "com.samsung.android.app.advsounddetector"
  "com.samsung.systemui.bixby2"
  # Bloatware pre-installed apps
  "com.microsoft.skydrive"                 # OneDrive
  "com.microsoft.office.excel"
  "com.microsoft.office.word"
  "com.microsoft.office.powerpoint"
  "com.linkedin.android"
  "com.facebook.katana"
  "com.facebook.appmanager"
  "com.facebook.services"
  "com.facebook.system"
  "com.netflix.partner.activation"
  "com.spotify.music"
  # Samsung Bloatware
  "com.samsung.android.game.gamehome"      # Game Launcher (if unwanted)
  "com.samsung.android.game.gametools"
  "com.samsung.android.app.updatecenter"
  "com.samsung.android.app.galaxyfinder"
  "com.samsung.android.dialer"             # SKIP if you use Samsung Phone app
  "com.sec.android.app.myfiles"            # Optional
  "com.samsung.android.weather"            # Optional
  "com.samsung.android.samsungpay"         # Optional — remove only if you don't use Samsung Pay
  "com.samsung.android.sdk.handwriting"
  "com.samsung.android.app.sharelive"
  "com.samsung.android.mobileservice"
  # Carrier-injected (T-Mobile example)
  "com.t-mobile.tuesdays"
  "com.t_mobile.mobilelife.enrollment"
  "com.wssyncmldm"                         # T-Mobile MDM
  "com.vzw.hss.myverizon"
  "com.att.myWireless"
)

echo -e "${YELLOW}[Samsung Debloat] Targeting ${#SAMSUNG_BLOAT[@]} packages...${NC}"
SUCCESS=0; FAIL=0

for pkg in "${SAMSUNG_BLOAT[@]}"; do
  # Skip comment lines
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
echo -e "${GREEN}[✓] Done. Removed: $SUCCESS | Skipped (not found): $FAIL${NC}"
echo -e "${YELLOW}[!] Reboot recommended: adb reboot${NC}"
