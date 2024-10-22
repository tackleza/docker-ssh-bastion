#!/bin/bash

# Ensure the servers.conf file is in place with example content if needed
if [ ! -f /bastion_data/servers.conf ]; then
    echo "Creating default /bastion_data/servers.conf with example content"
    echo "tackle@d01 192.168.1.2" > /bastion_data/servers.conf
    echo "tackle@d02 192.168.1.3" >> /bastion_data/servers.conf
    echo "tackle@d03 192.168.1.4" >> /bastion_data/servers.conf
fi

# Read servers.conf and add entries to /etc/hosts
while IFS='@ ' read -r ssh_user server_name server_ip; do
    if [ -n "$server_ip" ]; then
        echo "$server_ip $server_name" >> /etc/hosts
    fi
done < /bastion_data/servers.conf

# Ensure authorized_keys file exists in /bastion_data
if [ ! -f /bastion_data/authorized_keys ]; then
    touch /bastion_data/authorized_keys
fi

# Check if the SSH key pair for "menu" user exists and generate it if needed
if [ ! -f /bastion_data/menu_ssh_key ] || [ ! -f /bastion_data/menu_ssh_key.pub ]; then
    echo "Generating SSH key pair for 'menu' user..."
    # Remove incomplete keys if they exist
    rm -rf /bastion_data/menu_ssh_key /bastion_data/menu_ssh_key.pub
    ssh-keygen -t rsa -b 2048 -f /bastion_data/menu_ssh_key -N ""
fi

# Copy the SSH key pair to the "menu" user's .ssh directory
mkdir -p /home/menu/.ssh
cp -rf /bastion_data/menu_ssh_key /home/menu/.ssh/id_rsa
cp -rf /bastion_data/menu_ssh_key.pub /home/menu/.ssh/id_rsa.pub

# Copy the authorized_keys file from /bastion_data for the "menu" user
cp -rf /bastion_data/authorized_keys /home/menu/.ssh/authorized_keys

# Set permissions for the "menu" user's SSH key and authorized_keys
chmod 700 /home/menu/.ssh
chmod 600 /home/menu/.ssh/id_rsa
chmod 644 /home/menu/.ssh/id_rsa.pub
chmod 600 /home/menu/.ssh/authorized_keys
chown -R menu:menu /home/menu/.ssh

# Create .ssh directory and authorized_keys for the "bastion" user
mkdir -p /home/bastion/.ssh
cp -rf /bastion_data/authorized_keys /home/bastion/.ssh/authorized_keys

# Set ownership and permissions for the "bastion" user
chown -R bastion:bastion /home/bastion/.ssh
chmod 700 /home/bastion/.ssh
chmod 600 /home/bastion/.ssh/authorized_keys

# Ensure correct permissions for the home directories
chmod 755 /home/menu
chmod 755 /home/bastion

# Start the SSH server
echo "Starting SSH server..."
exec /usr/sbin/sshd -D
