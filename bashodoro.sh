#! /bin/bash
set -euo pipefail # Safe scripting

# Automatic mode is set by default
AUTO_MODE=true

# Load configuration
CONFIG_FILE="config/settings.conf"
# shellcheck disable=SC1090
source "$CONFIG_FILE"

# Load timer.sh functions (session.sh is included inside)
# shellcheck disable=SC1091
source "./bin/timer.sh"

# Helper function for usage instructions
help() {
  echo "bashodoro - A simple Bash-based Pomodoro timer"
  echo ""
  echo "Usage: bashodoro -> Starts a bashodoro session with the default config"
  echo ""
  echo "Options:"
  echo "  -s, --stats       show the statistics of sessions"
  echo "  -c, --config              show the current config"
  echo "  -h, --help                 Show this help message"
  echo "  ^c, cmd c                        Quit the Program"
  echo ""
  exit 1
}

start_pomodoro() {

  local session_num
  session_num=$(($(get_session_num) + 1))

  while true; do
    bash bin/notify.sh start
    start_timer "$WORK_DURATION" "Pomodoro"

    # sleep 1 #For the notifications to finish playing -> Better UX
    clear
    if (! $AUTO_MODE); then
      manual_mode_prompt "Break Session"
    fi

    # Start Long Break after every X (session_count) sessions
    if ((session_num % SESSION_COUNT == 0)); then
      bash bin/notify.sh start
      start_timer "$LONG_BREAK" "Long_break"

    # Take a short break
    else
      bash bin/notify.sh start
      start_timer "$SHORT_BREAK" "Short_break"
    fi

    # sleep 1
    clear

    if (! $AUTO_MODE); then
      manual_mode_prompt "Pomodoro Session"
    fi

  done
}

# Prompt for manual mode
manual_mode_prompt() {
  session_name=$1
  echo "Manual mode enabled. Press [Enter] to start the $session_name or [q] to quit."
  while true; do
    read -rsn1 key
    case "$key" in
    '')
      clear
      break
      ;; # Start session
    q | Q)
      clear
      echo "Exiting Bashodoro"
      exit 0
      ;;
    esac
  done
}

# Argument parsing
if [[ $# -eq 0 ]]; then
  start_pomodoro
else
  case "$1" in
  --manual | -m)
    AUTO_MODE=false
    start_pomodoro
    ;;
  --help | -h)
    help
    ;;
  --stats | -s)
    echo "Show the statistics from logs"
    exit 0
    ;;
  --config | -c)
    echo "Show the config"
    exit 0
    ;;
  *)
    echo "Invalid option: $1"
    echo "Usage: $0 [-h|--help] [-s|--stats] [-c|--config]"
    exit 1
    ;;
  esac
fi
