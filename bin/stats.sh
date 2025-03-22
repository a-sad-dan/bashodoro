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

    local start_date="$1"
    local end_date="$2"

    # disable 'exit on error'
    set +e

    if [[ -n "$start_date" && -n "$end_date" ]]; then
        filter="$start_date|$end_date"
    else
        filter=".*"  # Match all lines for total stats
    fi

    #counts
    pomodoro_count=$(egrep "$filter" "$LOG_FILE" | grep -c "\[Pomodoro\] \[End\]")
    short_break_count=$(egrep "$filter" "$LOG_FILE" | grep -c "\[Short_break\] \[End\]")
    long_break_count=$(egrep "$filter" "$LOG_FILE" | grep -c "\[Long_break\] \[End\]")

    # echo "Pomodoro count: $pomodoro_count"
    # echo "Short break count: $short_break_count"
    # echo "Long break count: $long_break_count"
    # Use global variables for access in display_stats

    # total time in seconds
    pomodoros=$((pomodoro_count * WORK_DURATION))
    short_breaks=$((short_break_count * SHORT_BREAK))
    long_breaks=$((long_break_count * LONG_BREAK))

    set -e # re-enable
}

display_stats() {
    local label="$1"
    echo "----- $label Stats -----"
    echo "Total Work time: $pomodoros seconds"
    echo "Total Short breaks: $short_breaks seconds"
    echo "Long breaks: $long_breaks seconds"
    echo ""
}

# Calculate and display daily stats
today=$(date '+%Y-%m-%d')
calculate_stats "$today" "$today"
display_stats "Today's"

# Calculate and display weekly stats
if [[ "$(uname)" == "Linux" ]]; then
    week_start=$(date -d "6 days ago" '+%Y-%m-%d') # Linux-compatible
else
    week_start=$(date -v -6d '+%Y-%m-%d') # macOS-compatible
fi
calculate_stats "$week_start" "$today"
display_stats "Weekly"

# Calculate and display monthly stats
if [[ "$(uname)" == "Linux" ]]; then
    month_start=$(date -d "$(date +%Y-%m-01)" '+%Y-%m-%d') # Linux-compatible
else
    month_start=$(date -v1d '+%Y-%m-%d') # macOS-compatible
fi
calculate_stats "$month_start" "$today"
display_stats "Monthly"

# Calculate and display total stats
calculate_stats "" ""  # No date filter to count all
display_stats "Total"
