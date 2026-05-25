# Pavlov Shack Dedicated Server (Docker)

Self-host a Pavlov Shack (Meta Quest) server using Docker. Works on any Linux VPS.

## Requirements

- Linux VPS (Ubuntu 22.04 recommended) — 2GB+ RAM, 10GB+ disk
- Docker installed
- Ports open: `7777 UDP`, `8177 UDP`, `9100 TCP`

## 1. Install Docker

```bash
curl -sSL https://get.docker.com/ | CHANNEL=stable bash
```

## 2. Create the server folder

```bash
mkdir -p ~/pavlov-shack/Saved/Config/LinuxServer
chown -R 999:999 ~/pavlov-shack/Saved
```

## 3. Create docker-compose.yml

```bash
nano ~/pavlov-shack/docker-compose.yml
```

Paste this:

```yaml
services:
  pavlov-shack:
    image: ghcr.io/bkhornyt/pavlov-shack-server-guide:latest
    container_name: pavlov-shack
    restart: unless-stopped
    environment:
      - TZ=America/New_York
      - PUID=999
      - PGID=999
    ports:
      - 7777:7777/udp
      - 8177:8177/udp
      - 9100:9100/tcp
    volumes:
      - ./Saved:/usr/src/pavlovserver/Pavlov/Saved/
      - pavlov-install:/usr/src/pavlovserver

volumes:
  pavlov-install:
```

> Change `TZ` to your timezone. See [timezone list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).

The image is a patched wrapper around the upstream Pavlov Shack Docker image with a required `libc++` fix applied — no manual steps needed.

## 4. Configure Game.ini

```bash
nano ~/pavlov-shack/Saved/Config/LinuxServer/Game.ini
```

```ini
[/Script/Pavlov.DedicatedServer]
bEnabled=true
ServerName=My Shack Server
MaxPlayers=10
bSecured=true
bCustomServer=true
bVerboseLogging=false
bCompetitive=false
bWhitelist=false
RefreshListTime=120
TimeLimit=60
Password=
MapRotation=(MapId="datacenter", GameMode="SND")
MapRotation=(MapId="sand", GameMode="TDM")
MapRotation=(MapId="bridge", GameMode="TDM")
```

> To add a custom map from mod.io, add: `MapRotation=(MapId="UGC1234567", GameMode="CUSTOM")`

## 5. Configure RCON (optional)

```bash
printf 'Password=YourRconPasswordHere\nPort=9100\n' > ~/pavlov-shack/Saved/Config/RconSettings.txt
```

> RCON lets you manage the server remotely. Connect with any RCON client to your server IP on port 9100.
>
> **Important:** Use `printf` as shown above rather than a text editor — the file must use Unix line endings (LF only). Windows-style line endings (CRLF) will cause Pavlov to misread the password.

## 6. Add yourself as admin (optional)

```bash
nano ~/pavlov-shack/Saved/Config/mods.txt
```

Add your Quest username (one per line):
```
YourQuestUsername
```

## 7. Open firewall ports

```bash
sudo ufw allow 7777/udp
sudo ufw allow 8177/udp
sudo ufw allow 9100/tcp
sudo ufw allow 22/tcp
sudo ufw enable
```

## 8. Start the server

```bash
cd ~/pavlov-shack && docker compose up -d
```

First start downloads Pavlov (~4GB) — takes a few minutes. Check progress:

```bash
docker logs -f pavlov-shack
```

When you see `Waiting for players` in the logs, the server is up.

## Finding the server in-game

Open Pavlov Shack → **Multiplayer** → **Community Servers** → search your server name.

## Useful commands

```bash
# View live logs
docker logs -f pavlov-shack

# Restart server (also updates Pavlov)
docker compose -f ~/pavlov-shack/docker-compose.yml restart

# Stop server
docker compose -f ~/pavlov-shack/docker-compose.yml down
```

## Connecting to RCON

Once your server is running with RCON configured, you can manage it from your browser using **[pavlovrcon.com](https://pavlovrcon.com/)** — no software to install.

1. Go to [pavlovrcon.com](https://pavlovrcon.com/)
2. Enter your server IP, port (`9100`), and RCON password
3. You can now run commands, switch maps, kick/ban players, and more

## RCON commands

| Command | Description |
|---|---|
| `SwitchMap [MapId] [GameMode]` | Switch to a map (e.g. `SwitchMap sand TDM`) |
| `RefreshList` | Refresh player list |
| `Kick [username]` | Kick a player |
| `Ban [username]` | Ban a player |
| `GiveItem [username] [ItemID]` | Give a player an item |

## Default map IDs

| Map | ID |
|---|---|
| Datacenter | `datacenter` |
| Sand | `sand` |
| Bridge | `bridge` |
| Container Yard | `containeryard` |
| Killhouse | `killhouse` |
| Santorini | `santorini` |
| Industry | `industry` |
| OG Containers (Shack only) | `ogcontainers` |
| Foundation (Shack only) | `foundation` |

Custom maps use their mod.io resource ID prefixed with `UGC` (e.g. `UGC2804322`).
