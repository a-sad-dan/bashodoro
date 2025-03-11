#! /bin/bash
set -euo pipefail # Safe scripting

# Load configuration
CONFIG_FILE="config/settings.conf"
# shellcheck disable=SC1090
source "$CONFIG_FILE"

# Helper function for usage instructions
help() {
  echo "bashodoro - A simple Bash-based Pomodoro timer"
  echo ""
  echo "Usage: bashodoro -> Starts a bashodoro session with the default config"
  echo ""
  echo "Options:"
  echo "  -s, --stats       show the statistics of sessions"
  echo "  -c, --config               show the current config"
  echo "  -h, --help            Show this help message"
  echo ""
  exit 1
}

# Argument parsing
if [[ $# -eq 0 ]]; then
  bash bin/timer.sh start
else
  case "$1" in
  --help | -h)
    help
    ;;
  --stats | -s)
    echo "Show the history"
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
