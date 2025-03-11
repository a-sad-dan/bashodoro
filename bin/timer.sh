#!/bin/bash

set -euo pipefail

start_timer() {
    local duration="$1"
    echo "Time left Until Break"

    for ((i = duration; i >= 0; i--)); do
        echo -ne "\r$i"
        delete_line

        # listen for interrupt every 1 s
        keyPress=$(get_input)

        if [[ $keyPress == "p" || $keyPress == "P" ]]; then
            pause_timer "$i"
            return
        fi
    done
    bash bin/notify.sh "Time's up!"
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

pause_timer() {
    echo ""
    paused_time=$1
    echo "Timer paused at $paused_time, press r to resume"

    while true; do
        key=$(get_input)
        if [[ $key == "r" || $key == "R" ]]; then
            resume_timer "$paused_time"
        fi
    done
}

resume_timer() {
    clear
    start_timer "$1"
    # Clear the terminal and start the timer again for now

}

case "$1" in
start) start_timer 10 ;; # Example: 10s
pause) pause_timer ;;
resume) resume_timer ;;
stop) echo "Timer stopped." ;;
*) echo "Usage: $0 {start|pause|resume|stop}" ;;
esac
