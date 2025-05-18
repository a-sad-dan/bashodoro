#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/config/settings.conf"

# Per-user logs
LOG_DIR="$HOME/.bashodoro/logs"
LOG_FILE="$LOG_DIR/bashodoro.log"


if [[ ! -f $LOG_FILE ]]; then
    echo "Log file not found"
    exit 1
fi


calculate_stats_fromawk() {
    local from_time="$1"
    local to_time="$2"
    local log_file="$LOG_FILE"  # Set your default log file path here
    AWK=$(command -v gawk || command -v awk)
    "$AWK" -F',' -v from="$from_time" -v to="$to_time" '
function parse_datetime(s,    d, t) {
    split(s, dt, " ")
    split(dt[1], d, "-")
    split(dt[2], t, ":")
    return mktime(d[1] " " d[2] " " d[3] " " t[1] " " t[2] " " t[3])
}

BEGIN {
    total_work = total_short = total_long = 0
    count_work = count_short = count_long = 0
    int_work = int_short = int_long = 0
}

{
    ts = $1
    type = $2
    signal = $3
    duration = $4

    t = parse_datetime(ts)

    if ((from == "" || t >= parse_datetime(from)) &&
        (to == "" || t <= parse_datetime(to))) {

        if (type == "Pomodoro") {
            if (signal == "End") {
                total_work += duration
                count_work++
            } else if (signal == "Interrupt") {
                int_work++
            }
        } else if (type == "Short_break") {
            if (signal == "End") {
                total_short += duration
                count_short++
            } else if (signal == "Interrupt") {
                int_short++
            }
        } else if (type == "Long_break") {
            if (signal == "End") {
                total_long += duration
                count_long++
            } else if (signal == "Interrupt") {
                int_long++
            }
        }
    }
}

END {
    total_all = total_work + total_short + total_long

    printf("----- Bashodoro Stats -----\n")
    printf("Time Range: %s to %s\n\n", from == "" ? "START" : from, to == "" ? "NOW" : to)

    printf("Work Time       : %.2f min (%d sessions)\n", total_work / 60, count_work)
    printf("Short Break Time: %.2f min (%d sessions)\n", total_short / 60, count_short)
    printf("Long Break Time : %.2f min (%d sessions)\n", total_long / 60, count_long)

    printf("\nInterrupts:\n")
    printf("  Work        : %d\n", int_work)
    printf("  Short Break : %d\n", int_short)
    printf("  Long Break  : %d\n", int_long)

    if (total_all > 0) {
        printf("\nTime Distribution:\n")
        printf("  Work        : %.2f%%\n", total_work * 100 / total_all)
        printf("  Short Break : %.2f%%\n", total_short * 100 / total_all)
        printf("  Long Break  : %.2f%%\n", total_long * 100 / total_all)
    }
    printf("-----------------------------\n")
}
' "$log_file"
}

# display_stats() {
#     local label="$1"
#     clear
#     echo -e "===================================="
#     echo -e "📊 $label Stats"
#     echo -e "===================================="
#     echo -e "✔ Total Work Time: $(format_time "$pomodoros")"
#     echo -e "☕ Total Short Breaks: $(format_time "$short_breaks")"
#     echo -e "💤 Long Breaks: $(format_time "$long_breaks")"
#     echo -e "⚠ Total Interrupts during work: $pomodoro_interrupts_count"
#     echo -e "⚠ Total Interrupts during short breaks: $short_break_interrupts_count"
#     echo -e "⚠ Total Interrupts during long breaks: $long_break_interrupts_count"
#     echo -e "===================================="
#     echo -e "Press any key to continue (q to quit)"
# }

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
    echo -e "Press any key to continue (q to quit)"
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
            calculate_stats_fromawk "$(date '+%Y-%m-%d 00:00:00')" "$(date '+%Y-%m-%d 23:59:59')"
            wait_for_key
            clear
            ;;
        2)
            reverse_weekly_stats
            clear
            ;;
        3)
            reverse_monthly_stats
            clear
            ;;
        4)
            calculate_stats_fromawk "" ""
            wait_for_key
            clear
            ;;
        5)
            display_reasons
            wait_for_key
            clear
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
    start_year=$(echo "$first_line" | cut -d'-' -f1)
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
        echo "${months[$((month - 1))]} $year"
        calculate_stats_fromawk "$start_date" "$end_date"
        wait_for_key
        clear
    done
}

reverse_weekly_stats() {

    # Get the date of the first log line
    first_line=$(head -n 1 "$LOG_FILE")
    first_date=$(echo "$first_line" | cut -d' ' -f1)

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
        echo "Week $i";

        calculate_stats_fromawk "$start_str" "$end_str"
        wait_for_key
        clear
    done
}

show_menu