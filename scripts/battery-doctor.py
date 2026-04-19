#!/usr/bin/env python3
"""
battery-doctor.py -- Diagnose battery drain and suggest fixes
Usage: python3 battery-doctor.py
"""
import subprocess, re, sys

def adb(cmd):
    r = subprocess.run(f"adb shell {cmd}", shell=True, capture_output=True, text=True)
    return r.stdout.strip()

def main():
    print("\n🔋 Battery Doctor — Drain Analysis")
    print("=" * 50)

    # Get battery stats
    battery = adb("dumpsys battery")
    print("\nCurrent Status:")
    for line in battery.splitlines():
        if any(k in line for k in ["level:", "status:", "health:", "temp"]):
            print(f"  {line.strip()}")

    # Find top apps draining battery
    print("\nTop battery consumers (last reset):")
    stats = adb("dumpsys batterystats | grep 'Uid u0a'")
    lines = [(l.split()[0], l) for l in stats.splitlines() if "mAh" in l]
    lines.sort(key=lambda x: -int(re.search(r'(\d+)mAh', x[1]).group(1) if re.search(r'(\d+)mAh', x[1]) else 0))
    for _, line in lines[:5]:
        print(f"  {line.strip()}")

    # Check wakelocks
    print("\nWakelocks (processes keeping CPU alive):")
    wl = adb("dumpsys power | grep 'Kernel uid wakelock'")
    for line in wl.splitlines()[:5]:
        print(f"  {line.strip()}")

    # Suggest fixes
    print("\n💡 Recommendations:")
    print("  • Disable location when not needed")
    print("  • Turn off WiFi/Bluetooth scanning in Settings")
    print("  • Set screen timeout to 2 minutes")
    print("  • Limit background app activity: adb shell dumpsys deviceidle step deep")
    print("  • Check Play Services — often #1 drain. Install 'Universal GMS Doze' Magisk module")
    print("  • Remove unused apps with location permission")

if __name__ == "__main__":
    main()
