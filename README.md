# Bashodoro

A Bash script for implementing the Pomodoro Technique in the terminal.

## Overview

The **Pomodoro Technique** is a time management method developed by Francesco Cirillo in the late 1980s. It involves breaking work into intervals, traditionally **25 minutes of focused work** (a "Pomodoro") followed by a **5-minute break**. After completing **four Pomodoros**, a longer break (15–30 minutes) is taken.

**Bashodoro** automates this technique by:
- Timing work and break intervals automatically.
- Sending notifications to handle distractions.
- Tracking progress and logging completed sessions.
- Allowing customization of intervals to match individual workflows.

## Key Features

1. **Customizable Intervals**
   - Set work, short break, and long break durations.
   - Defaults: **Work = 25 min, Short Break = 5 min, Long Break = 15 min**.

2. **Session Tracking**
   - Track completed work sessions.
   - Automatically start a long break after every 4 work sessions.

3. **Notifications**
   - Alerts when sessions start and end using `notify-send` (Linux) or sound effects.

4. **Progress Display**
   - Show a countdown timer or progress bar in the terminal.

5. **Pause & Resume**
   - Press **p** to pause and **r** to resume a session.

6. **Skip Session**
   - Press **s** to skip the current session.

7. **Statistics & Logging**
   - Log session data for productivity analysis.

8. **Help Menu**
   - Press **h** to display usage instructions.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/a-sad-dan/bashodoro.git
   cd bashodoro
   ```
2. Make the script executable:
   ```bash
   chmod +x bashodoro.sh
   ```
3. Run the script:
   ```bash
   ./bashodoro.sh
   ```

## Usage

Run the script with optional arguments to customize session durations:
   ```bash
   ./bashodoro.sh --work 30 --short-break 10 --long-break 20
   ```

### Available Commands

- **Pause/Resume**: Press **p** to pause, **r** to resume.
- **Skip Session**: Press **s** to skip.
- **Help Menu**: Press **h** for instructions.

## Technical Details

### Tools & Libraries Used
- `notify-send` for desktop notifications (Linux).
- `paplay` or `mpg123` for sound alerts.
- `sleep` or `date` for timer functionality.
- `printf` or `tput` for terminal-based progress display.

### Script Structure

#### Variables
- Define session durations, session counts, and notification settings.

#### Functions
- **start_session**: Starts a work or break session.
- **notify_user**: Sends notifications.
- **display_timer**: Shows a countdown timer.
- **pause_session**: Pauses the current session.
- **skip_session**: Skips the current session.
- **log_statistics**: Logs session data to a file.

#### Main Loop
- Alternates between work and break sessions using a `while` loop.

## Deliverables

- **Bash Script**: A fully functional `bashodoro.sh` script.
- **Documentation**: A well-structured `README.md` with installation, usage, and features.
- **Testing**:
  - Test cases for different systems.
  - Use `shellcheck` for script validation.
- **Optional Enhancements**:
  - GUI integration using `zenity` or `dialog`.
  - Remote control via SSH.
  - Web-based dashboard for tracking progress.

