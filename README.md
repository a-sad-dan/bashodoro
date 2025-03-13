# Bashodoro

A Bash-based implementation of the Pomodoro Technique, providing an efficient and configurable time management system within the terminal environment.

## Overview

The **Pomodoro Technique**, pioneered by Francesco Cirillo in the late 1980s, is a structured time management methodology designed to enhance productivity by segmenting work into **25-minute focused intervals** (Pomodoros), interspersed with **5-minute short breaks**. After the completion of four consecutive Pomodoros, a **longer break of 15–30 minutes** is introduced to facilitate cognitive recovery.

**Bashodoro** automates this methodology through:

- Programmatically timed work and break intervals.
- Adaptive notification mechanisms to mitigate distractions.
- Comprehensive session tracking with statistical insights.
- Flexible configuration parameters to accommodate diverse workflows.
- A streamlined command-line interface optimized for minimal resource utilization.

## Features

### ⏳ Configurable Time Intervals
- Define custom work, short break, and long break durations.
- Default settings: **Work = 25 min, Short Break = 5 min, Long Break = 15 min**.

### 📊 Advanced Session Tracking
- Logs completed work intervals.
- Automatically schedules long breaks after every four Pomodoros.

### 🔔 Multi-Platform Notifications
- Desktop notifications utilizing:
  - `notify-send` (Linux)
  - `osascript` (macOS)
  - `-Command` (Windows PowerShell)
- Acoustic alerts leveraging:
  - `afplay` (macOS)
  - `paplay` (Linux)
  - `aplay` (Linux)

### 📟 Real-Time Progress Monitoring
- Terminal-integrated countdown timer and progress bar.

### ⏸️ Pause, Resume, and Session Skipping
- **Pause/Resume:** Press **p** to pause, **r** to resume.
- **Skip:** Press **s** to advance to the next session.
- **Quit:** Press **q** to terminate the script.

### 📈 Productivity Analytics
- Comprehensive session logging and performance analysis.
- Automatically generated productivity reports (daily/weekly).
- **Key Metrics Tracked:**
  - Aggregate Pomodoro count
  - Total work duration (hours and minutes)
  - Time allocation for short and long breaks
  - Productivity streak analysis
  - Average session length
  - Frequency of skipped and paused sessions
  - Trends in daily and weekly productivity

### ⚙️ Customization via Configuration File
- **`settings.conf`** allows fine-tuning of:
  - Notification preferences
  - Sound settings
  - Break intervals
  - Long break frequency
  - Work session durations

### 🌙 Optimized Terminal UI
- Lightweight, distraction-free interface.

### 🆘 Integrated Help Menu
- Use `-h` or `--help` for contextual usage instructions.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/a-sad-dan/bashodoro.git
   cd bashodoro
   ```
2. Grant execution permissions:
   ```bash
   chmod +x bashodoro.sh
   ```
3. Execute the script:
   ```bash
   ./bashodoro.sh
   ```

## Usage

Execute the script with optional parameters:

```bash
./bashodoro.sh [OPTIONS]
```

### Command-Line Options

- **Manual Mode:** `-m, --manual` Start without automatic session initiation.
- **Statistics Display:** `-s, --stats` Show detailed session statistics.
- **Configuration Overview:** `-c, --config` Display current parameter settings.
- **Help Menu:** `-h, --help` Display command usage and options.
- **Exit Command:** `Ctrl+C` (Linux/macOS) or `Cmd+C` (Windows) to quit.

## System Dependencies

- `notify-send` (Linux), `osascript` (macOS), `-Command` (Windows PowerShell) for desktop notifications.
- `afplay` (macOS), `paplay` (Linux), `aplay` (Linux) for acoustic alerts.
- `sleep` or `date` for interval timing execution.

## Project Structure

```
.
|-- README.md
|-- audio
|-- bashodoro.sh
|-- bin
|   |-- notify.sh
|   |-- session.sh
|   `-- timer.sh
|-- config
|   `-- settings.conf
|-- logo.png
|-- logo_dark.png
|-- logs
|   `-- bashodoro.log
|-- sounds
|   |-- jokingly.ogg
|   |-- jokingly.wav
|   |-- joyous.ogg
|   |-- joyous.wav
|   |-- light-hearted.ogg
|   |-- light-hearted.wav
|   |-- slick.ogg
|   `-- slick.wav
|-- tests
|   |-- test_notify.sh
|   `-- test_timer.sh
`-- uninstall.sh
```

## Contributing

Contributions are encouraged and appreciated. To contribute:

1. **Fork** the repository.
2. **Create a feature branch** for your implementation.
3. **Develop and test** modifications locally.
4. **Submit a pull request** with a concise summary of changes.

For significant modifications, please initiate an issue discussion beforehand.

---
**Bashodoro** is a robust, extensible, and lightweight productivity tool designed for efficiency-focused terminal users. Stay productive and optimize your workflow!

