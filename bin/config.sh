#!/bin/bash

# Define the directory where the configuration file is stored
CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../config" && pwd)"
DEFAULT_CONF="$CONFIG_DIR/bashodoro.conf"
SETTING_CONF="$CONFIG_DIR/settings.conf"

set -ueo pipefail   #error handeling

# Function to update configuration settings in settings.conf

update_config() {
    local key="$1"
    local value="$2"
    local file="$SETTING_CONF"  # Update settings.conf instead of bashodoro.conf

    # If key exists in file, update it; otherwise, add it
    if grep -q "^$key=" "$file"; then
        sed -i "s/^$key=.*/$key=$value/" "$file"
    else
        echo "$key=$value" >> "$file"
    fi
}

# Function to display the main configuration menu
show_menu() {
    while true; do
        echo -e "\n Bashodoro Configuration Menu"
        echo "1) View current settings"
        echo "2) Change settings"
        echo "3) Reset to default"
        echo "4) Exit"
        read -p "Choose an option: " choice

        case "$choice" in
            1) cat "$SETTING_CONF" ;;  # Display the configuration file
            2) modify_settings ;;  # Modify settings
            3) reset_defaults ;;  # Reset configuration to default
            4) echo " Exiting..."; exit 0 ;;  # Exit the script
            *) echo " Invalid choice! Please try again." ;;  # Handle invalid inputs
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
        *) echo " Invalid choice! Keeping existing setting." ;;
    esac

    #prompt for Notifiaction ON and OFF
     read -p "Do you want to enable Notification alerts? (yes/no): " Notify
    case "$Notify" in
        yes|YES|y|Y) update_config "NOTIFICATIONS" "true" ;;
        no|NO|n|N) update_config "NOTIFICATIONS" "false" ;;
        *) echo " Invalid choice! Keeping existing setting." ;;
    esac

    # Prompt user for short break duration (in minutes)
    read -p "Enter short break duration (in minutes): " short_break
    if [[ "$short_break" =~ ^[1-9][0-9]*$ ]]; then
        update_config "SHORT_BREAK" "$short_break"
    else
        echo " Invalid input! Keeping existing setting."
    fi

    # Prompt user for work session duration (in minutes)
    read -p "Enter work session duration (in minutes): " work_duration
    if [[ "$work_duration" =~ ^[1-9][0-9]*$ ]]; then
        update_config "WORK_DURATION" "$work_duration"
    else
        echo " Invalid input! Keeping existing setting."
    fi
    echo " All changes saved!"
}

# Function to reset configuration file to default settings
reset_defaults() {
    create_config_file "$DEFAULT_CONF"
    echo " Settings reset to default!"
}

# Function to create a new configuration file with default settings
create_config_file() {
    local file="$1"
    echo " File does not exist: $file"
    echo " Creating new config file: $file"

    cat <<EOL > "$file"
# Default Configuration
WORK_DURATION=2
SHORT_BREAK=50
LONG_BREAK=4       # 15 minutes
SESSION_COUNT=4    #4 sessions until long break
AUTO_MODE=true     #automatically start sessions
NOTIFICATIONS=true
SOUNDS=true
EOL

    echo " Config file created: $file"
}

# creating file when user choose opretional mode for config 
ownfile_creation(){
    read -p "Enter your setting file name: " name
    if [[ -n "$name" ]]; then
        FILE="$CONFIG_DIR/$name.conf"
    
    if [[ ! -f "$FILE" ]]; then
        create_config_file "$FILE"
    fi
    gvim "$FILE"  # Open file in nano editor
    else
    echo "Please provide file name"
    exit 1
    fi
}

opretional_mode() {
    file_names=()  # Initialize an array to store filenames present in config

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
                rm "$CONFIG_DIR/$file_name"  # Deleting existing file 
                ownfile_creation
            fi
        done
    else
        ownfile_creation
    fi
}


# satrting of config file 
while true ; do
echo "Wellcome To Configuration of Bashodoro"
echo "For intractive mode use I"
echo "For option mode use O"
echo "Enter X for exit "
read -p "Enter Mode For Change Config : " choose1
case "$choose1" in 
    I|i) show_menu;;
    O|o) opretional_mode;;
    x|X) exit;;
    *) echo "Not a valid input";;
esac
done
