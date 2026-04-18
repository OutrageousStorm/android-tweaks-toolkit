#!/usr/bin/env python3
"""
battery_test.py -- Run Android battery drain test
Enables everything (WiFi, BT, location, bright screen) and measures drain over N minutes.
Usage: python3 battery_test.py --duration 10
"""
import subprocess, time, argparse, re
from datetime import datetime

def adb(cmd):
    return subprocess.run(f"adb shell {cmd}", shell=True, capture_output=True, text=True).stdout.strip()

def get_battery_level():
    out = adb("dumpsys battery | grep level")
    m = re.search(r'level:\s*(\d+)', out)
    return int(m.group(1)) if m else 0

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--duration", type=int, default=10, help="Test duration in minutes")
    args = parser.parse_args()

    print(f"\n🔋 Battery Drain Test — {args.duration} minutes")
    print("=" * 50)

    # Enable all power consumers
    print("Enabling: WiFi, Bluetooth, Location, 100% brightness, screen always-on")
    adb("svc wifi enable")
    adb("svc bluetooth enable")
    adb("settings put secure location_mode 3")
    adb("settings put system screen_brightness 255")
    adb("settings put system screen_brightness_mode 0")
    adb("settings put system screen_off_timeout 2147483647")

    # Measure
    start_level = get_battery_level()
    start_time = time.time()
    print(f"Starting battery: {start_level}%")
    print("Running... (press Ctrl+C to stop early)\n")

    samples = []
    try:
        for i in range(args.duration):
            time.sleep(60)
            level = get_battery_level()
            elapsed = i + 1
            drain = start_level - level
            per_min = drain / elapsed if elapsed > 0 else 0
            samples.append(level)
            print(f"  {elapsed:2d}min: {level}% (drained {drain}% | {per_min:.2f}%/min)")
    except KeyboardInterrupt:
        print("\nStopped early.")

    # Results
    end_level = get_battery_level()
    total_drain = start_level - end_level
    elapsed_min = (time.time() - start_time) / 60
    avg_drain = total_drain / elapsed_min if elapsed_min > 0 else 0

    print(f"\n{'='*50}")
    print(f"Results:")
    print(f"  Start: {start_level}% → End: {end_level}%")
    print(f"  Total drain: {total_drain}% in {elapsed_min:.1f} minutes")
    print(f"  Average: {avg_drain:.2f}%/min")
    print(f"  Estimated runtime: {int(end_level / avg_drain) if avg_drain > 0 else 'N/A'} minutes")

if __name__ == "__main__":
    main()
