#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

set -euo pipefail

LOG_FILE="$SCRIPT_DIR/logs/bashodoro.log"

if [[ ! -f $LOG_FILE ]]; then
  echo -e "Log Not file found, Creating Log File"
  mkdir logs
  touch "$LOG_FILE"
fi

save_session() {
  local type="$1"     # Long_break, Short_break, Pomodoro
  local duration="$2" # Duration in seconds

  # Append log entry to file
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$type] [$duration]" >>"$LOG_FILE"

  # echo "Session saved successully in Logs"
}

get_session_num() {
  #logic -> see the number of entries having the same date as today's date -> return the number
  local today
  today=$(date '+%Y-%m-%d')

  sess_num=$(grep "$today" "$LOG_FILE" | grep -c "\[Pomodoro\]")
  echo "$sess_num"
}
