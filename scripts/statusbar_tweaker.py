#!/usr/bin/env python3
"""
statusbar_tweaker.py -- Hide/show system status bar icons via ADB
Controls visibility of: clock, signal, battery, wifi, bluetooth, etc.
Usage: python3 statusbar_tweaker.py --hide-all
       python3 statusbar_tweaker.py --show-wifi --show-battery
"""
import subprocess

def adb(cmd):
    subprocess.run(f"adb shell {cmd}", shell=True, capture_output=True)

def toggle_icon(icon, visible):
    state = "1" if visible else "0"
    cmds = {
        "clock": f"settings put secure status_bar_show_clock {state}",
        "battery": f"settings put secure status_bar_battery {state}",
        "wifi": f"settings put secure wifi_icon_visible {state}",
        "signal": f"settings put secure signal_icon_visible {state}",
        "bluetooth": f"settings put secure bluetooth_icon_visible {state}",
        "location": f"settings put secure location_icon_visible {state}",
        "nfc": f"settings put secure nfc_icon_visible {state}",
    }
    if icon in cmds:
        adb(cmds[icon])

import argparse
parser = argparse.ArgumentParser()
parser.add_argument('--hide-all', action='store_true')
parser.add_argument('--show-clock', action='store_true')
parser.add_argument('--show-battery', action='store_true')
parser.add_argument('--show-wifi', action='store_true')
args = parser.parse_args()

if args.hide_all:
    for icon in ["clock", "battery", "wifi", "signal"]:
        toggle_icon(icon, False)
    print("✓ Hidden clock, battery, WiFi, signal")
else:
    if args.show_clock: toggle_icon("clock", True); print("✓ Showing clock")
    if args.show_battery: toggle_icon("battery", True); print("✓ Showing battery")
    if args.show_wifi: toggle_icon("wifi", True); print("✓ Showing WiFi")
