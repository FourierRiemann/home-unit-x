# home-unit-x – Build plan

Each phase has a goal and a "done when" check. Finish one phase before starting the next.

## Phase 0 – Order and prepare

- [x] Order the M720q (i5-8500T, 16 GB, 512 GB)
- [ ] Ethernet cable long enough to reach the router
- [ ] USB stick (8 GB or larger)
- [ ] Borrow a monitor (DisplayPort/HDMI) and USB keyboard
- [ ] Back up any existing files on the 1–2 TB external drive

**Done when:** all hardware is available.

## Phase 1 – Repo and Mac test (skipped)

Skipped: the M720q is ordered. Only the repo files are needed (without `setup-macos.sh`).

- [ ] Create repo files: `docker-compose.yml`, `.env.example`, `.gitignore`, `scripts/setup-macos.sh`, `scripts/setup-ubuntu.sh`
- [ ] Push to GitHub
- [ ] On the MacBook: install OrbStack, clone the repo, `cp .env.example .env`, set `DATA_PATH`
- [ ] `docker compose up -d` and set up Jellyfin with a few test files
- [ ] Install Tailscale on the MacBook and phone, then stream from the phone

**Done when:** Jellyfin plays a video on the phone over Tailscale.
Expected: CPU-only transcoding on the Mac. This is not representative of the M720q.

## Phase 2 – Install Ubuntu Server

- [ ] Flash Ubuntu Server LTS to the USB stick (Raspberry Pi Imager or balenaEtcher)
- [ ] BIOS (F1 at boot): check for a BIOS password or Computrace lock, set "After Power Loss" to **Power On**, and boot from USB
- [ ] Install to the internal SSD: set a hostname (e.g. `home-unit-x`) and username, and enable **OpenSSH**
- [ ] Remove the monitor and keyboard and connect with `ssh <user>@home-unit-x.local`

**Done when:** you can SSH into the server from the Mac.

## Phase 3 – Base system

- [ ] `sudo apt update && sudo apt full-upgrade -y`
- [ ] Reserve a fixed IP address for the server in the router (DHCP reservation)
- [ ] Copy your SSH key (`ssh-copy-id`), then disable SSH password login
- [ ] Enable automatic security updates (`unattended-upgrades`)
- [ ] Set the timezone: `sudo timedatectl set-timezone Europe/Stockholm`

**Done when:** you can log in with your SSH key only, and the server keeps the same IP address after a reboot.

## Phase 4 – Storage

- [ ] Connect the external drive to a rear USB port
- [ ] Check its health: `sudo smartctl -a /dev/sdX`
- [ ] Format it to ext4 (this erases the drive), or keep the existing filesystem
- [ ] Mount it at `/mnt/data` with its UUID and `nofail` in `/etc/fstab`
- [ ] Create the folders: `media/{movies,tv,music}`, `photos`, `nextcloud`, `games`

**Done when:** the drive mounts automatically at `/mnt/data` after a reboot.

## Phase 5 – Core services

- [ ] Run `scripts/setup-ubuntu.sh` to install Docker, Tailscale and Samba
- [ ] `sudo tailscale up` and add the server to your tailnet
- [ ] Set up the Samba share for `/mnt/data` and connect from Finder (`smb://home-unit-x.local`)
- [ ] Set up Jellyfin with `/dev/dri` passed through. In Jellyfin, choose **Intel QuickSync (QSV)** hardware acceleration
- [ ] Create Jellyfin libraries and users

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

## Phase 10 – VPN (decide later)

- [ ] Choose Mullvad (paid) or Proton VPN Free
- [ ] Install the VPN app on each device. Optional: the Tailscale Mullvad add-on
