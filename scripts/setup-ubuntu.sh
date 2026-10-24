#!/usr/bin/env bash
# Sets up home-unit-x on Ubuntu Server: Docker, Tailscale, Samba, folders and .env.
# Run from the cloned repo as your normal user (not root). Safe to run again.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DATA_PATH="/mnt/data"
CONFIG_PATH="/opt/home-unit-x/config"
SMB_SHARE="data"

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m!! %s\033[0m\n' "$*"; }

if [[ $EUID -eq 0 ]]; then
  echo "Run as your normal user; the script uses sudo where needed." >&2
  exit 1
fi

log "Updating system and installing base packages"
sudo apt-get update
sudo apt-get full-upgrade -y
sudo apt-get install -y ca-certificates curl smartmontools samba avahi-daemon \
  unattended-upgrades intel-gpu-tools
sudo timedatectl set-timezone Europe/Stockholm
sudo dpkg-reconfigure -f noninteractive unattended-upgrades

log "Installing Docker"
if ! command -v docker >/dev/null; then
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi
sudo usermod -aG docker "$USER"

log "Installing Tailscale"
if ! command -v tailscale >/dev/null; then
  curl -fsSL https://tailscale.com/install.sh | sh
fi

log "Checking data drive at $DATA_PATH"
if mountpoint -q "$DATA_PATH"; then
  sudo mkdir -p "$DATA_PATH"/media/{movies,tv,music} "$DATA_PATH"/{photos,nextcloud,games}
  sudo chown "$USER:$USER" "$DATA_PATH" "$DATA_PATH"/{media,photos,nextcloud,games} "$DATA_PATH"/media/*
else
  # Avoid filling the internal SSD with files meant for the external drive
  warn "$DATA_PATH is not mounted. Skipping data folders; mount the drive (Phase 4) and re-run."
fi

log "Creating config folder $CONFIG_PATH"
sudo mkdir -p "$CONFIG_PATH"
# Docker would otherwise create missing bind-mount folders as root, which Jellyfin can't write to
sudo mkdir -p "$CONFIG_PATH"/jellyfin/{config,cache}
sudo chown "$USER:$USER" "$CONFIG_PATH" "$(dirname "$CONFIG_PATH")"
sudo chown -R "$USER:$USER" "$CONFIG_PATH"/jellyfin

log "Configuring Samba share [$SMB_SHARE]"
if ! grep -q "^\[$SMB_SHARE\]" /etc/samba/smb.conf; then
  sudo tee -a /etc/samba/smb.conf >/dev/null <<EOF

[$SMB_SHARE]
   path = $DATA_PATH
   read only = no
   valid users = $USER
   force user = $USER
   create mask = 0664
   directory mask = 0775
   vfs objects = fruit streams_xattr
   fruit:metadata = stream
   fruit:model = MacSamba
EOF
fi
if ! sudo pdbedit -L | grep -q "^$USER:"; then
  echo "Choose a Samba password (used when connecting from Finder):"
  sudo smbpasswd -a "$USER"
fi
sudo systemctl restart smbd

log "Creating .env"
ENV_FILE="$REPO_DIR/.env"
if [[ ! -f $ENV_FILE ]]; then
  cp "$REPO_DIR/.env.example" "$ENV_FILE"
  RENDER_GID="$(getent group render | cut -d: -f3 || true)"
  sed -i \
    -e "s/^PUID=.*/PUID=$(id -u)/" \
    -e "s/^PGID=.*/PGID=$(id -g)/" \
    -e "s|^DATA_PATH=.*|DATA_PATH=$DATA_PATH|" \
    -e "s|^CONFIG_PATH=.*|CONFIG_PATH=$CONFIG_PATH|" \
    "$ENV_FILE"
  if [[ -n $RENDER_GID ]]; then
    sed -i "s/^RENDER_GID=.*/RENDER_GID=$RENDER_GID/" "$ENV_FILE"
  else
    warn "No 'render' group found; Quick Sync may not be available. Check: ls -l /dev/dri"
  fi
else
  echo ".env already exists, leaving it unchanged."
fi

log "Done. Next steps"
cat <<EOF
1. Log out and back in (so the docker group applies).
2. Connect to Tailscale:        sudo tailscale up
3. Start Jellyfin:              cd $REPO_DIR && docker compose up -d
4. Jellyfin web UI:             http://$(hostname).local:8096
   Dashboard > Playback > Transcoding > Intel QuickSync (QSV)
5. From the Mac (Finder, Cmd+K): smb://$(hostname).local/$SMB_SHARE
EOF
