# home-unit-x – Useful commands

Replace `<user>` with your username. Commands starting with `sudo` run as admin and ask for your password.

## Connect from the Mac

| Command | What it does |
|---|---|
| `ssh home-unit-x` | Log in to the server (shortcut from `~/.ssh/config`) |
| `ssh <user>@home-unit-x.local` | Log in to the server |
| `ssh <user>@192.168.x.x` | Log in using the IP address if `.local` doesn't work |
| `exit` | Log out (back to the Mac) |
| `scp file.mkv <user>@home-unit-x.local:/mnt/data/media/movies/` | Copy a file from the Mac to the server |
| `rsync -ah --progress folder/ <user>@home-unit-x.local:/mnt/data/media/movies/folder/` | Copy a folder; can resume if interrupted |

## Getting around

| Command | What it does |
|---|---|
| `pwd` | Show which folder you're in |
| `ls` / `ls -lah` | List files / with sizes, permissions and hidden files |
| `cd /mnt/data` | Go to a folder |
| `cd ..` / `cd ~` / `cd -` | Up one level / home folder / previous folder |
| `Tab` | Auto-complete file and folder names |
| `↑` / `↓` | Previous commands |
| `Ctrl+C` | Stop the running command |
| `Ctrl+R` | Search command history |
| `clear` | Clear the screen |

## Files and folders

| Command | What it does |
|---|---|
| `mkdir -p media/movies` | Create a folder (and parent folders) |
| `cp file.txt copy.txt` | Copy a file (`cp -r` for folders) |
| `mv old.txt new.txt` | Move or rename |
| `rm file.txt` | Delete a file. **No trash, it's gone for good** |
| `rm -r folder` | Delete a folder and everything in it. **Double-check the path first** |
| `cat file.txt` | Print a file |
| `less file.txt` | Read a long file (`q` to quit, `/` to search) |
| `nano file.txt` | Edit a file (`Ctrl+O` save, `Ctrl+X` exit) |
| `sudo nano /etc/fstab` | Edit a system file |
| `find /mnt/data -name "*.mkv"` | Find files by name |
| `du -sh /mnt/data/*` | Size of each folder |

## System status

| Command | What it does |
|---|---|
| `htop` | Live CPU, memory and processes (`q` to quit) |
| `df -h` | Free disk space |
| `free -h` | Memory usage |
| `hostname -I` | The server's IP address |
| `uptime` | How long it has been running, and load |
| `lsblk -f` | List drives, partitions and filesystems |
| `sudo smartctl -a /dev/sda` | Drive health (look for `PASSED` and reallocated sectors) |
| `sudo intel_gpu_top` | Quick Sync activity during a Jellyfin transcode |

## Updates and software

| Command | What it does |
|---|---|
| `sudo apt update && sudo apt upgrade -y` | Install updates |
| `sudo apt install <package>` | Install a program |
| `sudo apt remove <package>` | Remove a program |
| `cat /var/run/reboot-required` | Shows a message if a reboot is needed after updates |

## Services (programs running in the background)

| Command | What it does |
|---|---|
| `systemctl status smbd` | Is Samba running? (`q` to quit) |
| `sudo systemctl restart smbd` | Restart a service |
| `sudo systemctl enable --now <service>` | Start now and at every boot |
| `journalctl -u smbd -n 50` | Last 50 log lines for a service |
| `journalctl -f` | Follow the system log live (`Ctrl+C` to stop) |

## Docker (run in the repo folder: `cd ~/home-unit-x`)

| Command | What it does |
|---|---|
| `docker compose up -d` | Start the apps in the background |
| `docker compose --profile adblock up -d` | Also start an optional app |
| `docker compose ps` | Which apps are running |
| `docker compose logs -f jellyfin` | Follow an app's log (`Ctrl+C` to stop) |
| `docker compose restart jellyfin` | Restart one app |
| `docker compose down` | Stop all apps (data is kept) |
| `docker compose pull && docker compose up -d` | Update apps to the latest version |
| `docker image prune` | Delete old, unused app versions |
| `docker stats` | Live CPU and memory per app |

## Git (updating the setup files)

| Command | What it does |
|---|---|
| `git clone <repo-url>` | Download the repo the first time |
| `git pull` | Get the latest changes from GitHub |
| `git status` | Show changed files |

## Tailscale

| Command | What it does |
|---|---|
| `sudo tailscale up` | Connect the server to your Tailscale network |
| `tailscale status` | Devices in your network and their IPs |
| `tailscale ip -4` | The server's Tailscale IP |

## Power

| Command | What it does |
|---|---|
| `sudo reboot` | Restart |
| `sudo shutdown now` | Shut down (press the power button to start again) |

## Getting help

| Command | What it does |
|---|---|
| `man <command>` | Manual for a command (`q` to quit) |
| `<command> --help` | Short help |
| `history` | Commands you've run before |
| `sudo !!` | Re-run the last command with sudo (when you forgot it) |

## Safety tips

- Read a command before pressing Enter, especially with `sudo`, `rm` or anything under `/dev/`.
- Before editing a system file, make a copy: `sudo cp /etc/fstab /etc/fstab.bak`.
- If something hangs, press `Ctrl+C`. If the SSH session freezes, close the Mac terminal tab and reconnect.
