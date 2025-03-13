#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source "./bin/session.sh"

# shellcheck disable=SC1091
source "./config/settings.conf"

start_timer() {
    # get the session number
    local session
    session=$(($(get_session_num) + 1))

    local duration="$1"
    local type="$2" #Pomodoro #Short_break #Long_break

    print_separator
    if [[ $type = "Pomodoro" ]]; then
        echo "⌛ Work in Progress... Press [P] to pause"
        echo "🎯 Work Session #$session"
    elif [[ $type = "Short_break" ]]; then
        echo "☕ Take a short break! Relax for a few minutes."
    elif [[ $type = "Long_break" ]]; then
        echo "🌿 Time for a long break! Step away and recharge."
    fi

    for ((i = duration; i >= 1; i--)); do
        echo -ne "\r⏳ Time Left: $i"
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
    save_session "$type" "$WORK_DURATION"
    return
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
    echo -e "──────────────────────────────────────"
}

pause_timer() {
    clear
    print_separator
    echo " "
    paused_time=$1
    type=$2

    echo "⏸ Timer Paused "
    echo "🕒 $type | $paused_time left"
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
if [[ -n "${1:-}" ]]; then
    case "$1" in
    start)
        start_timer 10
        ;; # Example: 10s
    pause) pause_timer ;;
    resume) resume_timer ;;
    stop) echo "Timer stopped." ;;
    *) echo "Usage: $0 {start|pause|resume|stop}" ;;
    esac
fi
