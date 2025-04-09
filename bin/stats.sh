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

    os_type=$(uname)

    # disable 'exit on error'
    set +e
    if [[ $os_type == "Darwin" ]]; then
        if [[ -n "$start_date" && -n "$end_date" ]]; then
            start_epoch=$(date -j -f "%Y-%m-%d %H:%M:%S" "$start_date" +%s)
            end_epoch=$(date -j -f "%Y-%m-%d %H:%M:%S" "$end_date" +%s)

            filtered_lines=$(gawk -v start="$start_epoch" -v end="$end_epoch" '
            {
                regex = "\\[([0-9]{4}-[0-9]{2}-[0-9]{2}) ([0-9]{2}:[0-9]{2}:[0-9]{2})\\]"
                match($0,regex, m)
                if(m[1] != ""){
                    log_date = m[1] " " m[2]
                    cmd = "date -j -f \"%Y-%m-%d %H:%M:%S\" \"" log_date "\" +%s"
                    cmd | getline log_epoch
                    close(cmd)
                    if(log_epoch >= start && log_epoch < end) print $0
                }
            }' "$LOG_FILE")

        else
            filtered_lines=$(cat "$LOG_FILE") # Match all lines for total stats
        fi
    elif [[ $os_type == "Linux" ]]; then
        if [[ -n "$start_date" && -n "$end_date" ]]; then
            start_epoch=$(date -d "$start_date" +%s)
            end_epoch=$(date -d "$end_date" +%s)

            filtered_lines=$(awk -v start="$start_epoch" -v end="$end_epoch" '
            {
                regex = "\\[([0-9]{4}-[0-9]{2}-[0-9]{2}) ([0-9]{2}:[0-9]{2}:[0-9]{2})\\]"
                match($0,regex, m)
                if(m[1] != ""){
                    log_date = m[1] " " m[2]
                    cmd = "date -d \"" log_date "\" +%s"
                    cmd | getline log_epoch
                    close(cmd)
                    if(log_epoch >= start && log_epoch < end) print $0
                }
            }' "$LOG_FILE")

        else
            filtered_lines=$(cat "$LOG_FILE") # Match all lines for total stats
        fi
    fi

    # Calculate total times
    pomodoro_time=$(echo "$filtered_lines" | grep "\[Pomodoro\] \[Start\]" | grep -oE "\[[0-9]+\]" | tr -d '[]' | awk '{sum+=$1} END {print sum}')
    short_break_time=$(echo "$filtered_lines" | grep "\[Short_break\] \[Start\]" | grep -oE "\[[0-9]+\]" | tr -d '[]' | awk '{sum+=$1} END {print sum}')
    long_break_time=$(echo "$filtered_lines" | grep "\[Long_break\] \[Start\]" | grep -oE "\[[0-9]+\]" | tr -d '[]' | awk '{sum+=$1} END {print sum}')

    # Count interrupts
    pomodoro_interrupts_count=$(echo "$filtered_lines" | grep -c "\[Pomodoro\] \[Interrupt\]")
    short_break_interrupts_count=$(echo "$filtered_lines" | grep -c "\[Short_break\] \[Interrupt\]")
    long_break_interrupts_count=$(echo "$filtered_lines" | grep -c "\[Long_break\] \[Interrupt\]")

    # Time left during interrupts
    pomodoro_left_interrupt=$(echo "$filtered_lines" | grep "\[Pomodoro\] \[Interrupt\]" | grep -oE "\[[0-9]+\]" | tr -d '[]' | awk '{sum+=$1} END {print sum}')
    short_left_interrupt=$(echo "$filtered_lines" | grep "\[Short_break\] \[Interrupt\]" | grep -oE "\[[0-9]+\]" | tr -d '[]' | awk '{sum+=$1} END {print sum}')
    long_left_interrupt=$(echo "$filtered_lines" | grep "\[Long_break\] \[Interrupt\]" | grep -oE "\[[0-9]+\]" | tr -d '[]' | awk '{sum+=$1} END {print sum}')

    echo ""
    # total time in seconds
    pomodoros=$((pomodoro_time - pomodoro_left_interrupt))
    short_breaks=$((short_break_time - short_left_interrupt))
    long_breaks=$((long_break_time - long_left_interrupt))

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
    clear
    echo -e "===================================="
    echo -e "📊 $label Stats"
    echo -e "===================================="
    echo -e "✔ Total Work Time: $(format_time "$pomodoros")"
    echo -e "☕ Total Short Breaks: $(format_time "$short_breaks")"
    echo -e "💤 Long Breaks: $(format_time "$long_breaks")"
    echo -e "⚠ Total Interrupts during work: $pomodoro_interrupts_count"
    echo -e "⚠ Total Interrupts during short breaks: $short_break_interrupts_count"
    echo -e "⚠ Total Interrupts during long breaks: $long_break_interrupts_count"
    echo -e "===================================="
    echo -e "Press any key to continue (q to quit)"
}

# Shows the reasons for quitting the work session
display_reasons() {
    if [[ ! -f "$REASON_FILE" ]]; then
        echo "No reasons logged yet."
        return
    fi

    echo "Recent Quit Reasons:"
    echo "---------------------"
    tac "$REASON_FILE"
}

# todo add this in utils.sh file
wait_for_key() {
    read -rn1 -s key
    if [[ "$key" == "q" || "$key" == "Q" ]]; then
        exit 0
    fi
}

show_menu() {
    while true; do
        echo -e "\033[1;35mSelect the stats you want to see:\033[0m"
        echo "1) Today's Stats"
        echo "2) Weekly Stats"
        echo "3) Monthly Stats"
        echo "4) Total Stats"
        echo "5) Show your reasons for Quitting Bashodoro"
        echo "q) Exit"
        read -rp "Enter your choice: " choice

        clear

        case $choice in
        1)
            reverse_today_stats
            ;;
        2)
            reverse_weekly_stats
            ;;
        3)
            reverse_monthly_stats
            ;;
        4)
            calculate_stats "" ""
            display_stats "Total"
            wait_for_key
            ;;
        5)
            display_reasons
            wait_for_key
            ;;
        q)
            exit 0
            ;;
        *)
            echo -e "\033[1;31mInvalid choice! Please select a valid option.\033[0m"
            sleep 1
            ;;
        esac
    done
}

