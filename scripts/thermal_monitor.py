#!/usr/bin/env python3
"""
thermal_monitor.py -- Real-time device temperature monitor
Shows CPU, battery, and skin temps. Alerts if overheating.
Usage: python3 thermal_monitor.py [--alert 45]
"""
import subprocess, time, argparse
from datetime import datetime

def adb(cmd):
    r = subprocess.run(f"adb shell {cmd}", shell=True, capture_output=True, text=True)
    return r.stdout.strip()

def get_temp(zone_name):
    try:
        out = adb(f"cat /sys/class/thermal/thermal_zone*/type | grep {zone_name}")
        if out:
            zone = out.split("\n")[0].replace("type", "temp")
            temp = int(adb(f"cat {zone}")) // 1000
            return temp
    except:
        pass
    return None

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--alert", type=int, default=50, help="Alert temp in C")
    args = parser.parse_args()

    print("\n🌡️  Device Thermal Monitor — press Ctrl+C to stop\n")
    print(f"{'Time':<10} {'CPU':<8} {'Battery':<10} {'Skin':<8} {'Status'}")
    print("─" * 50)

    try:
        while True:
            cpu = get_temp("cpu")
            bat = get_temp("battery")
            skin = get_temp("skin")

            ts = datetime.now().strftime("%H:%M:%S")
            cpu_s = f"{cpu}°C" if cpu else "N/A"
            bat_s = f"{bat}°C" if bat else "N/A"
            skin_s = f"{skin}°C" if skin else "N/A"

            status = "✅"
            if (cpu and cpu > args.alert) or (bat and bat > args.alert):
                status = "⚠️  HOT"

            print(f"{ts:<10} {cpu_s:<8} {bat_s:<10} {skin_s:<8} {status}")
            time.sleep(2)
    except KeyboardInterrupt:
        print("\nStopped.")

if __name__ == "__main__":
    main()
