#!/bin/bash

set -euo pipefail

start_timer() {
    local duration="$1"
    echo "Starting timer for $duration seconds..."
    sleep "$duration"
    bash bin/notify.sh "Time's up!"
}

pause_timer() {
    echo "Pause functionality to be implemented."
}

resume_timer() {
    echo "Resume functionality to be implemented."
}

case "$1" in
start) start_timer 10 ;; # Example: 1s
pause) pause_timer ;;
resume) resume_timer ;;
stop) echo "Timer stopped." ;;
*) echo "Usage: $0 {start|pause|resume|stop}" ;;
esac
