#!/usr/bin/env python3
"""
auto_brightness.py -- Schedule Android brightness by time of day
Sets brightness based on a time schedule without root.
Usage: python3 auto_brightness.py [--daemon]
"""
import subprocess, time, argparse
from datetime import datetime

# Schedule: (hour_start, hour_end, brightness_0_to_255, auto_mode)
SCHEDULE = [
    (6,  9,  180, False),   # Morning: bright
    (9,  18, 230, False),   # Day: full brightness
    (18, 21, 140, False),   # Evening: medium
    (21, 24, 60,  False),   # Night: dim
    (0,  6,  30,  False),   # Late night: very dim
]

def adb(cmd):
    subprocess.run(f"adb shell {cmd}", shell=True, capture_output=True)

def set_brightness(level, auto=False):
    adb(f"settings put system screen_brightness_mode {'1' if auto else '0'}")
    if not auto:
        adb(f"settings put system screen_brightness {level}")

def get_target():
    h = datetime.now().hour
    for start, end, level, auto in SCHEDULE:
        if start <= h < end:
            return level, auto
    return 128, False

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--daemon", action="store_true", help="Run continuously")
    parser.add_argument("--set", type=int, help="Set brightness manually (0-255)")
    args = parser.parse_args()

    if args.set is not None:
        set_brightness(args.set)
        print(f"✓ Brightness set to {args.set}")
        return

    if args.daemon:
        print("🌞 Auto-brightness daemon running (Ctrl+C to stop)")
        last = None
        while True:
            level, auto = get_target()
            if (level, auto) != last:
                set_brightness(level, auto)
                print(f"[{datetime.now().strftime('%H:%M')}] Brightness → {level}")
                last = (level, auto)
            time.sleep(60)
    else:
        level, auto = get_target()
        set_brightness(level, auto)
        print(f"✓ Brightness set to {level} for {datetime.now().strftime('%H:%M')}")

if __name__ == "__main__":
    main()
