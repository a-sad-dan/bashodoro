#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

set -euo pipefail

# Per-user logs
LOG_DIR="$HOME/.bashodoro/logs"
LOG_FILE="$LOG_DIR/bashodoro.log"

# Ensure the logs directory exists
mkdir -p "$LOG_DIR"

# Ensure the log file exists
if [[ ! -f $LOG_FILE ]]; then
  echo "Log file not found, creating log file at $LOG_FILE"
  touch "$LOG_FILE"
fi

save_session() {
  local type="$1"     # Long_break, Short_break, Pomodoro
  local duration="$2" # Duration in seconds

  # Append log entry to file
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$type] [$duration]" >>"$LOG_FILE"
}

get_session_num() {
  # Logic: count the number of Pomodoro entries with today's date
  local today
  today=$(date '+%Y-%m-%d')

  sess_num=$(grep "$today" "$LOG_FILE" | grep -c "\[Pomodoro\]")
  echo "$sess_num"
}
