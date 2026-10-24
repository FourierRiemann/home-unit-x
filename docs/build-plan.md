# home-unit-x – Build plan

Each phase has a goal and a "done when" check. Finish one phase before starting the next.

## Phase 0 – Order and prepare

- [x] Order the M720q (i5-8500T, 16 GB, 512 GB)
- [x] Ethernet cable long enough to reach the router
- [x] USB stick (32 GB) for the Ubuntu installer
- [x] Copy the 42 GB on the existing 2 TB drive to the Mac and verify the copy. The drive is reused as the data drive for now
- [x] Borrow a monitor (DisplayPort/HDMI) and USB keyboard
- [ ] Later: buy a new data drive and keep the 2 TB drive as a backup

**Done when:** all hardware is available.

## Phase 1 – Repo and Mac test (skipped)

Skipped: the M720q is ordered. Only the repo files are needed (without `setup-macos.sh`).

- [x] Create repo files: `docker-compose.yml`, `.env.example`, `.gitignore`, `scripts/setup-ubuntu.sh`
- [x] Push to GitHub
- [ ] On the MacBook: install OrbStack, clone the repo, `cp .env.example .env`, set `DATA_PATH`
- [ ] `docker compose up -d` and set up Jellyfin with a few test files
- [ ] Install Tailscale on the MacBook and phone, then stream from the phone

**Done when:** Jellyfin plays a video on the phone over Tailscale.
Expected: CPU-only transcoding on the Mac. This is not representative of the M720q.

## Phase 2 – Install Ubuntu Server

- [x] Flash Ubuntu Server 24.04 LTS to the USB stick (Raspberry Pi Imager or `dd`; balenaEtcher failed on macOS)
- [x] Keep the external drive **unplugged** during the install
- [x] BIOS (F1 at boot): check for a BIOS password or Computrace lock, set "After Power Loss" to **Power On**, and boot from USB (F12 boot menu)
- [x] Install to the internal SSD: set a hostname (e.g. `home-unit-x`) and username, enable **OpenSSH**, and skip featured snaps
- [x] Remove the USB stick when prompted, then reboot
- [x] Check that the root filesystem uses the whole SSD (`df -h /`)
- [x] Remove the monitor and keyboard and connect with `ssh <user>@home-unit-x.local`

Note: `.local` names only work after the setup script installs `avahi-daemon`; use the IP address until then. If the password isn't accepted, reset it in recovery mode: GRUB menu (Esc once at boot) → Advanced options → recovery mode → root → `mount -o remount,rw /` → `passwd <user>`.

**Done when:** you can SSH into the server from the Mac.

## Phase 3 – Base system

- [x] `sudo apt update && sudo apt full-upgrade -y`
- [x] Reserve a fixed IP address for the server in the router (Asus: Advanced Settings → LAN → DHCP Server → Manual Assignment)
- [x] Copy your SSH key (`ssh-copy-id`)
- [x] Disable SSH password login: `echo "PasswordAuthentication no" | sudo tee /etc/ssh/sshd_config.d/10-no-password.conf && sudo systemctl restart ssh`
- [ ] Enable automatic security updates (`unattended-upgrades`, done by the setup script)
- [ ] Set the timezone (done by the setup script)

**Done when:** you can log in with your SSH key only, and the server keeps the same IP address after a reboot.

## Phase 4 – Storage

- [x] Connect the external drive to a rear USB port (Seagate Expansion 2 TB, `/dev/sda`)
- [ ] Check its health: `sudo smartctl -H -d sat /dev/sda`
- [x] Format it to ext4: `wipefs`, `parted` (GPT), `mkfs.ext4 -L data -m 1 /dev/sda1`
- [x] Mount it at `/mnt/data` with its UUID and `nofail` in `/etc/fstab`
- [x] Reboot and check `df -h /mnt/data`
- [ ] Create the folders: `media/{movies,tv,music}`, `photos`, `nextcloud`, `games` (done by the setup script)

**Done when:** the drive mounts automatically at `/mnt/data` after a reboot.

## Phase 5 – Core services

