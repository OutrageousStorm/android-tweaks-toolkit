#!/usr/bin/env python3
"""
screen_off_monitor.py -- Run ADB commands whenever screen turns off/on
Usage: python3 screen_off_monitor.py
Customize the on_screen_off() and on_screen_on() functions below.
"""
import subprocess, time, sys

def adb(cmd):
    return subprocess.run(f"adb shell {cmd}", shell=True, capture_output=True, text=True).stdout.strip()

def get_screen_state():
    out = adb("dumpsys power | grep 'mHoldingDisplaySuspendBlocker'")
    return "true" in out.lower()

def on_screen_off():
    """Called when screen turns off"""
    print("[Screen OFF]")
    # Example: enable aggressive doze
    adb("dumpsys deviceidle step deep")
    adb("dumpsys deviceidle step deep")
    # Example: disable WiFi scanning
    adb("settings put global wifi_scan_always_enabled 0")

def on_screen_on():
    """Called when screen turns on"""
    print("[Screen ON]")
    # Example: restore WiFi scanning
    adb("settings put global wifi_scan_always_enabled 1")

def main():
    print("👁️  Screen state monitor — press Ctrl+C to stop")
    last_state = get_screen_state()
    print(f"Initial state: {'ON' if last_state else 'OFF'}")
    try:
        while True:
            state = get_screen_state()
            if state != last_state:
                if state:
                    on_screen_on()
                else:
                    on_screen_off()
                last_state = state
            time.sleep(2)
    except KeyboardInterrupt:
        print("\nStopped.")

if __name__ == "__main__":
    main()
