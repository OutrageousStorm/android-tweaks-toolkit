#!/usr/bin/env python3
"""
app_launcher.py -- Launch, kill, and manage Android apps via ADB
Interactive app manager — search, launch, force-stop, clear data.
Usage: python3 app_launcher.py
"""
import subprocess, sys, re

def adb(cmd):
    r = subprocess.run(f"adb shell {cmd}", shell=True, capture_output=True, text=True)
    return r.stdout.strip()

def get_packages():
    out = adb("pm list packages -3")
    return sorted([l.split(":")[1] for l in out.splitlines() if l.startswith("package:")])

def get_app_label(pkg):
    out = adb(f"pm dump {pkg} | grep 'versionName'")
    ver = re.search(r'versionName=(\S+)', out)
    return f"{pkg} ({ver.group(1)})" if ver else pkg

def launch(pkg):
    out = adb(f"monkey -p {pkg} -c android.intent.category.LAUNCHER 1")
    return "Events injected" in out

def force_stop(pkg):
    adb(f"am force-stop {pkg}")

def clear_data(pkg):
    r = adb(f"pm clear {pkg}")
    return "Success" in r

def main():
    print("\n📱 App Launcher & Manager")
    print("=" * 40)
    pkgs = get_packages()
    print(f"Found {len(pkgs)} user apps\n")

    while True:
        query = input("Search app (or q to quit): ").strip()
        if query == 'q':
            break

        matches = [p for p in pkgs if query.lower() in p.lower()]
        if not matches:
            print("  No matches.\n")
            continue

        for i, p in enumerate(matches[:10]):
            print(f"  {i+1}. {p}")

        choice = input("Pick number (or Enter to cancel): ").strip()
        if not choice.isdigit():
            continue
        idx = int(choice) - 1
        if idx < 0 or idx >= len(matches):
            continue

        pkg = matches[idx]
        print(f"\nSelected: {pkg}")
        print("  l = launch  |  s = stop  |  c = clear data  |  Enter = cancel")
        action = input("Action: ").strip().lower()

        if action == 'l':
            ok = launch(pkg)
            print(f"  {'✓ Launched' if ok else '✗ Launch failed'}")
        elif action == 's':
            force_stop(pkg)
            print("  ✓ Force stopped")
        elif action == 'c':
            confirm = input(f"  Clear all data for {pkg}? (y/N): ").strip().lower()
            if confirm == 'y':
                ok = clear_data(pkg)
                print(f"  {'✓ Cleared' if ok else '✗ Failed'}")
        print()

if __name__ == "__main__":
    main()
