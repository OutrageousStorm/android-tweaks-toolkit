#!/usr/bin/env python3
"""
battery_saver.py -- Adaptive battery saver tied to battery percentage
When battery drops below threshold, enable aggressive power saving.
Usage: python3 battery_saver.py [--threshold 20] [--daemon]
"""
import subprocess, time, argparse

def adb(cmd):
    subprocess.run(f"adb shell {cmd}", shell=True, capture_output=True)

def get_battery_level():
    r = subprocess.run("adb shell dumpsys battery | grep level", 
                      shell=True, capture_output=True, text=True)
    try:
        return int(r.stdout.split(":")[-1].strip())
    except:
        return -1

def enable_power_saving():
    print("[🔋] Enabling power saver mode...")
    adb("settings put global low_power 1")
    adb("settings put global low_power_trigger_level 1")
    # Disable background sync
    adb("settings put global background_restrict_by_system 1")
    # Aggressive doze
    adb("dumpsys deviceidle step deep")
    adb("dumpsys deviceidle step deep")
    # Dim screen
    adb("settings put system screen_brightness 80")

def disable_power_saving():
    print("[🔋] Disabling power saver (battery OK)...")
    adb("settings put global low_power 0")
    adb("settings put system screen_brightness 200")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--threshold", type=int, default=20, help="Battery % to enable saver")
    parser.add_argument("--daemon", action="store_true", help="Run continuously")
    args = parser.parse_args()

    print(f"🔋 Battery Saver — threshold {args.threshold}%")
    saver_active = False

    if not args.daemon:
        level = get_battery_level()
        print(f"Current: {level}%")
        if level > 0 and level <= args.threshold:
            enable_power_saving()
        else:
            print("Battery OK")
        return

    print("Running in daemon mode (Ctrl+C to stop)")
    while True:
        level = get_battery_level()
        if level > 0:
            if level <= args.threshold and not saver_active:
                enable_power_saving()
                saver_active = True
            elif level > args.threshold + 5 and saver_active:
                disable_power_saving()
                saver_active = False
        time.sleep(30)

if __name__ == "__main__":
    main()
