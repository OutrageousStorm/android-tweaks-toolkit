# 🔧 Android Tweaks Toolkit

> A powerful ADB-based toolkit for Android customization, debloating, theming & performance tweaks — **no root required**.

![Platform](https://img.shields.io/badge/platform-Android-green)
![License](https://img.shields.io/badge/license-MIT-blue)
![No Root](https://img.shields.io/badge/root-not%20required-brightgreen)

## ✨ Features

- 🚫 **Debloater** — Remove bloatware from any Android device via ADB
- 🎨 **Theme Engine** — Apply custom icon packs, fonts, and UI tweaks
- ⚡ **Performance Tweaks** — Battery optimization, animation speed, CPU governor hints
- 📱 **App Manager** — Batch install/uninstall APKs, backup/restore apps
- 🔒 **Privacy Tools** — Disable telemetry, revoke hidden permissions
- 🌙 **Always-On Mods** — Force dark mode, system-wide font override

## 🚀 Quick Start

### Prerequisites
- [ADB (Android Debug Bridge)](https://developer.android.com/tools/adb) installed on your PC
- USB Debugging enabled on your Android device

### Installation

```bash
git clone https://github.com/OutrageousStorm/android-tweaks-toolkit.git
cd android-tweaks-toolkit
chmod +x toolkit.sh
./toolkit.sh
```

### Windows
```
toolkit.bat
```

## 📦 Usage

```bash
# List connected devices
./toolkit.sh --devices

# Debloat Samsung bloatware
./toolkit.sh --debloat samsung

# Apply performance tweaks
./toolkit.sh --perf

# Force dark mode on all apps
./toolkit.sh --dark-mode

# Backup all user apps
./toolkit.sh --backup-apps
```

## 📱 Supported Devices

| Manufacturer | Models | Notes |
|---|---|---|
| Samsung | Galaxy S/A/M series | Full support |
| Xiaomi / MIUI | All MIUI 12+ | Full support |
| OnePlus | OxygenOS 11+ | Full support |
| Pixel | Android 10+ | Full support |
| Generic AOSP | Any Android 8+ | Partial support |

## 🛠️ Tools Included

| Tool | Description |
|---|---|
| `debloat.sh` | Remove OEM/carrier bloatware |
| `perf_tweaks.sh` | Performance & battery optimization |
| `theme.sh` | UI customization (fonts, icons, overlays) |
| `privacy.sh` | Privacy hardening |
| `backup.sh` | App & data backup via ADB |

## ⚠️ Disclaimer

Use at your own risk. Always back up your device before making system changes. This tool uses ADB commands — it cannot brick your device, but incorrect usage may cause apps to behave unexpectedly.

## 🤝 Contributing

PRs welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

> 🤖 This project is maintained by an AI agent ([Tom](https://base44.com)) on behalf of [@OutrageousStorm](https://github.com/OutrageousStorm)
