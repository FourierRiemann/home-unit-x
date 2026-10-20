# home-unit-x – Overview

A small home server for media streaming, file storage, remote access and, later, cloud storage, smart home and more.

## Hardware

- **Lenovo ThinkCentre M720q Tiny** (refurbed.se, 3 265 kr)
  - Intel Core i5-8500T (6 cores), Intel UHD 630 with Quick Sync
  - 16 GB RAM, 512 GB SSD
  - Gigabit Ethernet, no Wi-Fi (connected by cable to the router)
  - Power adapter included
- **For the first install:** USB stick (8 GB or larger), borrowed monitor and keyboard
- **To ask the seller (optional):** RAM 2×8 or 1×16 GB, SSD NVMe or SATA, warranty length

## Storage

| Phase | Plan |
|---|---|
| Start | Existing 1–2 TB external drive mounted at `/mnt/data`. Check its health, reformat to ext4 if possible, and never keep the only copy of important files on it. |
| Later | 2-bay USB enclosure (e.g. TerraMaster D2-320) with 2× CMR NAS drives (WD Red Plus / IronWolf / N300, 8 TB or larger), mirrored with mdadm or Btrfs RAID1. Move data with rsync and keep the same mount path. |
| Backup | Offsite backup of photos and documents only (Hetzner Storage Box or Backblaze B2, using Restic or Kopia). |
| Internal SSD | OS, Docker, app databases and config. |

Data layout:

```
/mnt/data/
├── media/{movies,tv,music}
├── photos/
├── nextcloud/
└── games/
```

## Software

- **OS:** Ubuntu Server LTS
- **Apps:** Docker Compose; all paths configured in `.env`

### Core

| App | Purpose |
|---|---|
| Jellyfin | Media streaming with Quick Sync hardware transcoding (free, chosen over Plex) |
| Samba | Network drive accessible from Finder |
| Tailscale | Secure remote access, no open router ports |

### Later, as needed

| App | Purpose |
|---|---|
| AdGuard Home | Ad and tracker blocking for the whole network |
| Nextcloud | Personal cloud storage |
| Immich | Photo and video backup |
| RomM | Retro games played in the browser |
| Home Assistant | Smart home (Zigbee USB adapter, IKEA bulbs and remotes to start) |

## Privacy and network security

- **Ad blocking:** AdGuard Home on the server
- **Hiding your IP:** VPN app on each device. Undecided: Mullvad (~€5/month, preferred) or Proton VPN Free (1 device, no P2P)
- **Public Wi-Fi:** optionally use a Tailscale exit node through home
- **Wi-Fi:** WPA3/WPA2-AES, router firmware kept up to date, guest network for IoT devices, no open ports

## Limitations

- UHD 630 has no AV1 hardware decoding; 4K HDR tone mapping handles about 1–2 streams
- Remote viewers are limited by home internet upload speed (~5–20 Mbit/s per 1080p stream)
- A single drive has no redundancy until the mirrored setup is in place
