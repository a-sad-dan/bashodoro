#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/config/settings.conf"

# Per-user logs
LOG_DIR="$HOME/.bashodoro/logs"
LOG_FILE="$LOG_DIR/bashodoro.log"

if [[ ! -f $LOG_FILE ]]; then
    echo "Log file not found!"
    exit 1
fi

calculate_stats() {
    today=$(date '+%Y-%m-%d')
    set +e
    pomodoro_count=$(grep "$today" "$LOG_FILE" | grep -c "\[Pomodoro\] \[End\]")
    short_break_count=$(grep "$today" "$LOG_FILE" | grep -c "\[Short_break\] \[End\]")
    long_break_count=$(grep "$today" "$LOG_FILE" | grep -c "\[Long_break\] \[End\]")

    # echo "Pomodoro count: $pomodoro_count"
    # echo "Short break count: $short_break_count"
    # echo "Long break count: $long_break_count"
    # Use global variables for access in display_stats
    today_pomodoros=$((pomodoro_count * WORK_DURATION))
    today_short_breaks=$((short_break_count * SHORT_BREAK))
    today_long_breaks=$((long_break_count * LONG_BREAK))
}

display_stats() {
    echo "Date: $today"
    echo "Today's Report"
    echo "Total pomodoros: $today_pomodoros seconds"
    echo "Total Short breaks: $today_short_breaks seconds"
    echo "Long breaks: $today_long_breaks seconds"
}

calculate_stats
display_stats