- [x] Run `scripts/setup-ubuntu.sh` to install Docker, Tailscale and Samba
- [x] `sudo tailscale up` and add the server to your tailnet
- [x] Tailscale admin console: **Disable key expiry** for `home-unit-x`
- [x] Set up the Samba share for `/mnt/data` and connect from Finder (`smb://home-unit-x.local/data`)
- [x] Set up Jellyfin with `/dev/dri` passed through. In Jellyfin, choose **Intel QuickSync (QSV)** hardware acceleration (verified with `sudo intel_gpu_top`)
- [x] Create Jellyfin libraries (`/media/movies`, `/media/tv`, `/media/music`) and users
- [x] Test playback with a legal test video (Big Buck Bunny; the Blender download was a ZIP, so unzip it first)
- [x] Remote playback over Tailscale on the iPhone (mobile data)
- [ ] Later: copy the 42 GB backup from the Mac back to the drive
- [ ] Later: fix the Ethernet link. It runs at 100 Mbit/s instead of 1000 (`cat /sys/class/net/e*/speed`), which caps internet at ~92/92 and LAN copies at ~11 MB/s. Try a Cat5e/Cat6 cable, another router LAN port, and a direct connection; then re-run `speedtest-cli`

**Done when:**
- Copying a file from the Mac via Finder works.
- Jellyfin plays a video on a TV or phone.
- A forced transcode shows hardware acceleration in Jellyfin's dashboard.
- Remote playback works over Tailscale on mobile data.

## Phase 6 – Ad blocking

- [ ] Add AdGuard Home to Docker Compose. Port 53 conflicts with `systemd-resolved`, so turn off its stub listener
- [ ] Point the router's DNS to the server's IP address
- [ ] Optional: use it as the DNS for your Tailscale network too

**Done when:** ads are blocked on devices on the home Wi-Fi, and the internet still works if the server is restarted. Keep a fallback DNS in the router, or know how to revert.

## Phase 7 – More apps (pick as needed)

- [ ] Immich for phone photo backup
- [ ] Nextcloud for personal cloud storage
- [ ] RomM for retro games
- [ ] Home Assistant, plus a Zigbee USB adapter on an extension cable

**Done when:** each app works locally and via Tailscale, and its data is under `/mnt/data` or the config path.

## Phase 8 – Backups

- [ ] Choose an offsite target: Hetzner Storage Box, Backblaze B2, or a drive at a relative's house
- [ ] Set up Restic or Kopia for `photos/`, `nextcloud/` and the app config folders
- [ ] Schedule nightly backups and enable alerts when one fails
- [ ] **Test a restore**

**Done when:** a file restored from backup matches the original.

## Phase 9 – Storage upgrade

- [ ] Buy a 2-bay USB enclosure and 2× CMR NAS drives
- [ ] Set the enclosure to JBOD and create a mirror (mdadm or Btrfs RAID1)
- [ ] `docker compose down`
- [ ] Copy the data: `rsync -aHAX --info=progress2 /mnt/data/ /mnt/newdata/`
- [ ] Mount the new storage at `/mnt/data` instead, then `docker compose up -d`

**Done when:** all apps work from the new storage, and the old drive can be kept as an extra backup.

## Phase 10 – VPN and torrenting

Provider: **Proton VPN Plus** (P2P + port forwarding).

- [x] Sign up for Proton VPN Plus
- [x] account.protonvpn.com → Downloads → WireGuard configuration: platform GNU/Linux, **NAT-PMP (Port Forwarding) on**, a P2P server → copy the `PrivateKey`
- [x] On the server: `git pull`, then add to `.env`: `WIREGUARD_PRIVATE_KEY=...` and `VPN_SERVER_COUNTRIES=...`
- [x] `mkdir -p /mnt/data/downloads` (needs `sudo` + `chown` if `/mnt/data` is owned by root)
- [x] `docker compose --profile torrent up -d`, then check `docker compose logs gluetun` for a public IP and a forwarded port
- [x] qBittorrent web UI at `http://home-unit-x:8081`: user `admin`, temporary password from `docker compose logs qbittorrent`. Change the password
- [x] qBittorrent → Options → Web UI: enable **Bypass authentication for clients on localhost** (lets Gluetun set the port; verify the latest "port forwarded" in `docker compose logs gluetun` matches Options → Connection)
- [x] qBittorrent → Options → Downloads: default save path `/downloads`
- [x] Verify the VPN: `docker exec gluetun wget -qO- https://ipinfo.io` shows a Proton IP, not the home IP
- [x] Verify the kill switch: `docker stop gluetun` and check that qBittorrent loses its connection, then `docker start gluetun` (and `docker restart qbittorrent` once gluetun is healthy)
- [ ] Optional: Proton VPN app on Mac/phone/TV (or Asus VPN Fusion) for streaming via another country

**Done when:** qBittorrent downloads only through Proton, with a forwarded port, and stops when the VPN is down.
