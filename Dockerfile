# Base image
FROM debian:bookworm-slim

# Install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    bash \
    dialog \
    && rm -rf /var/lib/apt/lists/*

# Create necessary users and directories
RUN adduser --disabled-password --gecos "" bastion && \
    adduser --disabled-password --gecos "" menu && \
    mkdir -p /bastion_data /var/run/sshd

# Set permissions for SSH directory
RUN chmod 0755 /var/run/sshd

# Setup SSH configuration
# Set up SSH configuration for bastion and menu users
RUN echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
    echo "AllowUsers bastion menu" >> /etc/ssh/sshd_config && \
    echo "AuthorizedKeysFile .ssh/authorized_keys" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "StrictModes yes" >> /etc/ssh/sshd_config && \
    echo "Match User bastion" >> /etc/ssh/sshd_config && \
    echo "    ForceCommand /bin/false" >> /etc/ssh/sshd_config && \
    echo "    PermitTTY no" >> /etc/ssh/sshd_config && \
    echo "    AllowTcpForwarding yes" >> /etc/ssh/sshd_config && \
    echo "    AllowAgentForwarding yes" >> /etc/ssh/sshd_config && \
    echo "    PermitOpen any" >> /etc/ssh/sshd_config && \
    echo "    PermitTunnel no" >> /etc/ssh/sshd_config && \
    echo "    X11Forwarding no" >> /etc/ssh/sshd_config && \
    echo "Match User menu" >> /etc/ssh/sshd_config && \
    echo "    ForceCommand /usr/local/bin/menu-script.sh" >> /etc/ssh/sshd_config



# Copy custom scripts to appropriate locations
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY menu-script.sh /usr/local/bin/menu-script.sh

# Make scripts executable
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/menu-script.sh

# Expose the SSH port
EXPOSE 22

# Configure entrypoint to start the SSH server
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
