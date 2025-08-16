#!/bin/bash

# Rofi Power Menu Script
# Provides Lock, Logout, Reboot, Shutdown options with confirmations

# Define options
options="Lock\nLogout\nReboot\nShutdown"

# Show main menu
chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu" -theme-str 'window {width: 200px;}')

case $chosen in
    "Lock")
        i3lock-color -c 1e1e2e
        ;;
    "Logout")
        confirm=$(echo -e "Yes\nNo" | rofi -dmenu -i -p "Logout? This will close all applications")
        if [[ $confirm == "Yes" ]]; then
            awesome-client "awesome.quit()"
        fi
        ;;
    "Reboot")
        confirm=$(echo -e "Yes\nNo" | rofi -dmenu -i -p "Reboot system?")
        if [[ $confirm == "Yes" ]]; then
            systemctl reboot
        fi
        ;;
    "Shutdown")
        confirm=$(echo -e "Yes\nNo" | rofi -dmenu -i -p "Shutdown system?")
        if [[ $confirm == "Yes" ]]; then
            systemctl poweroff
        fi
        ;;
esac