reverse_monthly_stats() {
    declare -a months=("January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December")

    first_line=$(head -n 1 "$LOG_FILE")
    start_year=$(echo "$first_line" | cut -d'-' -f1 | sed 's/^\[//')
    start_month=$(echo "$first_line" | cut -d'-' -f2 | sed 's/^0*//') # Remove leading zeros

    current_year=$(date '+%Y')
    current_month=$(date '+%m' | sed 's/^0*//') # Remove leading zeros

    # Store all months in an array
    declare -a all_months=()
    year=$start_year
    month=$start_month

    while [[ $year -lt $current_year || ($year -eq $current_year && $month -le $current_month) ]]; do
        all_months+=("$year-$month")
        month=$((month + 1))
        if [[ $month -eq 13 ]]; then
            month=1
            year=$((year + 1))
        fi
    done

    # Display in reverse order
    for ((i = ${#all_months[@]} - 1; i >= 0; i--)); do
        ym=${all_months[$i]}
        year=$(echo "$ym" | cut -d'-' -f1)
        month=$(echo "$ym" | cut -d'-' -f2)

        next_month=$((month + 1))
        next_year=$year
        if [[ $next_month -eq 13 ]]; then
            next_month=1
            next_year=$((year + 1))
        fi

        start_date=$(printf "%04d-%02d-01 00:00:00" "$year" "$month")
        end_date=$(printf "%04d-%02d-01 00:00:00" "$next_year" "$next_month")

        calculate_stats "$start_date" "$end_date"
        display_stats "${months[$((month - 1))]} $year"
        wait_for_key
    done
}

reverse_weekly_stats() {
    # Get the date of the first log line
    first_line=$(head -n 1 "$LOG_FILE")
    first_date=$(echo "$first_line" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')

    # Start from the beginning of the week (Monday) for first_date
    start_date=$(date -j -f "%Y-%m-%d" "$first_date" "+%Y-%m-%d" 2>/dev/null || date -d "$first_date" "+%Y-%m-%d")
    day_of_week=$(date -j -f "%Y-%m-%d" "$start_date" "+%u" 2>/dev/null || date -d "$start_date" "+%u")
    start_epoch=$(date -j -f "%Y-%m-%d" "$start_date" +%s 2>/dev/null || date -d "$start_date" +%s)
    start_epoch=$((start_epoch - (day_of_week - 1) * 86400)) # Move to Monday

    # Current time in epoch
    current_epoch=$(date +%s)

    # Store all weeks in an array
    declare -a all_weeks=()
    while [[ $start_epoch -lt $current_epoch ]]; do
        all_weeks+=("$start_epoch")
        start_epoch=$((start_epoch + 7 * 86400))
    done

    # Display in reverse order
    for ((i = ${#all_weeks[@]} - 1; i >= 0; i--)); do
        week_start=${all_weeks[$i]}
        week_end=$((week_start + 7 * 86400))

        start_str=$(date -r "$week_start" "+%Y-%m-%d 00:00:00" 2>/dev/null || date -d "@$week_start" "+%Y-%m-%d 00:00:00")
        end_str=$(date -r "$week_end" "+%Y-%m-%d 00:00:00" 2>/dev/null || date -d "@$week_end" "+%Y-%m-%d 00:00:00")

        calculate_stats "$start_str" "$end_str"
        display_stats "$(date -r "$week_start" "+%d %b" 2>/dev/null || date -d "@$week_start" "+%d %b") - $(date -r "$((week_start + 6 * 86400))" "+%d %b %Y" 2>/dev/null || date -d "@$((week_start + 6 * 86400))" "+%d %b %Y") Stats"
        wait_for_key
    done
}

reverse_today_stats() {
    # Get current date in YYYY-MM-DD format
    today=$(date "+%Y-%m-%d")

    # Start and end time for today
    start_date="$today 00:00:00"
    end_date="$today 23:59:59"

    calculate_stats "$start_date" "$end_date"
    display_stats "Today ($today)"
    wait_for_key
}

show_menu
