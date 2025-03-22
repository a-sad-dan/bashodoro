#!/bin/bash

# Define the directory where the configuration file is stored
CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../config" && pwd)"
DEFAULT_CONF="$CONFIG_DIR/bashodoro.conf"
SETTING_CONF="$CONFIG_DIR/settings.conf"

# Enable strict error handling
# -u: Treat unset variables as an error
# -e: Exit immediately if a command fails
# -o pipefail: If any command in a pipeline fails, the entire pipeline fails
set -ueo pipefail  

# Function to display the main configuration menu
show_menu() {
    while true; do
        echo -e "\n🔧 Bashodoro Configuration Menu"
        echo "1) View current settings"
        echo "2) Change settings"
        echo "3) Reset to default"
        echo "4) Exit"
        read -p "Choose an option: " choice

        case "$choice" in
            1) cat "$DEFAULT_CONF" ;;  # Display the configuration file
            2) modify_settings ;;  # Modify settings
            3) reset_defaults ;;  # Reset configuration to default
            4) echo "🚀 Exiting..."; exit 0 ;;  # Exit the script
            *) echo "❌ Invalid choice! Please try again." ;;  # Handle invalid inputs
        esac
    done
}

# Function to modify configuration settings
modify_settings() {
    echo -e "\n🔧 Updating Settings..."

    # Prompt user for sound preference (on/off)
    read -p "Do you want to enable sound alerts? (yes/no): " sound_choice
    case "$sound_choice" in
        yes|YES|y|Y) update_config "SOUNDS" "true" ;;
        no|NO|n|N) update_config "SOUNDS" "false" ;;
        *) echo "❌ Invalid choice! Keeping existing setting." ;;
    esac

    # Prompt user for short break duration (in minutes)
    read -p "Enter short break duration (in minutes): " short_break
    if [[ "$short_break" =~ ^[0-9]+$ ]]; then
        update_config "SHORT_BREAK" "$short_break"
    else
        echo "❌ Invalid input! Keeping existing setting."
    fi

    # Prompt user for work session duration (in minutes)
    read -p "Enter work session duration (in minutes): " work_duration
    if [[ "$work_duration" =~ ^[0-9]+$ ]]; then
        update_config "WORK_DURATION" "$work_duration"
    else
        echo "❌ Invalid input! Keeping existing setting."
    fi

    echo "✅ All changes saved!"
}

# Function to reset configuration file to default settings
reset_defaults() {
    create_config_file "$DEFAULT_CONF"
    echo "✅ Settings reset to default!"
}

# Function to create a new configuration file with default settings
create_config_file() {
    local file="$1"
    echo "⚠️ File does not exist: $file"
    echo "📄 Creating new config file: $file"

    cat <<EOL > "$file"
# Default Configuration
WORK_DURATION=25
SHORT_BREAK=5
LONG_BREAK=15
AUTO_MODE=true
SOUNDS=true
EOL

    echo "✅ Config file created: $file"
}

# If no arguments are provided, display the menu
if [[ $# -eq 0 ]]; then
    show_menu
fi

# If the -c option is provided, edit the specified configuration file or default to setting.conf
if [[ "$1" == "-c" ]]; then
    if [[ $# -ge 2 ]]; then
        FILE="$CONFIG_DIR/$2"
    else
        FILE="$SETTING_CONF"
    fi
    
    if [[ ! -f "$FILE" ]]; then
        create_config_file "$FILE"
    fi
    nano "$FILE"  # Open file in nano editor
else
    echo "Usage: config.sh -c [filename]"
    exit 1
fi
