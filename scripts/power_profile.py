#!/usr/bin/env python3
"""power_profile.py -- Switch CPU power profile"""
import subprocess, argparse

PROFILES = {
    "performance": ("performance", "0", "100"),
    "balanced": ("schedutil", "85", "10"),
    "powersave": ("powersave", "100", "2"),
}

def adb(cmd):
    subprocess.run(f"adb shell {cmd}", shell=True, capture_output=True)

def set_profile(mode):
    if mode not in PROFILES:
        print(f"Unknown: {mode}")
        return
    gov, headroom, rate = PROFILES[mode]
    adb(f"echo {gov} > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor")
    print(f"CPU profile: {mode}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", default="balanced", choices=PROFILES.keys())
    set_profile(parser.parse_args().mode)
