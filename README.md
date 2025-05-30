# SSH Bastion Host, Jump host (+Interactive Menu)

This is a bastion SSH server Docker image that allows you to securely connect to remote servers. It creates two users (`menu` and `bastion`) to handle SSH connections and use the bastion as a jump point. The `menu` user provides a selectable menu to choose which remote server to connect to, while the `bastion` user is restricted and only allowed to forward SSH connections.

![Demo of menu user](https://i.imgur.com/mkThWpG.png "Demo of menu user")

## Features

- `menu` user provides an interactive menu for connecting to remote servers.
- `bastion` user acts as a jump point, securely forwarding SSH connections.
- SSH keys are persisted across restarts in `/bastion_data` volume.
- `/bastion_data` can be configured to manage SSH keys and server information.

## File Structure

![File Structure](https://i.imgur.com/tZvBJYT.png "File Structure")

When running this Docker image, you'll need to mount a volume (`/bastion_data`) from the host that contains configuration and key data. The file structure is as follows:

```bash
/bastion_data/
    ├── authorized_keys       # Public keys allowed to authenticate for both users
    ├── menu_ssh_key          # Private key for the 'menu' user (generated if missing)
    ├── menu_ssh_key.pub      # Public key for the 'menu' user (generated if missing)
    ├── servers.conf          # List of servers the 'menu' user can connect to (format below)
    ├── ssh_keys/             # Optional: Persistent SSH host keys (auto-generated if missing)
```

### Example `servers.conf`

The `servers.conf` file defines the list of remote servers that the `menu` user can connect to. Each line follows this format:

```bash
[ssh_user]@[server_alias] [server_ip]
```

Example:

```bash
tackle@d01 192.168.1.2
tackle@d02 192.168.1.3
tackle@d03 192.168.1.4
```

### Authorized Keys

The `authorized_keys` file in `/bastion_data/authorized_keys` contains the public SSH keys that are allowed to authenticate for both the `bastion` and `menu` users.

You can add public keys like this:

```bash
ssh-rsa AAAAB3Nza... user@domain
```

## How to Build and Run

### Pull the Image

To pull the image from Docker Hub:

```bash
docker pull tackleza/bastion:debian
```

### Running the Container

To run the container, you must mount the `/bastion_data` volume from your host to store SSH keys, configuration, and authorized keys. Use the following command:

```bash
docker run -d \
  -v $(pwd)/bastion_data:/bastion_data \
  -p 2222:22 \
  tackleza/bastion:debian
```
This will expose the SSH server on port 2222 and mount the bastion_data folder from your current directory to the container.

### Configuration

1. **Authorized Keys**: Place the public keys you want to allow into the `/bastion_data/authorized_keys` file.
   
2. **Server Configuration**: Modify the `/bastion_data/servers.conf` file to define the remote servers the `menu` user can connect to.

3. **SSH Host Keys**: Host keys for the SSH server are auto-generated and saved in `/bastion_data/ssh_keys` if not already present.

## Using the Container

### SSH as `menu` User

To log in as the `menu` user, run the following command:

```bash
ssh menu@<host-ip> -p 2222
```
You will be prompted with a menu to select a server to connect to. The menu will list the servers defined in the servers.conf file.

### SSH as `bastion` User (Jump Point)

To log in as the `bastion` user (restricted), run the following command:

```bash
ssh bastion@<host-ip> -p 2222
```
The bastion user is restricted from accessing a shell, but can be used as a jump point for SSH forwarding:
```bash
ssh -J bastion@<host-ip>:2222 remote_user@remote_ip
# OR use alias name that defined in server.conf
ssh -J bastion@<host-ip>:2222 tackle@d01
```
## Important Notes

- Both the `menu` and `bastion` users share the same `authorized_keys` file stored in `/bastion_data/authorized_keys`.
- The SSH keys for the `menu` user are stored in `/bastion_data/menu_ssh_key` and `/bastion_data/menu_ssh_key.pub`.
- If the keys don't exist on the first run, they will be automatically generated and saved in `/bastion_data`.

### Disclaimer

This Docker image was built as a hobby project with security in mind, but it comes with no warranty. If you have concerns about security or require a production-grade solution, please refrain from using it. Use at your own risk.