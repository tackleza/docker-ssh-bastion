# SSH Bastion Host — Jump Box with Interactive Menu

A Docker image for a secure SSH bastion/jump host. Two user accounts are provided:

- **`menu`** — interactive menu to select and connect to remote servers
- **`bastion`** — restricted jump point for SSH connection forwarding only

![Demo of menu user](https://i.imgur.com/mkThWpG.png "Demo of menu user")

## Features

- `menu` user with an interactive menu for connecting to remote servers
- `bastion` user for secure SSH forwarding (no shell access)
- SSH keys persist across restarts via `/bastion_data` volume
- Auto-generates keys on first run if not present

## File Structure

Mount a volume from your host to `/bastion_data`. Required structure:

```
/bastion_data/
    ├── authorized_keys       # Public keys allowed for both users
    ├── menu_ssh_key          # Private key for 'menu' user (auto-generated)
    ├── menu_ssh_key.pub      # Public key for 'menu' user (auto-generated)
    ├── servers.conf          # Servers 'menu' user can connect to
    ├── ssh_keys/             # SSH host keys (auto-generated)
```

### `servers.conf` Format

```
[ssh_user]@[alias] [ip_or_hostname]
```

Example:

```
tackle@d01 192.168.1.2
tackle@d02 192.168.1.3
tackle@d03 192.168.1.4
```

### `authorized_keys`

Add public SSH keys (one per line):

```
ssh-rsa AAAAB3Nza... user@domain
```

## Quick Start

### Pull the Image

```bash
docker pull tackleza/bastion:debian
```

### Run the Container

```bash
docker run -d \
  -v $(pwd)/bastion_data:/bastion_data \
  -p 2222:22 \
  tackleza/bastion:debian
```

SSH is exposed on port 2222. The `bastion_data` directory is created automatically on first run.

## Usage

### Connect as `menu` User

```bash
ssh menu@<host-ip> -p 2222
```

You'll see a menu of available servers from `servers.conf`.

### Connect as `bastion` User (Jump Point)

```bash
ssh bastion@<host-ip> -p 2222
```

Use as a jump host for SSH forwarding:

```bash
# By IP
ssh -J bastion@<host-ip>:2222 remote_user@remote_ip

# By alias (from servers.conf)
ssh -J bastion@<host-ip>:2222 tackle@d01
```

## Configuration

| File | Description |
|------|-------------|
| `authorized_keys` | Public keys allowed for both `menu` and `bastion` users |
| `servers.conf` | Remote servers available to the `menu` user |
| `ssh_keys/` | SSH host keys — auto-generated if missing |

## Notes

- Both `menu` and `bastion` users share the same `authorized_keys` file
- SSH keys for `menu` are stored in `menu_ssh_key` and `menu_ssh_key.pub`
- Keys are auto-generated on first run if not present

## Disclaimer

Built as a hobby project with security in mind. No warranty is provided. For production use, evaluate your security requirements carefully.
