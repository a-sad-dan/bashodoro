
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../config" && pwd)"
set -euo pipefail


source "$CONFIG_DIR/settings.conf"

# Detect platform
OS_TYPE="$(uname -s)"
IS_WSL=false
if grep -qiE "(Microsoft|WSL)" /proc/version 2>/dev/null; then
  IS_WSL=true
fi

# Function: Play Notification Sound
notificationSound() {
  if [ "$SOUNDS" = true ]; then
    if $IS_WSL && command -v powershell.exe &>/dev/null; then
      SOUND_FILE_PATH=$(wslpath -w "$SCRIPT_DIR/sounds/$1")
      powershell.exe -Command "Add-Type -AssemblyName presentationCore; Add-Type -AssemblyName System.Windows.Forms; \$player = New-Object System.Media.SoundPlayer '$SOUND_FILE_PATH'; \$player.PlaySync()" >/dev/null
    elif [[ "$OS_TYPE" == "Darwin" ]] && command -v afplay &>/dev/null; then
      afplay "$SCRIPT_DIR/sounds/$1" &
    elif command -v paplay &>/dev/null; then
      paplay "$SCRIPT_DIR/sounds/$1" &
    else
      echo "[WARN] No supported sound player found on this OS."
    fi
  fi
}

# Function: Send Desktop Notification
sendNotification() {
  if [ "$NOTIFICATIONS" = true ]; then
    message="${1:-Task Completed!}"

    if $IS_WSL && command -v powershell.exe &>/dev/null; then
      # powershell.exe -Command "[System.Windows.Forms.MessageBox]::Show('$message')" >/dev/null
      powershell.exe -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('$message')" >/dev/null

    elif [[ "$OS_TYPE" == "Darwin" ]] && command -v osascript &>/dev/null; then
      osascript -e "display notification \"$message\" with title \"BASHodoro\""
    elif command -v notify-send &>/dev/null; then
      notify-send -i "$SCRIPT_DIR/logo.png" -t 1000 -a "Bashodoro" "Bashodoro" "$message"
    else
      echo "[INFO] $message (no notification tool available)"
    fi
  fi
}

# Main Command Handler
case "$1" in
start)
  sendNotification "Timer Started!"
  notificationSound "joyous.wav"
  ;;
pause)
  sendNotification "Timer Paused!"
  notificationSound "slick.wav"
  ;;
resume)
  sendNotification "Timer Resumed!"
  notificationSound "jokingly.wav"
  ;;
stop)
  sendNotification "Timer Stopped!"
  notificationSound "joyous.wav"
  ;;
complete)
  sendNotification "Time's up!"
  notificationSound "jokingly.wav"
  ;;
*)
  echo "Usage: $0 {start|pause|resume|stop|complete}"
  ;;
esac















# #!/bin/bash

# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../config" && pwd)"
# set -euo pipefail
# source "$CONFIG_DIR/settings.conf"

# #notify-send "$1" # Linux desktop notification

# notificationSound() {
#   if [ "$SOUNDS" = true ]; then
#     if command -v paplay &>/dev/null; then
#       paplay "$SCRIPT_DIR/sounds/$1" & # Linux (PulseAudio)
#     elif command -v afplay &>/dev/null; then
#       afplay "$SCRIPT_DIR/sounds/$1" & # macOS
#     elif command -v powershell.exe &>/dev/null; then
#       powershell.exe -Command "Add-Type -AssemblyName presentationCore; (New-Object Media.SoundPlayer '$SCRIPT_DIR\\sounds\\$1').PlaySync()"
#     else
#       echo "No supported audio player found."
#     fi
#   fi
# }

# sendNotification() {
#   if [ "$NOTIFICATIONS" = true ]; then
#     message="${1:-Task Completed!}" # Use first argument or default message

#     if command -v notify-send &>/dev/null; then
#       notify-send -i "$SCRIPT_DIR/logo.png" \
#         -t 1000 \
#         -a "Bashodoro" \
#         "Bashodoro" "$message"

#     elif command -v osascript &>/dev/null; then
#       osascript -e "display notification \"$message\" with title \"BASHodoro\""

#     elif command -v powershell.exe &>/dev/null; then
#       powershell.exe -Command "[System.Windows.Forms.MessageBox]::Show('$message')"

#     else
#       echo "No notification tool found. Message: $message"
#     fi
#   fi
# }

# case "$1" in
# start)
#   sendNotification "Timer Started!"
#   notificationSound "joyous.wav"
#   ;;
# pause)
#   sendNotification "Timer Paused!"
#   notificationSound "slick.wav"
#   ;;
# resume)
#   sendNotification "Timer Resumed!"
#   notificationSound "jokingly.wav"
#   ;;
# stop)
#   sendNotification "Timer Stopped!"
#   notificationSound "joyous.wav"
#   ;;
# complete)
#   sendNotification "Time's up!"
#   notificationSound "jokingly.wav"
#   ;;
# *) echo "Usage: $0 {start|pause|resume|stop}" ;;
# esac
