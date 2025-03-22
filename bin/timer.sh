#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

set -euo pipefail

# shellcheck disable=SC1091
source "$SCRIPT_DIR/bin/session.sh"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/config/settings.conf"

start_timer() {

    # Handle Quits in the middle
    trap 'handle_quit $type $duration' EXIT

    # get the session number
    local session
    session=$(($(get_session_num) + 1))

    local duration="$1"
    local type="$2" #Pomodoro #Short_break #Long_break

    # Find duration from type
    if [[ $type = "Pomodoro" ]]; then
        duration=$WORK_DURATION
    elif [[ $type = "Short_break" ]]; then
        duration=$SHORT_BREAK
    elif [[ $type = "Long_break" ]]; then
        duration=$LONG_BREAK
    fi

    # Determine total_time based on type from the sourced config file
    local total_time
    case "$type" in
    "Pomodoro") total_time=$WORK_DURATION ;;
    "Short_break") total_time=$SHORT_BREAK ;;
    "Long_break") total_time=$LONG_BREAK ;;
    *)
        echo "Invalid type: $type"
        return 1
        ;;
    esac

    print_separator
    if [[ $type = "Pomodoro" ]]; then
        echo "⌛ Work in Progress... Press [P] to pause"
        echo "🎯 Work Session #$session"
    elif [[ $type = "Short_break" ]]; then
        echo "☕ Take a short break! Relax for a few minutes."
    elif [[ $type = "Long_break" ]]; then
        echo "🌿 Time for a long break! Step away and recharge."
    fi

    # Log the start of the timer
    save_session "$type" "$duration" "Start"

    # Start the timer

    for ((i = duration; i >= 1; i--)); do
        echo -ne "\r⏳ Time Left: $(format_time $i) $(progress_bar "$total_time" $i)"
        delete_line

        # listen for interrupt every 1 s
        keyPress=$(get_input)

        if [[ $keyPress == "p" || $keyPress == "P" ]]; then
            bash bin/notify.sh pause
            pause_timer "$i" "$type"
            return
        fi
    done

    # This marks the session as complete
    bash bin/notify.sh complete

    # Log the session in the file
    save_session "$type" "$duration" "End"

    return
}

handle_quit() {
    # take type and duration from the file
    local type=$1
    local duration=$2

    bash bin/notify.sh stop
    save_session "$type" "$duration" "Interrupt" # Log the session in the file

    # print logo for 1.5 seconds
    clear
    print_logo

    echo "Quitting Bashodoro..."
    sleep 1

    # clear the terminal and exit
    clear
    exit 0
}

# Todo - put these functions in a utility file
delete_line() {
    echo -en "\033[0K"
}

get_input() {
    local input
    IFS= read -r -t 1 -n 1 -s input
    echo "$input"
}

print_separator() {
    echo -e "──────────────────────────────────────────────────"
}

format_time() {
    local total_seconds=$1
    local minutes=$((total_seconds / 60))
    local seconds=$((total_seconds % 60))
    printf "%02d:%02d\n" "$minutes" "$seconds"
}

progress_bar() {
    local total=$1
    local current=$2
    local width=20                              # Length of the progress bar
    local filled=$(((current * width) / total)) # Filled part
    local empty=$((width - filled))             # Empty part
    local percent=$(((current * 100) / total))  # Percentage

    # Bar
    local bar="|"
    for ((i = 0; i < filled; i++)); do bar+="▰"; done
    for ((i = 0; i < empty; i++)); do bar+=" "; done
    bar+="|"

    # Print progress bar with percentage
    echo -e "$bar $percent%"
}

pause_timer() {
    clear
    print_separator
    paused_time=$1
    type=$2

    echo "⏸ Timer Paused "
    echo "🕒 $type | $(format_time "$paused_time") left"
    echo "Press [r] to Resume the timer"

    while true; do
        key=$(get_input)
        if [[ $key == "r" || $key == "R" ]]; then
            bash bin/notify.sh resume
            resume_timer "$paused_time" "$type"
            break
        fi
    done
}

resume_timer() {
    # Clear the terminal and start the timer again for now
    clear
    start_timer "$1" "$2"

}

# For Testing
# if [[ -n "${1:-}" ]]; then
#     case "$1" in
#     start)
#         start_timer 10
#         ;; # Example: 10s
#     pause) pause_timer ;;
#     resume) resume_timer ;;
#     stop) echo "Timer stopped." ;;
#     *) echo "Invalid Option" ;;
#     esac
# fi
