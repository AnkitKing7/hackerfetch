<div align="center">

<img src="logos/hackerfetch-green.png" alt="HackerFetch" width="760">

```
 ╦ ╦╔═╗╔═╗╦╔═╔═╗╦═╗╔═╗╔═╗╔╦╗╔═╗╦ ╦
 ╠═╣╠═╣║  ╠╩╗║╣ ╠╦╝╠╣ ║╣  ║ ║  ╠═╣
 ╩ ╩╩ ╩╚═╝╩ ╩╚═╝╩╚═╚  ╚═╝ ╩ ╚═╝╩ ╩
```

**Hacker-style neofetch for Linux servers.**
Hard binary circle, 10 color themes, compact login banner, full system details. Pure Bash.

![shell](https://img.shields.io/badge/shell-bash-00ff00)
![themes](https://img.shields.io/badge/themes-10-00aaff)
![platform](https://img.shields.io/badge/platform-Debian%20%7C%20Ubuntu-ff0000)

**Powered by AnkitCoder**

</div>

---

## Table of contents

1. [Preview](#preview)
2. [Features](#features)
3. [Install](#install)
4. [Themes (colors)](#themes-colors)
5. [Usage](#usage)
6. [The hard circle](#the-hard-circle)
7. [Login banner (MOTD)](#login-banner-motd)
8. [Fields](#fields)
9. [`--full` sections](#--full-sections)
10. [Customization](#customization)
11. [Files](#files)
12. [Troubleshooting](#troubleshooting)
13. [Privacy](#privacy)
14. [Uninstall](#uninstall)
15. [License and credits](#license-and-credits)

---

## Preview

```
          ███████████           ┌─[root@myvps]─[10.0.0.5]
       ███▓▓▓01010▓▓▓███        ├─ os     Ubuntu 22.04.5 LTS
     ██▓▓0110111001011▓▓██      ├─ kernel 5.15.0 · up 21m
    ██▓11000011101011001▓██     ├─ cpu    ▰▱▱▱▱▱▱▱▱▱   5% 4c·0.05
   ██▓0000101100010111111▓██    ├─ ram    ▰▱▱▱▱▱▱▱▱▱   1% 219Mi/15Gi
   █▓000011╔═══════╗110010▓█    ├─ disk   ▰▱▱▱▱▱▱▱▱▱   6% 4.2G/77G
  ██▓001101║ root# ║011011▓██   ├─ net    eth0 ↓1.2G ↑340M
   █▓000100╚═══════╝111011▓█    ├─ pub-ip 203.0.113.7 Mumbai, IN
   ██▓0010011101001011111▓██    ├─ ports  5 open · fw active
    ██▓11100110001000011▓██     ├─ threat ssh-fail 12 · f2b on
     ██▓▓0100011011000▓▓██      ├─ docker 2/3 · updates 0 · failed 0
       ███▓▓▓00100▓▓▓███        ├─ login  root from 1.2.3.4
          ███████████           └─ time   10 Nov 23:14 IST [ONLINE]

   HACKERFETCH  v1.0 · green · Powered by AnkitCoder
```

Real colored screenshots for every theme are in `screenshots/`, and logos in `logos/`:

<div align="center">
<img src="logos/all-themes.png" alt="All themes" width="700">
</div>

---

## Features

| Area | What you get |
|---|---|
| **Design** | Hard circle made of live random binary (`0` `1`), thick ring, `root#` terminal box in the center, tree-style info (`├─ └─`), `[ONLINE]` status badge |
| **Colors** | 10 themes: `--green --blue --red --cyan --purple --yellow --orange --pink --white --rainbow` |
| **Resources** | CPU, RAM, disk bars (`▰▱`) that turn orange at 60 percent and red at 85 percent |
| **Network** | Interface, RX/TX, local IP, public IP, city, ISP |
| **Security** | Open ports, UFW, failed SSH logins (24h), fail2ban, SSH hardening checks in `--full` |
| **Ops** | Docker counts, pending updates, failed units, last login, reboot-required flag |
| **Login banner** | Runs automatically over SSH, 13 lines, about 80 columns, no slow network calls at login |
| **Animation** | `--anim` types the command and draws the circle row by row |
| **Brand** | Footer badge: `HACKERFETCH · Powered by AnkitCoder` |

---

## Install

```bash
sudo bash install.sh              # default green theme
sudo bash install.sh --blue       # install with blue as the login theme
sudo bash install.sh --red --keep-default-motd
```

Step by step:

```bash
scp install.sh root@YOUR_VPS_IP:~/
ssh root@YOUR_VPS_IP
bash install.sh --blue
hackerfetch
```

The installer:

1. Installs helpers: `pciutils iproute2 procps curl net-tools util-linux`.
2. Writes `/usr/local/bin/hackerfetch`.
3. Writes the logo to `/usr/share/hackerfetch/`.
4. Saves the chosen theme to `/etc/hackerfetch.conf` and enables the SSH login banner.
5. Warms the cache and prints a preview.

If **BharatFetch** is installed, its login banner is switched off so you do not get two banners. Uninstalling HackerFetch turns it back on.

**Manual install:**

```bash
sudo cp hackerfetch /usr/local/bin/ && sudo chmod +x /usr/local/bin/hackerfetch
hackerfetch --blue
```

---

## Themes (colors)

Every theme colors the circle, the tree labels, the bars, the badge and the section headers.

| Flag | Look | Ring / accent | Binary fill |
|---|---|---|---|
| `--green` *(default)* | Matrix | `46` bright green | `28` dark green |
| `--blue` | Cyber blue | `39` | `25` |
| `--red` | Red team | `196` | `88` |
| `--cyan` | Ice | `51` | `30` |
| `--purple` | Neon violet | `177` | `91` |
| `--yellow` | Amber terminal | `220` | `136` |
| `--orange` | Warning orange | `208` | `130` |
| `--pink` | Synthwave | `213` | `132` |
| `--white` | Ghost / mono | `255` | `243` |
| `--rainbow` | All colors, one per row | gradient | gradient |

Aliases: `--matrix` = green, `--violet` / `--magenta` = purple, `--amber` / `--gold` = yellow, `--mono` / `--ghost` = white, `--all` = rainbow. You can also use `--theme blue` or `-t blue`.

```bash
hackerfetch --list        # show all themes with color swatches
```

**Make a theme the default:**

```bash
sudo hackerfetch --red --save        # login banner (all users)
hackerfetch --blue --save            # only for you (~/.hackerfetchrc)
HACKERFETCH_THEME=cyan hackerfetch   # one-off through an environment variable
```

Priority: command-line flag, then `HACKERFETCH_THEME`, then `~/.hackerfetchrc`, then `/etc/hackerfetch.conf`, then green.

---

## Usage

```bash
hackerfetch                  # default theme
hackerfetch --blue           # blue
hackerfetch --red --full     # red + every detail
hackerfetch --rainbow --anim # animated
hackerfetch --static         # no animation (used by the login banner)
hackerfetch --list           # themes
hackerfetch -v               # version
hackerfetch -h               # help
```

| Option | Effect |
|---|---|
| `--THEME` / `--theme NAME` | Pick a color theme |
| `--static` | Print once (default) |
| `--anim` | Typing + row-by-row reveal (needs a terminal) |
| `--full` | Add detailed sections under the banner |
| `--save` | Remember the theme |
| `--list` | Show all themes |
| `--refresh` | Refresh cached slow data (used internally) |

---

## The hard circle

The art is generated at run time with `awk`, so the binary digits change on every login (like a live matrix).

```
 distance from center  →  glyph
   > 6.5               →  (empty)
   5.8 – 6.5           →  █   outer ring     (bright color)
   5.2 – 5.8           →  ▓   inner ring     (mid color)
   < 5.2               →  0 1 random binary  (dark color, 8% bright sparkles)
   center 9x3 box      →  ╔═══════╗ ║ root# ║ ╚═══════╝
```

Size: 13 rows, 27 columns. In `--rainbow` every row gets its own color.

---

## Login banner (MOTD)

After install, the banner appears **automatically every time you log in over SSH**.

| System | How |
|---|---|
| Ubuntu | `/etc/update-motd.d/99-hackerfetch` runs `hackerfetch --static` through `pam_motd` |
| Debian and others | `/etc/profile.d/99-hackerfetch.sh` for interactive logins |
| Default Ubuntu noise | `10-help-text`, `50-motd-news` etc. are switched off and restored on uninstall. Keep them with `--keep-default-motd` |

**Why login stays fast:** public IP, apt updates, UFW state and failed-SSH counts are cached in `/var/cache/hackerfetch/stats` and refreshed in the background every 30 minutes. The very first login may show `pub-ip ...` for a few seconds.

Change the login color any time:

```bash
sudo hackerfetch --purple --save
```

---

## Fields

| Label | Source |
|---|---|
| os | `/etc/os-release` |
| kernel / up | `uname -r`, `uptime -p` |
| cpu | two samples of `/proc/stat` 0.25 s apart, cores, 1-min load |
| ram / disk | `free`, `df /` |
| net | default-route interface counters in `/sys/class/net` |
| pub-ip | ipinfo.io (cached) |
| ports | `ss -tuln` |
| fw | `ufw status` (cached) |
| threat | failed SSH logins in 24h (`journalctl`, cached), fail2ban state |
| docker | `docker ps` / `ps -a` |
| updates / failed | `apt list --upgradable` (cached), `systemctl --failed` |
| login | `last` |
| time | `Asia/Kolkata` |

---

## `--full` sections

| Section | Contents |
|---|---|
| HARDWARE | CPU model, cores and threads, arch, RAM, swap, GPU, board and BIOS, virtualization |
| DISKS | Filesystems with type and usage, `lsblk` tree |
| NETWORK | All interfaces, gateway, DNS, public IP, ISP, established TCP |
| LISTENING PORTS | Protocol, address, process |
| TOP PROCESSES | Top 5 by CPU and by memory |
| USERS & LOGINS | Current sessions, last 5 logins, failed SSH, sudo group |
| SECURITY | UFW, fail2ban, `PermitRootLogin`, `PasswordAuthentication`, SSH port, updates, failed units |
| DOCKER | Version, images, running containers |
| SYSTEM | Hostname, timezone, boot time, load vs cores, zombies, open files, entropy |

Run with `sudo` for the complete picture (`sshd -T`, `journalctl`, `ss -p` need root).

---

## Customization

Edit `/usr/local/bin/hackerfetch`:

| Change | Where |
|---|---|
| Add or edit a theme | `set_theme()` (three color codes: bright, mid, dark) |
| Rainbow colors | `RB=( ... )` array |
| Circle size | `R=6.5`, the `-6..6` and `-13..13` loops in `art_rows()` |
| Center text | the `T2` split string: `"║| |r|o|o|t|#| |║"` |
| Sparkle amount | `r<0.08` in `art_rows()` |
| Footer / branding | `FOOT=` |
| Timezone | `TZ=Asia/Kolkata` |
| Info lines | the `INFO=( ... )` array (keep 13 lines to match the circle) |

---

## Files

```
.
├── install.sh              # one-shot installer (embeds the script)
├── hackerfetch             # the tool
├── README.md
├── logos/                  # SVG + PNG logo for every theme, all-themes.png
└── screenshots/            # real terminal renders for every theme
```

Installed:

```
/usr/local/bin/hackerfetch
/etc/hackerfetch.conf                    # saved theme
/etc/update-motd.d/99-hackerfetch        # Ubuntu login hook
/etc/profile.d/99-hackerfetch.sh         # fallback hook
/usr/share/hackerfetch/                  # logo
/var/cache/hackerfetch/stats             # cached slow data
/var/lib/hackerfetch/                    # list of MOTD scripts to restore
```

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `command not found` | `ls -l /usr/local/bin/hackerfetch`, re-run the installer |
| Circle looks like an oval | Terminal font is too wide. Use a normal monospace font (cells about 1:2) |
| Boxes instead of `█ ▓ ▰ ╔` | Use a UTF-8 terminal and a font with block and box glyphs (DejaVu Sans Mono, JetBrains Mono) |
| Colors look wrong | Needs 256 colors: `export TERM=xterm-256color` |
| Banner not shown at login | Check `ls -l /etc/update-motd.d/99-hackerfetch` is executable and `grep pam_motd /etc/pam.d/sshd` exists. Debian: log in again |
| Two banners | Remove old `.bashrc` lines: `sed -i '/fetch/d' ~/.bashrc`, or run the installer again |
| `pub-ip ...` / `updates -` | Cache is warming. `sudo hackerfetch --refresh` |
| Theme not changing at login | Use `sudo hackerfetch --red --save` (writes `/etc/hackerfetch.conf`). A `~/.hackerfetchrc` overrides it for that user |
| Animation does nothing | `--anim` needs an interactive terminal (not MOTD or a pipe) |
| `--full` fields empty | Run with `sudo`; install `openssh-server`, `iproute2` |

---

## Privacy

- Only outbound request: `https://ipinfo.io/json` (3 second timeout, in the background, result cached 30 minutes). Remove the `curl` line and set `PIP=offline` to run fully offline.
- Nothing is sent to the author. Nothing is written outside the paths listed above.
- `--full` output contains IPs, users and ports. Redact it before pasting publicly.

---

## Uninstall

```bash
sudo bash install.sh --uninstall
```

Removes the command, hook, config, logo and cache, and restores the previous MOTD (including BharatFetch if it was installed).

---

## License and credits

MIT. Use it, change it, share it.

```
Copyright (c) 2026 AnkitCoder

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files, to deal in the Software
without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the
Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
```

<div align="center">

**HackerFetch · Powered by AnkitCoder**

</div>
