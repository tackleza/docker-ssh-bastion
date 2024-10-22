#!/bin/bash

# Read the servers.conf file
if [ ! -f /bastion_data/servers.conf ]; then
  echo "/bastion_data/servers.conf file not found!"
  exit 1
fi

# Build a list of servers for dialog
menu_items=()
while IFS='@ ' read -r ssh_user server_name server_ip; do
    if [ -n "$server_ip" ]; then
        menu_items+=("$server_name" "$server_ip")
    fi
done < /bastion_data/servers.conf

# Use dialog to present a menu to the user
chosen_server=$(dialog --clear --stdout --menu "Select a server to connect to:" 15 40 8 "${menu_items[@]}")

# If the user pressed cancel or no option was selected
if [ $? -ne 0 ]; then
    clear
    echo "No server selected, exiting."
    exit 1
fi

# Find the selected server's SSH user and server alias from servers.conf
ssh_user=$(grep "^.*@$chosen_server " /bastion_data/servers.conf | awk '{print $1}' | cut -d'@' -f1)

# If no SSH user was found for the selected server
if [ -z "$ssh_user" ]; then
  echo "SSH user not found for the selected server!"
  exit 1
fi

# Clear the screen before connecting
clear

# Connect to the selected server using the alias (server_name)
ssh "$ssh_user@$chosen_server"
