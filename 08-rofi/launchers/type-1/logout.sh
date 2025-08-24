#!/bin/bash

# Rofi Power Menu Script
# Provides Lock, Logout, Reboot, Shutdown options with confirmations

# Define options
options="Lock\nLogout\nReboot\nShutdown"
dir="$HOME/.config/rofi/launchers/type-1"
theme='style-3'

# Show main menu
chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu" -theme ${dir}/${theme}.rasi)

case $chosen in
    "Lock")
        i3lock -c 1e1e2e
        ;;
    "Logout")
        confirm=$(echo -e "Yes\nNo" | rofi -dmenu -i -p "Logout? This will close all applications" -theme ${dir}/${theme}.rasi)
        if [[ $confirm == "Yes" ]]; then
            awesome-client "awesome.quit()"
        fi
        ;;
    "Reboot")
        confirm=$(echo -e "Yes\nNo" | rofi -dmenu -i -p "Reboot system?" -theme ${dir}/${theme}.rasi)
        if [[ $confirm == "Yes" ]]; then
            systemctl reboot
        fi
        ;;
    "Shutdown")
        confirm=$(echo -e "Yes\nNo" | rofi -dmenu -i -p "Shutdown system?" -theme ${dir}/${theme}.rasi)
        if [[ $confirm == "Yes" ]]; then
            systemctl poweroff
        fi
        ;;
esac
