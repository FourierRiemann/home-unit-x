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
- [ ] Push to GitHub
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

- [ ] Connect the external drive to a rear USB port
- [ ] Check its health: `sudo smartctl -a /dev/sdX`
- [ ] Format it to ext4 (this erases the installer)
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
