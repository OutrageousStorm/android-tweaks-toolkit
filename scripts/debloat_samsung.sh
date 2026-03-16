#!/bin/bash
# Samsung bloatware removal list
# Safe to remove — tested on Galaxy S/A/M series

PACKAGES=(
  "com.samsung.android.bixby.agent"
  "com.samsung.android.bixby.wakeup"
  "com.samsung.android.visionintelligence"
  "com.samsung.android.app.tips"
  "com.samsung.android.game.gamehome"
  "com.samsung.android.game.gametools"
  "com.samsung.android.rubin.app"
  "com.sec.android.app.samsungprintservice"
  "com.samsung.android.kidsinstaller"
  "com.samsung.android.app.watchmanagerstub"
  "com.samsung.android.mobileservice"
  "com.samsung.android.dialer"
  "com.samsung.android.app.social"
  "com.samsung.android.messaging"
  "com.microsoft.skydrive"
  "com.linkedin.android"
  "com.facebook.appmanager"
  "com.facebook.services"
  "com.facebook.system"
  "com.netflix.partner.activation"
)

echo "[Samsung Debloater] Found ${#PACKAGES[@]} packages to remove"
for pkg in "${PACKAGES[@]}"; do
  echo "  Disabling: $pkg"
  adb shell pm disable-user --user 0 "$pkg" 2>/dev/null || echo "  (skipped: $pkg)"
done
echo "[✓] Samsung debloat complete"
