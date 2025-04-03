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
    interrupts_count=$(egrep "$filter" "$LOG_FILE" | grep -c "\[Pomodoro\] \[Interrupt\]")

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

format_time() {
    local total_seconds="$1"
    local hours=$((total_seconds / 3600))
    local minutes=$(((total_seconds % 3600) / 60))
    local seconds=$((total_seconds % 60))
    printf "%02dh %02dm %02ds" "$hours" "$minutes" "$seconds"
}
display_stats() {
    local label="$1"
    echo -e "===================================="
    echo -e "📊 $label Stats"
    echo -e "===================================="
    echo -e "✔ Total Work Time: $(format_time "$pomodoros")"
    echo -e "☕ Total Short Breaks: $(format_time "$short_breaks")"
    echo -e "💤 Long Breaks: $(format_time "$long_breaks")"
    echo -e "⚠ Total Interrupts: $interrupts_count"
    echo -e "====================================\n"
}

show_menu() {
    while true; do
        echo -e "\033[1;35mSelect the stats you want to see:\033[0m"
        echo "1) Today's Stats"
        echo "2) Weekly Stats"
        echo "3) Monthly Stats"
        echo "4) Total Stats"
        echo "5) Exit"
        read -rp "Enter your choice: " choice

        clear

        case $choice in
            1)
                today=$(date '+%Y-%m-%d')
                calculate_stats "$today" "$today"
                display_stats "Today's"
                ;;
            2)
                if [[ "$(uname)" == "Linux" ]]; then
                    week_start=$(date -d "6 days ago" '+%Y-%m-%d')
                else
                    week_start=$(date -v -6d '+%Y-%m-%d')
                fi
                calculate_stats "$week_start" "$today"
                display_stats "Weekly"
                ;;
            3)
                if [[ "$(uname)" == "Linux" ]]; then
                    month_start=$(date -d "$(date +%Y-%m-01)" '+%Y-%m-%d')
                else
                    month_start=$(date -v1d '+%Y-%m-%d')
                fi
                calculate_stats "$month_start" "$today"
                display_stats "Monthly"
                ;;
            4)
                calculate_stats "" ""
                display_stats "Total"
                ;;
            5)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo -e "\033[1;31mInvalid choice! Please select a valid option.\033[0m"
                ;;
        esac
        read -n 1 -sp "enter any key to continue to main menu"
        echo ""
        clear
    done
}

show_menu