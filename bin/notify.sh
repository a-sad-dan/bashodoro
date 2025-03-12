#!/bin/bash

set -euo pipefail

#notify-send "$1" # Linux desktop notification

sendNotification() {
  #
  message="${1:-Task Completed!}" # Use first argument or default message

  if command -v notify-send &>/dev/null; then
    notify-send -i "$(realpath ./../logo.png)" \
      -t 2000 \
      -a "Bashodoro" \
      "Bashodoro" "$message"

  elif command -v osascript &>/dev/null; then
    osascript -e "display notification \"$message\" with title \"BASHodoro\""

  elif command -v powershell.exe &>/dev/null; then
    powershell.exe -Command "[System.Windows.Forms.MessageBox]::Show('$message')"

  else
    echo "No notification tool found. Message: $message"
  fi
}

case "$1" in
start) sendNotification "Timer Started!" ;;
pause) sendNotification "Timer Paused!" ;;
resume) sendNotification "Timer Resumed!" ;;
stop) sendNotification "Timer Stopped!" ;;
complete) sendNotification "Time's up!" ;;
*) echo "Usage: $0 {start|pause|resume|stop}" ;;
esac
