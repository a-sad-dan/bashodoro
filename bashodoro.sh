#! /bin/bash

# Main entry point of the script

set -euo pipefail #safe scripting

CONFIG_FILE="config/settings.conf"
source "$CONFIG_FILE"

# Helper function for usage instructions
usage() {
  echo "Usage: $0 {start|pause|resume|stop}"
  exit 1
}

if [[ $# -eq 0 ]]; then
  usage
fi

#!/bin/bash

set -euo pipefail # Safe scripting

# Load configuration
CONFIG_FILE="config/settings.conf"
source "$CONFIG_FILE"

# Helper function for usage instructions
usage() {
  echo "Usage: $0 {start|pause|resume|stop}"
  exit 1
}

# Argument parsing
if [[ $# -eq 0 ]]; then
  usage
fi

case "$1" in
start)
  bash bin/timer.sh start
  ;;
pause)
  bash bin/timer.sh pause
  ;;
resume)
  bash bin/timer.sh resume
  ;;
stop)
  bash bin/timer.sh stop
  ;;
*)
  usage
  ;;
esac
