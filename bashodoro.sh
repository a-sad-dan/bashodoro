#! /bin/bash
set -euo pipefail # Safe scripting

# Load configuration
CONFIG_FILE="config/settings.conf"
# shellcheck disable=SC1090
source "$CONFIG_FILE"

# Load timer.sh functions
# shellcheck disable=SC1091
source "./bin/timer.sh"

# Load session.sh to get the session number

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

  done
}

# Argument parsing
if [[ $# -eq 0 ]]; then
  start_pomodoro
else
  case "$1" in
  --help | -h)
    help
    ;;
  --stats | -s)
    echo "Show the statistics from logs"
    ;;
  --config | -c)
    echo "Show the config"
    ;;
  *)
    echo "$0 Invalid option"
    echo "Try -h for help"
    ;;
  esac
fi
