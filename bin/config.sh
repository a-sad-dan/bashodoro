#!/bin/bash

# Define the directory where the configuration file is stored
CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../config" && pwd)"
SETTING_CONF="$CONFIG_DIR/settings.conf"

set -ueo pipefail #error handeling

# Function to update configuration settings in settings.conf
update_config() {
    local key="$1"
    local value="$2"
    local file="$SETTING_CONF" # Update settings.conf instead of bashodoro.conf

    # If key exists in file, update it; otherwise, add it
    if grep -q "^$key=" "$file"; then
        sed -i "s/^$key=.*/$key=$value/" "$file"
        # todo -> Update function to only change the value, NOT remove the Comments
    else
        echo "$key=$value" >>"$file"
    fi
}

# Function to display settings.conf nicely formatted with colors
pretty_print_config() {
    echo -e "\n🔧 \e[1mCurrent Bashodoro Settings:\e[0m"
    echo -e "----------------------------------"

    while IFS='=' read -r key value; do
        # Skip empty lines or lines starting with #
        if [[ -z "$key" || "$key" =~ ^# ]]; then
            continue
        fi

        # Prepare a nice label
        case "$key" in
        WORK_DURATION) label="Work Duration" ;;
        SHORT_BREAK) label="Short Break" ;;
        LONG_BREAK) label="Long Break" ;;
        SESSION_COUNT) label="Sessions Before Long Break" ;;
        AUTO_MODE) label="Auto Start Sessions" ;;
        NOTIFICATIONS) label="Desktop Notifications" ;;
        SOUNDS) label="Sound Alerts" ;;
        *) label="$key" ;; # fallback
        esac

        # Apply transformations (e.g., seconds to minutes, colors)
        case "$key" in
        WORK_DURATION | SHORT_BREAK | LONG_BREAK)
            minutes=$((value / 60))
            printf "%-30s : %s minutes\n" "$label" "$minutes"
            ;;
        AUTO_MODE | NOTIFICATIONS | SOUNDS)
            if [[ "$value" == "true" ]]; then
                printf "%-30s : \e[32m%s\e[0m\n" "$label" "Enabled"
            else
                printf "%-30s : \e[31m%s\e[0m\n" "$label" "Disabled"
            fi
            ;;
        *)
            printf "%-30s : %s\n" "$label" "$value"
            ;;
        esac
    done <"$SETTING_CONF"

    echo -e "----------------------------------\n"
}

# Function to display the main configuration menu
show_menu() {
    while true; do

        echo -e "\n Bashodoro Configuration Menu"
        echo -e "===================================="
        echo "1) View current settings"
        echo "2) Change settings"
        echo "3) Exit"
        echo -e "====================================\n"

        read -rp "Choose an option: " choice

        case "$choice" in

        1) pretty_print_config ;;
        2) modify_settings ;; # Modify settings
        3)
            clear
            echo " Exiting..."
            exit 0
            ;;                                          # Exit the script
        *) echo " Invalid choice! Please try again." ;; # Handle invalid inputs
        esac
    done
}

# Function to modify configuration settings
modify_settings() {
    echo -e "\n🔧 Updating Settings..."

    # Prompt user for sound preference (on/off)
    read -rp "Do you want to enable sound alerts? (yes/no): " sound_choice
    case "$sound_choice" in
    yes | YES | y | Y) update_config "SOUNDS" "true" ;;
    no | NO | n | N) update_config "SOUNDS" "false" ;;
    *) echo " Invalid choice! Keeping existing setting." ;;
    esac

    #prompt for Notifiaction ON and OFF
    read -rp "Do you want to enable Notification alerts? (yes/no): " Notify
    case "$Notify" in
    yes | YES | y | Y) update_config "NOTIFICATIONS" "true" ;;
    no | NO | n | N) update_config "NOTIFICATIONS" "false" ;;
    *) echo " Invalid choice! Keeping existing setting." ;;
    esac

    #Prompt user for auto start sessions
    read -rp "Do you want to enable auto-start of sesssions? (yes/no): " auto_choice
    case "$auto_choice" in
    yes | YES | y | Y) update_config "AUTO_MODE" "true" ;;
    no | NO | n | N) update_config "AUTO_MODE" "false" ;;
    *) echo " Invalid choice! Keeping existing setting." ;;
    esac

    # Prompt user for work session duration (in minutes)
    read -rp "Enter work session duration (in minutes): " work_duration
    if [[ "$work_duration" =~ ^[1-9][0-9]*$ ]]; then
        update_config "WORK_DURATION" "$((work_duration * 60))"
    else
        echo " Invalid input! Keeping existing setting."
    fi

    # Prompt user for short break duration (in minutes)
    read -rp "Enter short break duration (in minutes): " short_break
    if [[ "$short_break" =~ ^[1-9][0-9]*$ ]]; then
        update_config "SHORT_BREAK" "$((short_break * 60))"
    else
        echo " Invalid input! Keeping existing setting."
    fi

    # Prompt user for long break duration (in minutes)
    read -rp "Enter long break duration (in minutes): " long_break
    if [[ "$long_break" =~ ^[1-9][0-9]*$ ]]; then
        update_config "LONG_BREAK" "$((long_break * 60))"
    else
        echo " Invalid input! Keeping existing setting."
    fi

    # Prompt user for number of work sessions until long break
    read -rp "Enter number of work sessions before long break: " session_count
    if [[ "$session_count" =~ ^[1-9][0-9]*$ ]]; then
        update_config "SESSION_COUNT" "$session_count"
    else
        echo " Invalid input! Keeping existing setting."
    fi

    echo " All changes saved!"
}

# Function to create a new configuration file with default settings
create_config_file() {
    local file="$1"
    echo " File does not exist: $file"
    echo " Creating new config file: $file"

    cat <<EOL >"$file"
# WORK_DURATION=1500
# SHORT_BREAK=300
# LONG_BREAK=900
# SESSION_COUNT=4         
# AUTO_MODE=true          
# NOTIFICATIONS=true
# SOUNDS=true

EOL

    echo " Config file created: $file"
}

# creating file when user choose  mode for config
ownfile_creation() {
    read -rp "Enter your setting file name: " name
    if [[ -n "$name" ]]; then
        FILE="$CONFIG_DIR/$name.conf"

        if [[ ! -f "$FILE" ]]; then
            create_config_file "$FILE"
        fi
        nano "$FILE" # Open file in nano editor
    else
        echo "Please provide file name"
        exit 1
    fi
}

opretional_mode() {
    file_names=() # Initialize an array to store filenames present in config

    # Loop to populate the array
    for item_path in "$CONFIG_DIR"/*; do
        if [[ -f "$item_path" ]]; then
            filename="${item_path##*/}"
            file_names+=("$filename")
        fi
    done

    if [[ ${#file_names[@]} -ge 3 ]]; then
        for file_name in "${file_names[@]}"; do
            if [[ "$file_name" != "bashodoro.conf" && "$file_name" != "settings.conf" ]]; then
                rm "$CONFIG_DIR/$file_name" # Deleting existing file
                ownfile_creation
            fi
        done
    else
        ownfile_creation
    fi
}

# starting of config file
while true; do
    show_menu
done
