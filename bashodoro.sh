#! /bin/bash

# Get the directory where the script is located
# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

cd "$SCRIPT_DIR" || exit 1 # Ensure that the script is always called from the directory

# Set default values
WORK_DURATION=25
SHORT_BREAK=5
LONG_BREAK=15
AUTO_MODE=true

set -euo pipefail # Safe scripting

# Load configuration and config files
# shellcheck disable=SC1091
source "$SCRIPT_DIR/config/settings.conf"

# shellcheck disable=SC1091
source "$SCRIPT_DIR/bin/timer.sh"

# shellcheck disable=SC1091
# Load Session.sh
source "$SCRIPT_DIR/bin/session.sh"

print_logo() {
  echo -e "                                                
                █████████████████                
               ██               ██               
               ██               ██               
               ██               ██               
            ██   ███         ███                 
              ██   ███     ███                   
                ██    █████                      
                ██    █████                      
              ██   ███     ███                   
            ██   ███         ███                 
               ██               ██               
               ██  ███████████  ██               
               ██               ██               
                █████████████████                
"
}

# Helper function for usage instructions
help() {

  print_logo
  echo "Bashodoro - Your Productivity Timer"
  echo "Quick Start: ./bashodoro.sh"
  echo ""
  echo "Options:"
  echo "  -m, --manual      Start in manual mode (no auto-start)"
  echo "  -s, --stats                    Show session statistics"
  echo "  -c, --config          Display current configuration"
  echo "  -h, --help            Show this help message"
  echo "  Ctrl+C, Cmd+C         Quit the program"

  echo ""
  exit 1
}

start_pomodoro() {

  print_logo
  echo "Bashodoro - Your Productivity Timer"
  sleep 1.5 #For the notifications to finish playing -> Better UX
  clear

  local session_num

  while true; do
    session_num=$(($(get_session_num) + 1)) #FIX : Get session number in each loop

    bash "$SCRIPT_DIR/bin/notify.sh" start
    start_timer "$WORK_DURATION" "Pomodoro"

    clear

    if (! $AUTO_MODE); then
      manual_mode_prompt "Break Session"
    fi

    # Start Long Break after every X (session_count) sessions
    if (((session_num % SESSION_COUNT) == 0)); then
      bash "$SCRIPT_DIR/bin/notify.sh" start
      start_timer "$LONG_BREAK" "Long_break"

    # Take a short break
    else
      bash "$SCRIPT_DIR/bin/notify.sh" start
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
    # shellcheck disable=SC1091
    #Load stats.sh
    source "$SCRIPT_DIR/bin/stats.sh"
    exit 0
    ;;
  --config | -c)
    source "$SCRIPT_DIR/bin/config.sh"
    exit 0
    ;;
  *)
    echo "Invalid option: $1"
    echo "Usage: $0 [-h|--help] [-s|--stats] [-c|--config]"
    exit 1
    ;;
  esac
fi
