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

    #counts
    pomodoro_time=$(echo "$filtered_lines" | grep "\[Pomodoro\] \[Start\]" | egrep -o "\[[0-9]+\]" | egrep -o "[0-9]+" | awk '{sum+=$1} END {print sum}')
    short_break_time=$(echo "$filtered_lines" | grep "\[Short_break\] \[Start\]" | egrep -o "\[[0-9]+\]" | egrep -o "[0-9]+" | awk '{sum+=$1} END {print sum}')
    long_break_time=$(echo "$filtered_lines" | grep "\[Long_break\] \[Start\]" | egrep -o "\[[0-9]+\]" | egrep -o "[0-9]+" | awk '{sum+=$1} END {print sum}')
    pomodoro_interrupts_count=$(echo "$filtered_lines" | grep -c "\[Pomodoro\] \[Interrupt\]")
    short_break_interrupts_count=$(echo "$filtered_lines" | grep -c "\[Short_break\] \[Interrupt\]")
    long_break_interrupts_count=$(echo "$filtered_lines" | grep -c "\[Long_break\] \[Interrupt\]")
    pomodoro_left_interrupt=$(echo "$filtered_lines" | grep "\[Pomodoro\] \[Interrupt\]" | egrep -o "\[[0-9]+\]" | egrep -o "[0-9]+" | awk '{sum+=$1} END {print sum}')
    short_left_interrupt=$(echo "$filtered_lines" | grep "\[Short_break\] \[Interrupt\]" | egrep -o "\[[0-9]+\]" | egrep -o "[0-9]+" | awk '{sum+=$1} END {print sum}')
    long_left_interrupt=$(echo "$filtered_lines" | grep "\[Long_break\] \[Interrupt\]" | egrep -o "\[[0-9]+\]" | egrep -o "[0-9]+" | awk '{sum+=$1} END {print sum}')

    # echo "Pomodoro count: $pomodoro_count"
    # echo "Short break count: $short_break_count"
    # echo "Long break count: $long_break_count"
    # Use global variables for access in display_stats
    # echo -e "\n debug \n"
    # echo "$pomodoro_left_interrupt"
    # echo "$short_left_interrupt"
    # echo "$long_left_interrupt"
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
    echo -e "===================================="
    echo -e "📊 $label Stats"
    echo -e "===================================="
    echo -e "✔ Total Work Time: $(format_time "$pomodoros")"
    echo -e "☕ Total Short Breaks: $(format_time "$short_breaks")"
    echo -e "💤 Long Breaks: $(format_time "$long_breaks")"
    echo -e "⚠ Total Interrupts during work: $pomodoro_interrupts_count"
    echo -e "⚠ Total Interrupts during short breaks: $short_break_interrupts_count"
    echo -e "⚠ Total Interrupts during long breaks: $long_break_interrupts_count"
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
            # today=$(date '+%Y-%m-%d')
            # calculate_stats "$today" "$today"
            # display_stats "Today's"
            today_stats
            ;;
        2)
            # if [[ "$(uname)" == "Linux" ]]; then
            #     week_start=$(date -d "6 days ago" '+%Y-%m-%d')
            # else
            #     week_start=$(date -v -6d '+%Y-%m-%d')
            # fi
            # calculate_stats "$week_start" "$today"
            # display_stats "Weekly"
            weekly_stats
            ;;
        3)
            # if [[ "$(uname)" == "Linux" ]]; then
            #     month_start=$(date -d "$(date +%Y-%m-01)" '+%Y-%m-%d')
            # else
            #     month_start=$(date -v1d '+%Y-%m-%d')
            # fi
            # calculate_stats "$month_start" "$today"
            # display_stats "Monthly"
            monthly_stats
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

monthly_stats() {
    declare -a months=("January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December")

    first_line=$(head -n 1 "$LOG_FILE")
    start_year=$(echo "$first_line" | cut -d'-' -f1 | sed 's/^\[//')
    start_month=$(echo "$first_line" | cut -d'-' -f2 | sed 's/^0*//') # Remove leading zeros

    current_year=$(date '+%Y')
    current_month=$(date '+%m' | sed 's/^0*//') # Remove leading zeros

    year=$start_year
    month=$start_month

    while [[ $year -lt $current_year || ($year -eq $current_year && $month -le $current_month) ]]; do
        next_month=$((month + 1))
        next_year=$year

        if [[ $next_month -eq 13 ]]; then
            next_month=1
            next_year=$((year + 1))
        fi

        # Format start and end date as YYYY-MM-DD
        start_date=$(printf "%04d-%02d-01 00:00:00" "$year" "$month")
        end_date=$(printf "%04d-%02d-01 00:00:00" "$next_year" "$next_month")

        calculate_stats "$start_date" "$end_date"
        display_stats "${months[$((month - 1))]} $year"

        month=$next_month
        year=$next_year
    done
}

weekly_stats() {
    # Get the date of the first log line
    first_line=$(head -n 1 "$LOG_FILE")
    first_date=$(echo "$first_line" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
    
    # Start from the beginning of the week (Monday) for first_date
    start_date=$(date -j -f "%Y-%m-%d" "$first_date" "+%Y-%m-%d" 2>/dev/null || date -d "$first_date" "+%Y-%m-%d")
    day_of_week=$(date -j -f "%Y-%m-%d" "$start_date" "+%u" 2>/dev/null || date -d "$start_date" "+%u")
    start_epoch=$(date -j -f "%Y-%m-%d" "$start_date" +%s 2>/dev/null || date -d "$start_date" +%s)
    start_epoch=$((start_epoch - (day_of_week - 1) * 86400))  # Move to Monday

    # Current time in epoch
    current_epoch=$(date +%s)

    while [[ $start_epoch -lt $current_epoch ]]; do
        end_epoch=$((start_epoch + 7 * 86400))

        # Format readable date range for display
        start_str=$(date -r "$start_epoch" "+%Y-%m-%d 00:00:00" 2>/dev/null || date -d "@$start_epoch" "+%Y-%m-%d 00:00:00")
        end_str=$(date -r "$end_epoch" "+%Y-%m-%d 00:00:00" 2>/dev/null || date -d "@$end_epoch" "+%Y-%m-%d 00:00:00")

        # Calculate and display
        calculate_stats "$start_str" "$end_str"
        display_stats "Week of $(date -r "$start_epoch" "+%d %b %Y" 2>/dev/null || date -d "@$start_epoch" "+%d %b %Y")"

        start_epoch=$end_epoch
    done
}

today_stats() {
    # Get current date in YYYY-MM-DD format
    today=$(date "+%Y-%m-%d")

    # Start and end time for today
    start_date="$today 00:00:00"
    end_date="$today 23:59:59"

    calculate_stats "$start_date" "$end_date"
    display_stats "Today ($today)"
}

show_menu

# if(system == "Darwin"){
#                         cmd = "date -j -f \"%Y-%m-%d %H:%M:%S\" \"" log_date "\" +%s"
#                     }
#                     else if (system == "Linux"){
#                         cmd = "date -d \"" log_date "\" +%s"
#                     } else{
#                         print "Unknown OS:", system
#                     }
