# 🔧 Android Tweaks Toolkit

> **The most complete ADB toolkit for Android** — debloat, tweak, backup, audit, and harden your device in minutes. No root required.

![Platform](https://img.shields.io/badge/platform-Android%205%2B-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![No Root](https://img.shields.io/badge/root-not%20required-brightgreen)
![ADB](https://img.shields.io/badge/powered%20by-ADB-orange)
[![Stars](https://img.shields.io/github/stars/OutrageousStorm/android-tweaks-toolkit?style=social)](https://github.com/OutrageousStorm/android-tweaks-toolkit/stargazers)

## ✨ What it does

| Feature | Command |
|---|---|
| 📱 Device info (model, RAM, chipset, build) | `--info` |
| 🗑️ Remove bloatware (Samsung / Xiaomi / OnePlus / Generic) | `--debloat samsung` |
| ⚡ Speed up animations, optimize performance | `--perf` |
| 🌙 Force dark mode on all apps | `--dark` |
| 💾 Backup all user-installed APKs | `--backup-apps` |
| 🔒 Apply privacy hardening (revoke ad permissions) | `--privacy` |
| 🔍 Audit dangerous permissions across all apps | `--audit` |
| 📡 Enable ADB over WiFi (no USB needed) | `--wifi` |

---

## 🚀 Quick Start

### 1. Prerequisites

**Install ADB:**
```bash
# macOS
brew install android-platform-tools

# Windows (PowerShell)
winget install Google.PlatformTools

# Linux (Debian/Ubuntu)
sudo apt install adb
```

**Enable USB Debugging on your phone:**
> Settings → About Phone → tap **Build Number** 7 times → Developer Options → **USB Debugging** ✓

### 2. Clone & Run

```bash
git clone https://github.com/OutrageousStorm/android-tweaks-toolkit.git
cd android-tweaks-toolkit
chmod +x toolkit.sh
./toolkit.sh --info
```

---

## 📦 Usage Examples

```bash
# See device details
./toolkit.sh --info

# Remove Samsung bloatware (Bixby, Facebook, OneDrive, etc.)
./toolkit.sh --debloat samsung

# Remove Xiaomi/MIUI bloatware (GetApps, Mi Analytics, etc.)
./toolkit.sh --debloat xiaomi

# Remove OnePlus/OxygenOS bloatware
./toolkit.sh --debloat oneplus

# Speed up the phone (reduce animations to 0.5x)
./toolkit.sh --perf

# Force dark mode system-wide
./toolkit.sh --dark

# Backup all installed apps as APKs
./toolkit.sh --backup-apps

# Restore them later
./toolkit.sh --restore-apps

# Harden privacy (revoke ad tracking permissions)
./toolkit.sh --privacy

# Full permission audit — see what each app can access
./toolkit.sh --audit

# Connect wirelessly — no USB cable after setup
./toolkit.sh --wifi
```

---

## 📱 Supported Devices

Works on **any Android device with USB Debugging enabled**:

| Brand | Tested | Notes |
|---|---|---|
| Samsung (One UI 4/5/6) | ✅ | Bixby, Facebook, Microsoft apps removed |
| Xiaomi / MIUI 13-14 | ✅ | GetApps, Mi Analytics removed |
| OnePlus / OxygenOS 13-14 | ✅ | GameService, OPPO Market removed |
| Pixel (stock Android) | ✅ | Generic list applies |
| Any Android 5+ | ✅ | Use `--debloat generic` |

---

## 🗑️ Debloat Lists

Detailed package lists are in [`scripts/`](scripts/):

- [`debloat_samsung.sh`](scripts/debloat_samsung.sh) — Bixby, Samsung Free, Facebook, Microsoft suite, carrier apps
- [`debloat_xiaomi.sh`](scripts/debloat_xiaomi.sh) — GetApps, Mi Analytics, Mi Finance, MIUI services
- [`debloat_oneplus.sh`](scripts/debloat_oneplus.sh) — OPPO Market, Game Center, OnePlus account
- [`debloat_generic.sh`](scripts/debloat_generic.sh) — Facebook, LinkedIn, Netflix, Google extras

> **All removals use `pm uninstall --user 0`** — apps are uninstalled for your user profile only. You can restore them from the Play Store at any time. Nothing is permanently deleted.

---

## 🔒 Privacy Hardening

`--privacy` applies these changes:
- Disables crash reporting and analytics upload
- Revokes `LOCATION`, `CONTACTS`, `CALL_LOG` from known ad/telemetry packages
- Disables microphone access for Google Search background listening

For a deeper audit, use `--audit` to see every dangerous permission granted on your device.

---

## 🤝 Contributing

Pull requests are welcome! To add a debloat list for a new brand:

1. Copy `scripts/debloat_generic.sh`
2. Name it `scripts/debloat_[brand].sh`
3. Add packages and submit a PR

See [CONTRIBUTING.md](CONTRIBUTING.md).

---

## 📄 License

MIT — free to use, fork, and share.

---

*Built by [Tom](https://github.com/OutrageousStorm) · Android Intelligence*
