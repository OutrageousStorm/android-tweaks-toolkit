#!/usr/bin/env node
/**
 * dashboard.js - Android ADB TUI Dashboard
 * Real-time monitoring: battery, CPU, memory, temperature
 * Usage: npm install && node dashboard.js
 */
import blessed from 'blessed';
import { execSync } from 'child_process';
import chalk from 'chalk';

const screen = blessed.screen({
  mouse: true,
  title: 'Android ADB Dashboard',
});

const mainBox = blessed.box({
  parent: screen,
  top: 0,
  left: 0,
  width: '100%',
  height: '100%',
  content: '',
  style: { bg: 'black', fg: 'white' },
});

const logBox = blessed.box({
  parent: screen,
  top: 15,
  left: 0,
  width: '100%',
  height: '100%-15',
  scrollable: true,
  mouse: true,
  keys: true,
  style: { bg: 'black', fg: 'green' },
});

function adb(cmd) {
  try {
    return execSync(`adb shell ${cmd}`, { encoding: 'utf-8' }).trim();
  } catch(e) {
    return 'ERROR';
  }
}

function formatBytes(b) {
  if (b < 1024) return b + 'B';
  if (b < 1024*1024) return (b/1024).toFixed(1) + 'KB';
  return (b/1024/1024).toFixed(1) + 'MB';
}

function update() {
  try {
    const battery = adb("dumpsys battery | grep level | head -1").match(/\d+/)[0];
    const temp = adb("dumpsys battery | grep temperature | head -1").match(/\d+/)[0];
    const ram = adb("cat /proc/meminfo | grep MemAvailable").match(/\d+/)[0];
    const cpu = adb("top -n 1 | head -3 | tail -1");
    const model = adb("getprop ro.product.model");

    let header = `\n🤖 Android Dashboard - ${model}\n`;
    header += `${'═'.repeat(50)}\n`;
    header += `Battery: ${battery}%  |  Temp: ${temp}°C  |  RAM: ${formatBytes(ram*1024)}\n`;
    header += `CPU: ${cpu.substring(0, 60)}\n`;
    header += `${'─'.repeat(50)}\n`;

    mainBox.setContent(header);
    logBox.log(chalk.green(`[${new Date().toLocaleTimeString()}] Updated`));

    setTimeout(update, 3000);
  } catch(e) {
    logBox.log(chalk.red(`Error: ${e.message}`));
    setTimeout(update, 5000);
  }
}

screen.key(['escape', 'q', 'C-c'], () => process.exit(0));
logBox.log(chalk.cyan('ADB Dashboard started. Press Q to quit.\n'));

update();
screen.render();
