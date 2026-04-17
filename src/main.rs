use std::process::Command;
use serde_json::json;

fn adb(cmd: &str) -> String {
    let output = Command::new("adb")
        .args(&["shell", cmd])
        .output()
        .expect("Failed to run adb");
    String::from_utf8_lossy(&output.stdout).to_string()
}

fn main() {
    println!("
🚀 Android Performance Analyzer
");

    // CPU
    println!("CPU Info:");
    let cpuinfo = adb("cat /proc/cpuinfo | grep processor | wc -l");
    let cores = cpuinfo.trim();
    println!("  Cores: {}", cores);

    let freq = adb("cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq");
    if !freq.is_empty() {
        let mhz = freq.trim().parse::<u64>().unwrap_or(0) / 1000;
        println!("  Current Freq: {} MHz", mhz);
    }

    // Memory
    println!("
Memory:");
    let meminfo = adb("free -h | grep Mem");
    for line in meminfo.lines() {
        if !line.is_empty() {
            println!("  {}", line);
        }
    }

    // Top processes by CPU
    println!("
Top CPU consumers:");
    let top = adb("top -n 1 -o %CPU | head -10");
    for (i, line) in top.lines().take(5).enumerate() {
        if i > 0 {
            println!("  {}", line);
        }
    }

    // Battery
    println!("
Battery:");
    let level = adb("dumpsys battery | grep level");
    let temp = adb("dumpsys battery | grep temperature");
    println!("  {}", level.trim());
    println!("  {}", temp.trim());

    println!("
✅ Analysis complete
");
}
