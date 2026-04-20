#!/usr/bin/env python3
"""
battery_monitor.py -- Real-time Android battery monitoring
Shows: level, temperature, voltage, current, status, health
Usage: python3 battery_monitor.py [--alert-temp 45] [--alert-level 15]
"""
import subprocess, time, sys, argparse
from datetime import datetime

def adb(cmd):
    r = subprocess.run(f"adb shell {cmd}", shell=True, capture_output=True, text=True)
    return r.stdout.strip()

def parse_battery():
    raw = adb("dumpsys battery")
    battery = {}
    for line in raw.splitlines():
        parts = line.strip().split(": ")
        if len(parts) == 2:
            k, v = parts
            battery[k.strip()] = v.strip()
    return battery

def celsius(mv):
    """Convert millivolts to celsius if it's a temp reading"""
    try:
        val = int(mv)
        if val > 100:  # likely mV, not celsius
            return val / 10
        return val
    except:
        return 0

def format_battery(b):
    """Pretty print battery dict"""
    return {
        "Level": f"{b.get('level', '?')}%",
        "Temp": f"{celsius(b.get('temperature', 0))}°C",
        "Voltage": f"{b.get('voltage', '?')}mV",
        "Current": f"{b.get('current', '?')}mA",
        "Status": b.get('status', '?'),
        "Health": b.get('health', '?'),
        "Plugged": b.get('plugged', 'no'),
    }

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--alert-temp", type=float, default=45, help="Alert if temp exceeds this (°C)")
    parser.add_argument("--alert-level", type=int, default=15, help="Alert if level drops below this (%)")
    parser.add_argument("--interval", type=float, default=2, help="Update interval (seconds)")
    args = parser.parse_args()

    print("\n🔋 Battery Monitor — press Ctrl+C to stop\n")
    try:
        while True:
            b = parse_battery()
            fmt = format_battery(b)
            
            ts = datetime.now().strftime("%H:%M:%S")
            temp = celsius(b.get('temperature', 0))
            level = int(b.get('level', 0))
            
            alerts = []
            if temp > args.alert_temp:
                alerts.append(f"🔥 HIGH TEMP: {temp}°C")
            if level < args.alert_level:
                alerts.append(f"⚠️  LOW BATTERY: {level}%")
            
            print(f"[{ts}]", end="")
            print(f"  Level: {fmt['Level']:<6}  Temp: {fmt['Temp']:<8}  Status: {fmt['Status']:<15}  Voltage: {fmt['Voltage']}", end="")
            if alerts:
                print(" " + " | ".join(alerts), end="")
            print()
            
            time.sleep(args.interval)
    except KeyboardInterrupt:
        print("\nStopped.")

if __name__ == "__main__":
    main()
