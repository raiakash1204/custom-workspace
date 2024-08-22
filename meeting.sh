#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color

# Log file location
LOGFILE="$HOME/start_meeting_workspace.log"

# Function to log messages
log_message() {
    local message="$1"
    local color="$2"
    echo -e "${color}${message}${NC}" | tee -a "$LOGFILE"
}

# Function to check if a process is running
is_running() {
    pgrep "$1" > /dev/null 2>&1
}

# Function to perform the check and start application
# app_name is used to check for the process
# command is used to run the app
# description is the description of the app
check_and_start() {
    local app_name="$1"
    local command="$2"
    local description="$3"
    
    log_message "\nChecking for ${description}..." "$WHITE"
    sleep 2
    
    if ! is_running "$app_name"; then
        log_message "Attempting to start ${description} in the background..." "$YELLOW"
        sleep 1
        # Use nohup to start the app in the background without blocking
        nohup $command &>/dev/null &
        disown
        sleep 2
        if is_running "$app_name"; then
            log_message "${description} has been started successfully." "$GREEN"
        else
            log_message "Failed to start ${description}." "$RED"
        fi
    else
        log_message "${description} is already running." "$GREEN"
    fi
}

# Function to move an application window to a specific desktop
move_to_desktop() {
    local app_name="$1"
    local desktop_number="$2"
    
    # Find the window ID of the application
    local window_id
    window_id=$(wmctrl -l | grep "$app_name" | awk '{print $1}')
    
    if [ -z "$window_id" ]; then
        log_message "No window found for application: $app_name" "$RED"
        return 1
    fi
    
    # Move the window to the specified desktop
    wmctrl -i -r "$window_id" -t "$desktop_number"
    
    if [ $? -eq 0 ]; then
        log_message "\nMoved $app_name to desktop $desktop_number." "$GREEN"
    else
        log_message "Failed to move $app_name to desktop $desktop_number." "$RED"
    fi
}

# Start checking for applications with a delay
log_message "Starting the meeting workspace..." "$WHITE"
sleep 1
log_message "Apps to start.." "$WHITE"
log_message "Thunderbird" "$WHITE"
log_message "Zoom" "$WHITE"
log_message "Firefox" "$WHITE"

check_and_start "thunderbird" "thunderbird" "Thunderbird"
sleep 2

check_and_start "zoom" "zoom" "Zoom"
sleep 2

check_and_start "firefox" "firefox" "Firefox"
sleep 5

move_to_desktop "Thunderbird" "1"

log_message "Successfully started the meeting workspace" "$WHITE"
