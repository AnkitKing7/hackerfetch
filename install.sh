#!/bin/bash
# HackerFetch installer  -  Powered by AnkitCoder
# usage: sudo bash install.sh [--blue|--red|--green|--cyan|--purple|--yellow|--orange|--pink|--white|--rainbow]
#                             [--keep-default-motd] [--uninstall]
set -e
BIN=/usr/local/bin/hackerfetch
SHARE=/usr/share/hackerfetch
STATE=/var/lib/hackerfetch
CONF=/etc/hackerfetch.conf
HOOK=/etc/update-motd.d/99-hackerfetch
PROF=/etc/profile.d/99-hackerfetch.sh

[ "$(id -u)" -eq 0 ] || { echo "Run as root: sudo bash install.sh"; exit 1; }

restore_all(){
  for L in "$STATE/disabled-motd.list" "$STATE/disabled-bharat.list"; do
    [ -f "$L" ] && while read -r f; do [ -f "$f" ] && chmod +x "$f"; done < "$L"
  done
  [ -f /etc/profile.d/99-bharatfetch.sh.disabled ] && mv /etc/profile.d/99-bharatfetch.sh.disabled /etc/profile.d/99-bharatfetch.sh
  return 0
}

if [ "$1" = "--uninstall" ]; then
  restore_all
  rm -f "$BIN" "$HOOK" "$PROF" "$CONF"
  rm -rf "$SHARE" "$STATE" /var/cache/hackerfetch
  echo "HackerFetch removed. Previous MOTD restored."; exit 0
fi

THEME=green; KEEP_DEFAULT=0
for a in "$@"; do
  case "$a" in
    --keep-default-motd) KEEP_DEFAULT=1;;
    --green|--matrix|--blue|--red|--cyan|--purple|--violet|--magenta|--yellow|--amber|--gold|--orange|--pink|--white|--mono|--rainbow) THEME=${a#--};;
  esac
done

echo "[1/5] Installing dependencies..."
if command -v apt-get >/dev/null; then
  apt-get update -qq >/dev/null 2>&1 || true
  apt-get install -y -qq pciutils iproute2 procps curl net-tools util-linux >/dev/null 2>&1 \
    || echo "  (some packages could not be installed, continuing)"
fi

echo "[2/5] Installing hackerfetch to $BIN ..."
cat > "$BIN" <<'HACKER_EOF'
#!/bin/bash
# ╦ ╦╔═╗╔═╗╦╔═╔═╗╦═╗╔═╗╔═╗╔╦╗╔═╗╦ ╦
# ╠═╣╠═╣║  ╠╩╗║╣ ╠╦╝╠╣ ║╣  ║ ║  ╠═╣
# ╩ ╩╩ ╩╚═╝╩ ╩╚═╝╩╚═╚  ╚═╝ ╩ ╚═╝╩ ╩   Powered by AnkitCoder
# hackerfetch - hacker-style neofetch with a hard binary circle and color themes
export LC_ALL=C.UTF-8
VERSION="1.0"
AUTHOR="AnkitCoder"
CONF=/etc/hackerfetch.conf

THEME=""; ANIM=0; FULL=0; SAVE=0; REFRESH=0
[ -r "$CONF" ] && . "$CONF"
[ -r "$HOME/.hackerfetchrc" ] && . "$HOME/.hackerfetchrc"
THEME=${HACKERFETCH_THEME:-$THEME}

# ---------------- themes ----------------
RB=(196 202 208 214 220 226 190 154 118 82 46 47 48 49 51 45 39 33 27 21 57 93 129 165 201)
set_theme(){
  RAINBOW=0
  case "$1" in
    blue)                 P1=39;  P2=33;  P3=25;  T=blue;;
    red)                  P1=196; P2=160; P3=88;  T=red;;
    cyan)                 P1=51;  P2=44;  P3=30;  T=cyan;;
    purple|violet|magenta) P1=177; P2=135; P3=91;  T=purple;;
    yellow|amber|gold)    P1=220; P2=178; P3=136; T=yellow;;
    orange)               P1=208; P2=166; P3=130; T=orange;;
    pink)                 P1=213; P2=170; P3=132; T=pink;;
    white|mono|ghost)     P1=255; P2=248; P3=243; T=white;;
    rainbow|all)          P1=46;  P2=40;  P3=28;  T=rainbow; RAINBOW=1;;
    ""|green|matrix)      P1=46;  P2=34;  P3=28;  T=green;;
    *) echo "unknown theme '$1' - using green (see: hackerfetch --list)" >&2
                          P1=46;  P2=34;  P3=28;  T=green;;
  esac
}

R=$'\e[0m'; B=$'\e[1m'; DM=$'\e[38;5;245m'; WH=$'\e[97m'
ac(){ local c=$P1; ((RAINBOW)) && c=${RB[$(( ($1*2) % ${#RB[@]} ))]}; printf '\e[38;5;%dm' "$c"; }

usage(){
cat <<EOF
hackerfetch $VERSION - Powered by $AUTHOR

Usage: hackerfetch [theme] [options]

Themes (colors):
  --green (default)  --blue  --red  --cyan  --purple  --yellow
  --orange  --pink  --white  --rainbow        or: --theme NAME

Options:
  --static     no animation (default for login banner)
  --anim       typing + row-by-row animation
  --full       show every detail section
  --save       remember the chosen theme (/etc/hackerfetch.conf or ~/.hackerfetchrc)
  --list       show all themes with color swatches
  -v           version
  -h           this help

Examples:
  hackerfetch --blue
  hackerfetch --red --full
  hackerfetch --rainbow --anim
  sudo hackerfetch --purple --save
EOF
}
list_themes(){
  echo; echo "  Available themes:"; echo
  for t in green blue red cyan purple yellow orange pink white rainbow; do
    set_theme "$t"
    printf '   %-8s ' "--$t"
    if ((RAINBOW)); then for c in "${RB[@]}"; do printf '\e[38;5;%dm█' "$c"; done
    else printf '\e[38;5;%dm████\e[38;5;%dm████\e[38;5;%dm████' "$P1" "$P2" "$P3"; fi
    printf '%s\n' "$R"
  done; echo
}

while [ $# -gt 0 ]; do
  case "$1" in
    --green|--matrix|--blue|--red|--cyan|--purple|--violet|--magenta|--yellow|--amber|--gold|--orange|--pink|--white|--mono|--ghost|--rainbow|--all) THEME=${1#--};;
    --theme|-t|--color|-c) THEME=$2; shift;;
    --anim) ANIM=1;; --static) ANIM=0;; --full) FULL=1;; --save) SAVE=1;;
    --refresh) REFRESH=1;;
    --list) list_themes; exit 0;;
    -v|--version) echo "hackerfetch $VERSION - Powered by $AUTHOR"; exit 0;;
    -h|--help) usage; exit 0;;
  esac; shift
done
set_theme "$THEME"
[ ! -t 1 ] && ANIM=0

if ((SAVE)); then
  if [ -w /etc ]; then F=$CONF; else F=$HOME/.hackerfetchrc; fi
  echo "THEME=$T" > "$F" && echo "Theme '$T' saved to $F"
  [ "$REFRESH" = 0 ] && exit 0
fi

# ---------------- cache (slow data in background) ----------------
if [ -w /var/cache ] 2>/dev/null; then CACHE_DIR=/var/cache/hackerfetch; else CACHE_DIR=/tmp/.hackerfetch-$UID; fi
CACHE=$CACHE_DIR/stats
if ((REFRESH)); then
  mkdir -p "$CACHE_DIR" 2>/dev/null || exit 0
  J=$(curl -s --max-time 3 https://ipinfo.io/json 2>/dev/null)
  jget(){ printf '%s' "$J" | grep -o "\"$1\": *\"[^\"]*\"" | head -1 | sed 's/.*: *"\(.*\)"/\1/'; }
  PIP=$(jget ip); CITY=$(jget city); CC=$(jget country); ORG=$(jget org)
  FAILSSH=$(journalctl -u ssh -u sshd --since "24 hours ago" -q --no-pager 2>/dev/null | grep -c "Failed password")
  UPD=$(apt list --upgradable 2>/dev/null | grep -c upgradable)
  if command -v ufw >/dev/null; then FWS=$(ufw status 2>/dev/null | head -1 | sed 's/Status: //'); else FWS="n/a"; fi
  RB_=no; [ -f /var/run/reboot-required ] && RB_=yes
  {
    echo "PIP='${PIP:-offline}'"; echo "GEO='${CITY:+$CITY, }$CC'"; echo "ORG='$ORG'"
    echo "FAILSSH='${FAILSSH:-0}'"; echo "UPD='${UPD:-0}'"; echo "FWS='${FWS:-n/a}'"; echo "RBT='$RB_'"
  } > "$CACHE.tmp" && mv "$CACHE.tmp" "$CACHE"
  exit 0
fi
PIP="..."; GEO=""; ORG=""; FAILSSH="-"; UPD="-"; FWS="-"; RBT=no
[ -r "$CACHE" ] && . "$CACHE"
if [ ! -s "$CACHE" ] || [ $(( $(date +%s) - $(stat -c %Y "$CACHE" 2>/dev/null || echo 0) )) -gt 1800 ]; then
  ( "$0" --refresh >/dev/null 2>&1 </dev/null & )
fi

# ---------------- helpers ----------------
bar(){
  local p=$1 f i col; ((p>100)) && p=100; f=$((p/10))
  for ((i=0;i<10;i++)); do
    if ((i<f)); then
      if ((p>=85)); then col=196; elif ((p>=60 && !RAINBOW && T!=red)); then col=214; else col=$P1; fi
      ((RAINBOW)) && ((p<85)) && col=${RB[$((i*2+4))]}
      printf '\e[38;5;%sm▰' "$col"
    else printf '\e[38;5;238m▱'; fi
  done
  printf '%s %3d%%' "$R" "$p"
}
hb(){ awk -v b="$1" 'BEGIN{split("B K M G T",u," ");i=1;while(b>=1024&&i<5){b/=1024;i++}printf "%.1f%s",b,u[i]}'; }
lab(){ # lab index name  (last row uses └─)
  local pre="├─"; [ "$1" = "L" ] && pre="└─"
  local idx=$2
  printf '%s%s %s%s%-7s%s' "$(ac $idx)" "$pre" "$B" "$(ac $idx)" "$3" "$R"
}

# ---------------- gather (fast) ----------------
OS=$(. /etc/os-release; echo "$PRETTY_NAME")
KER=$(uname -r)
UP=$(uptime -p | sed 's/^up //; s/ hours\?/h/; s/ minutes\?/m/; s/ days\?/d/; s/ weeks\?/w/; s/,//g')
CORES=$(nproc)
read -r _ u1 n1 s1 i1 w1 q1 sq1 _ < /proc/stat; sleep 0.25
read -r _ u2 n2 s2 i2 w2 q2 sq2 _ < /proc/stat
dt=$(( (u2+n2+s2+i2+w2+q2+sq2)-(u1+n1+s1+i1+w1+q1+sq1) )); di=$(( (i2+w2)-(i1+w1) ))
CP=$(( dt>0 ? (dt-di)*100/dt : 0 ))
LOAD=$(awk '{print $1}' /proc/loadavg)
read -r MT MU <<<"$(free -m | awk '/Mem:/{print $2,$3}')"; MP=$((MU*100/MT))
MEMH=$(free -h | awk '/Mem:/{print $3"/"$2}')
DP=$(df / --output=pcent | tail -1 | tr -dc 0-9)
DISKH=$(df -h / | awk 'NR==2{print $3"/"$2}')
IF=$(ip route show default 2>/dev/null | awk '{print $5; exit}')
RX=$(cat /sys/class/net/$IF/statistics/rx_bytes 2>/dev/null || echo 0)
TX=$(cat /sys/class/net/$IF/statistics/tx_bytes 2>/dev/null || echo 0)
LIP=$(hostname -I 2>/dev/null | awk '{print $1}')
PORTS=$(ss -tuln 2>/dev/null | tail -n +2 | wc -l)
FAILED=$(systemctl --failed --no-legend 2>/dev/null | wc -l)
if command -v docker >/dev/null && docker info >/dev/null 2>&1; then DK="$(docker ps -q | wc -l)/$(docker ps -aq | wc -l)"; else DK="-"; fi
F2B=$(systemctl is-active fail2ban 2>/dev/null); [ "$F2B" = active ] && F2B=on || F2B=off
LAST=$(last -w -a -n 3 2>/dev/null | grep -vE '^(reboot|wtmp|$)' | sed -n 2p | awk '{printf "%s from %s",$1,$NF}')
LAST=${LAST:-first login}
HN=$(hostname); HNS=${HN:0:16}
NOW=$(TZ=Asia/Kolkata date '+%d %b %H:%M IST')

# ---------------- hard circle art ----------------
art_rows(){
  awk -v p1=$P1 -v p2=$P2 -v p3=$P3 -v rb="${RB[*]}" -v rainbow=$RAINBOW -v seed="$(date +%s%N | cut -c1-9)" '
  BEGIN{
    srand(seed); n=split(rb,RB," ")
    split("╔|═|═|═|═|═|═|═|╗",T1,"|"); split("║| |r|o|o|t|#| |║",T2,"|"); split("╚|═|═|═|═|═|═|═|╝",T3,"|")
    for(y=-6;y<=6;y++){
      ry=y+7
      if(rainbow){ c1=RB[((ry-1)*2)%n+1]; c2=c1; c3=c1 } else { c1=p1; c2=p2; c3=p3 }
      out=""
      for(i=-13;i<=13;i++){
        d=sqrt((i/2.0)*(i/2.0)+y*y)
        if(d>6.5){ out=out " "; continue }
        if(y>=-1 && y<=1 && i>=-4 && i<=4){
          k=i+5
          if(y==-1) t=T1[k]; else if(y==0) t=T2[k]; else t=T3[k]
          out=out sprintf("\033[1;38;5;%d;48;5;16m%s\033[0m", c1, t); continue
        }
        if(d>5.8)      out=out sprintf("\033[1;38;5;%dm█\033[0m", c1)
        else if(d>5.2) out=out sprintf("\033[38;5;%dm▓\033[0m", c2)
        else {
          r=rand(); ch=(rand()<0.5)?"0":"1"
          if(r<0.08) out=out sprintf("\033[1;38;5;%dm%s\033[0m", c1, ch)
          else       out=out sprintf("\033[38;5;%dm%s\033[0m", c3, ch)
        }
      }
      print out
    }
  }'
}
mapfile -t ART < <(art_rows)

# ---------------- info (13 compact lines) ----------------
HDR="$(ac 0)┌─[$R$WH$B$(whoami)$R$(ac 0)@$HNS]─[$R${LIP:-n/a}$(ac 0)]$R"
INFO=(
"$HDR"
"$(lab 1 1 os)$OS"
"$(lab 2 2 kernel)$KER ${DM}· up$R $UP"
"$(lab 3 3 cpu)$(bar $CP) ${DM}${CORES}c·$R$LOAD"
"$(lab 4 4 ram)$(bar $MP) ${DM}$MEMH$R"
"$(lab 5 5 disk)$(bar $DP) ${DM}$DISKH$R"
"$(lab 6 6 net)${IF:-n/a} ${DM}↓$R$(hb $RX) ${DM}↑$R$(hb $TX)"
"$(lab 7 7 pub-ip)$PIP ${DM}$GEO$R"
"$(lab 8 8 ports)$PORTS open ${DM}· fw$R $FWS"
"$(lab 9 9 threat)${DM}ssh-fail$R $FAILSSH ${DM}· f2b$R $F2B"
"$(lab 10 10 docker)$DK ${DM}· updates$R $UPD ${DM}· failed$R $FAILED"
"$(lab 11 11 login)$(printf '%s' "$LAST" | cut -c1-34)"
"$(lab L 12 time)$NOW ${DM}[$R$(ac 12)ONLINE$R${DM}]$R"
)

BADGE=$'\e[30;48;5;'$P1'm'; ((RAINBOW)) && BADGE=$'\e[30;48;5;46m'
NAMEC=$(ac 6); ((RAINBOW)) && NAMEC=$'\e[38;5;201m'
FOOT="  $B${BADGE} HACKERFETCH $R ${DM}v$VERSION · $T · Powered by$R $B${NAMEC}$AUTHOR$R"

render(){
  local d=$1 i
  for i in $(seq 0 12); do
    printf '  %s   %s\n' "${ART[i]}" "${INFO[i]}"
    [ "$d" != 0 ] && sleep "$d"
  done
}

# ---------------- full details ----------------
SECN=0
sec(){ SECN=$((SECN+1)); printf '\n  %s%s▌ %s %s%s\n' "$(ac $((SECN*2)))" "$B" "$1" "$(printf '─%.0s' $(seq 1 $((58-${#1}))))" "$R"; }
kv(){ printf '  %s%-15s%s %s\n' "$DM" "$1" "$R" "$2"; }
full_details(){
  CPU=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)
  if command -v nvidia-smi >/dev/null; then GPU=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)
  elif command -v lspci >/dev/null; then GPU=$(lspci | grep -iE 'vga|3d|display' | head -1 | cut -d: -f3- | xargs); fi
  GPU=${GPU:-None / virtual}
  sec "HARDWARE"
  kv "cpu" "$CPU"
  kv "cores/threads" "$(lscpu 2>/dev/null | awk -F: '/^Core\(s\) per socket/{c=$2}/^Socket\(s\)/{s=$2}/^CPU\(s\):/{t=$2}END{gsub(/ /,"",c);gsub(/ /,"",s);gsub(/ /,"",t);print c*s" cores / "t" threads"}')"
  kv "arch" "$(uname -m)"
  kv "ram" "$(free -h | awk '/Mem:/{print $2" (used "$3", free "$4", cache "$6")"}')"
  kv "swap" "$(free -h | awk '/Swap:/{print $2" (used "$3")"}')"
  kv "gpu" "$GPU"
  kv "board/bios" "$(cat /sys/devices/virtual/dmi/id/board_name 2>/dev/null || echo n/a)  $(cat /sys/devices/virtual/dmi/id/bios_version 2>/dev/null)"
  kv "virt" "$(systemd-detect-virt 2>/dev/null || echo none)"

  sec "DISKS"
  df -hT -x tmpfs -x devtmpfs -x squashfs -x overlay -x fuse.rclone 2>/dev/null | awk 'NR==1{printf "  %-22s %-8s %6s %6s %6s %5s\n",$1,$2,$3,$4,$5,$6} NR>1{printf "  %-22s %-8s %6s %6s %6s %5s  %s\n",$1,$2,$3,$4,$5,$6,$7}'
  command -v lsblk >/dev/null && { echo; lsblk -o NAME,SIZE,TYPE,MOUNTPOINT 2>/dev/null | sed 's/^/  /'; }

  sec "NETWORK"
  ip -brief addr 2>/dev/null | awk '{printf "  %-14s %-8s %s %s\n",$1,$2,$3,$4}'
  kv "gateway" "$(ip route 2>/dev/null | awk '/default/{print $3; exit}')"
  kv "dns" "$(awk '/^nameserver/{printf "%s ",$2}' /etc/resolv.conf)"
  kv "public ip" "$PIP  $GEO"
  kv "isp" "${ORG:-n/a}"
  kv "tcp established" "$(ss -tn state established 2>/dev/null | tail -n +2 | wc -l)"

  sec "LISTENING PORTS"
  printf '  %s%-6s %-26s %s%s\n' "$DM" "PROTO" "ADDRESS" "PROCESS" "$R"
  ss -tulnpH 2>/dev/null | awk '{p=$NF; sub(/.*users:\(\("/,"",p); sub(/".*/,"",p); printf "  %-6s %-26s %s\n",$1,$5,p}' | sort -u | head -15

  sec "TOP PROCESSES"
  printf '  %s%-18s %6s %6s%s\n' "$DM" "COMMAND" "CPU%" "MEM%" "$R"
  ps -eo comm,%cpu,%mem --sort=-%cpu --no-headers | head -5 | awk '{printf "  %-18s %6s %6s\n",$1,$2,$3}'
  echo "  ${DM}-- by memory --${R}"
  ps -eo comm,%cpu,%mem --sort=-%mem --no-headers | head -5 | awk '{printf "  %-18s %6s %6s\n",$1,$2,$3}'

  sec "USERS & LOGINS"
  who 2>/dev/null | awk '{printf "  now: %s from %s (%s %s)\n",$1,$5,$3,$4}'
  last -n 5 -a -w 2>/dev/null | grep -vE '^(reboot|wtmp|$)' | head -5 | sed 's/^/  /'
  kv "ssh fails 24h" "$FAILSSH"
  kv "sudo group" "$(getent group sudo | cut -d: -f4)"

  sec "SECURITY"
  kv "firewall (ufw)" "$FWS"
  kv "fail2ban" "$(systemctl is-active fail2ban 2>/dev/null || echo not-installed)"
  kv "root login" "$(sshd -T 2>/dev/null | awk '/^permitrootlogin/{print $2}')"
  kv "password auth" "$(sshd -T 2>/dev/null | awk '/^passwordauthentication/{print $2}')"
  kv "ssh port" "$(sshd -T 2>/dev/null | awk '/^port /{print $2; exit}')"
  kv "pending updates" "$UPD   (reboot required: $RBT)"
  kv "failed units" "$FAILED"

  sec "DOCKER"
  if command -v docker >/dev/null && docker info >/dev/null 2>&1; then
    kv "version" "$(docker --version | cut -d, -f1)"
    kv "images" "$(docker images -q | wc -l)"
    docker ps --format '  {{.Names}}\t{{.Image}}\t{{.Status}}' 2>/dev/null | column -t -s $'\t' | head -10
  else kv "docker" "not installed / not running"; fi

  sec "SYSTEM"
  kv "hostname" "$(hostname -f 2>/dev/null || hostname)"
  kv "timezone" "$(timedatectl show -p Timezone --value 2>/dev/null || cat /etc/timezone 2>/dev/null)"
  kv "boot time" "$(uptime -s 2>/dev/null)"
  kv "load avg" "$(awk '{print $1", "$2", "$3}' /proc/loadavg)  (cores: $CORES)"
  kv "processes" "$(ps -e --no-headers | wc -l) total, $(ps -eo stat --no-headers | grep -c '^Z') zombie"
  kv "open files" "$(awk '{print $1}' /proc/sys/fs/file-nr) / $(cat /proc/sys/fs/file-max)"
  kv "entropy" "$(cat /proc/sys/kernel/random/entropy_avail 2>/dev/null)"
  echo
}

# ---------------- output ----------------
echo
if ((ANIM)); then
  printf '\e[?25l'; trap 'printf "\e[?25h"' EXIT
  p="$(ac 0)$(whoami)@$HNS$R:~# "
  printf '  %s' "$p"; for w in "hackerfetch" "--$T"; do for ((k=0;k<${#w};k++)); do printf '%s' "${w:k:1}"; sleep 0.03; done; printf ' '; done; echo; sleep 0.2; echo
  render 0.05
else
  render 0
fi
printf '\n%s\n\n' "$FOOT"
((FULL)) && full_details
exit 0
HACKER_EOF
chmod +x "$BIN"

echo "[3/5] Installing logo to $SHARE ..."
mkdir -p "$SHARE"
cat > "$SHARE/hackerfetch-green.svg" <<'SVG_EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 630" width="1200" height="630" font-family="DejaVu Sans Mono, Consolas, monospace">
<rect width="1200" height="630" fill="#060a0d"/>
<defs><clipPath id="c"><circle cx="320" cy="315" r="215"/></clipPath>
</defs>
<g clip-path="url(#c)">
<text x="70" y="83" font-size="18" fill="#008700" textLength="520">10001110<tspan fill="#00ff00" font-weight="700">0</tspan>10110110<tspan fill="#00ff00" font-weight="700">0</tspan>1<tspan fill="#00ff00" font-weight="700">1</tspan>011010111101<tspan fill="#00ff00" font-weight="700">1</tspan>001101001110100</text>
<text x="70" y="105" font-size="18" fill="#008700" textLength="520"><tspan fill="#00ff00" font-weight="700">0</tspan>01010101010111001100001011<tspan fill="#00ff00" font-weight="700">0</tspan>111111<tspan fill="#00ff00" font-weight="700">0</tspan>011<tspan fill="#00ff00" font-weight="700">1</tspan>111010101</text>
<text x="70" y="127" font-size="18" fill="#008700" textLength="520">1<tspan fill="#00ff00" font-weight="700">0</tspan>11<tspan fill="#00ff00" font-weight="700">1</tspan>00001<tspan fill="#00ff00" font-weight="700">1</tspan>1<tspan fill="#00ff00" font-weight="700">1</tspan>1100001<tspan fill="#00ff00" font-weight="700">1</tspan><tspan fill="#00ff00" font-weight="700">1</tspan>110101100<tspan fill="#00ff00" font-weight="700">0</tspan>1110001110<tspan fill="#00ff00" font-weight="700">0</tspan>00011</text>
<text x="70" y="149" font-size="18" fill="#008700" textLength="520">111000100111001<tspan fill="#00ff00" font-weight="700">0</tspan>00111011<tspan fill="#00ff00" font-weight="700">1</tspan>111011<tspan fill="#00ff00" font-weight="700">1</tspan>01110<tspan fill="#00ff00" font-weight="700">0</tspan>001100<tspan fill="#00ff00" font-weight="700">0</tspan>010</text>
<text x="70" y="171" font-size="18" fill="#008700" textLength="520">001111010011001110111010001100<tspan fill="#00ff00" font-weight="700">0</tspan>00<tspan fill="#00ff00" font-weight="700">0</tspan>01000111100100</text>
<text x="70" y="193" font-size="18" fill="#008700" textLength="520">101010110110111<tspan fill="#00ff00" font-weight="700">0</tspan>101<tspan fill="#00ff00" font-weight="700">0</tspan>101010<tspan fill="#00ff00" font-weight="700">1</tspan>001001010101111001001</text>
<text x="70" y="215" font-size="18" fill="#008700" textLength="520">01<tspan fill="#00ff00" font-weight="700">0</tspan>10111110111010110<tspan fill="#00ff00" font-weight="700">1</tspan>1111111011010<tspan fill="#00ff00" font-weight="700">0</tspan>011100000<tspan fill="#00ff00" font-weight="700">1</tspan>000</text>
<text x="70" y="237" font-size="18" fill="#008700" textLength="520">11100100000100<tspan fill="#00ff00" font-weight="700">1</tspan>101000000<tspan fill="#00ff00" font-weight="700">0</tspan>00101110<tspan fill="#00ff00" font-weight="700">0</tspan>011100<tspan fill="#00ff00" font-weight="700">1</tspan>0010101</text>
<text x="70" y="259" font-size="18" fill="#008700" textLength="520">0110<tspan fill="#00ff00" font-weight="700">0</tspan>1111001<tspan fill="#00ff00" font-weight="700">1</tspan>10101101011001000<tspan fill="#00ff00" font-weight="700">0</tspan><tspan fill="#00ff00" font-weight="700">1</tspan><tspan fill="#00ff00" font-weight="700">0</tspan><tspan fill="#00ff00" font-weight="700">1</tspan>10110100100110</text>
<text x="70" y="281" font-size="18" fill="#008700" textLength="520">110110001<tspan fill="#00ff00" font-weight="700">0</tspan>100001<tspan fill="#00ff00" font-weight="700">1</tspan>01<tspan fill="#00ff00" font-weight="700">1</tspan>1011101111011111<tspan fill="#00ff00" font-weight="700">0</tspan>1010110<tspan fill="#00ff00" font-weight="700">1</tspan><tspan fill="#00ff00" font-weight="700">1</tspan>10</text>
<text x="70" y="303" font-size="18" fill="#008700" textLength="520">011111111<tspan fill="#00ff00" font-weight="700">1</tspan>010101100100100<tspan fill="#00ff00" font-weight="700">1</tspan>11100<tspan fill="#00ff00" font-weight="700">1</tspan><tspan fill="#00ff00" font-weight="700">1</tspan><tspan fill="#00ff00" font-weight="700">1</tspan>00111001001000</text>
<text x="70" y="325" font-size="18" fill="#008700" textLength="520">10001001110<tspan fill="#00ff00" font-weight="700">1</tspan>01100000<tspan fill="#00ff00" font-weight="700">1</tspan>011100000011101101000011100</text>
<text x="70" y="347" font-size="18" fill="#008700" textLength="520">11110<tspan fill="#00ff00" font-weight="700">1</tspan>101011010110010000111010110<tspan fill="#00ff00" font-weight="700">0</tspan>01011000110<tspan fill="#00ff00" font-weight="700">0</tspan><tspan fill="#00ff00" font-weight="700">0</tspan>1</text>
<text x="70" y="369" font-size="18" fill="#008700" textLength="520">11011011111100111010001000100101<tspan fill="#00ff00" font-weight="700">0</tspan>0<tspan fill="#00ff00" font-weight="700">1</tspan>1001100111010</text>
<text x="70" y="391" font-size="18" fill="#008700" textLength="520">01<tspan fill="#00ff00" font-weight="700">1</tspan>10011<tspan fill="#00ff00" font-weight="700">0</tspan>100111101011100<tspan fill="#00ff00" font-weight="700">1</tspan>001010101<tspan fill="#00ff00" font-weight="700">1</tspan>101111<tspan fill="#00ff00" font-weight="700">1</tspan>01100<tspan fill="#00ff00" font-weight="700">0</tspan></text>
<text x="70" y="413" font-size="18" fill="#008700" textLength="520">10110100<tspan fill="#00ff00" font-weight="700">0</tspan>011110110000000101100<tspan fill="#00ff00" font-weight="700">0</tspan>11011001<tspan fill="#00ff00" font-weight="700">0</tspan><tspan fill="#00ff00" font-weight="700">0</tspan>01<tspan fill="#00ff00" font-weight="700">0</tspan>1<tspan fill="#00ff00" font-weight="700">1</tspan>01</text>
<text x="70" y="435" font-size="18" fill="#008700" textLength="520">11101000<tspan fill="#00ff00" font-weight="700">0</tspan>11111<tspan fill="#00ff00" font-weight="700">1</tspan><tspan fill="#00ff00" font-weight="700">1</tspan>0000<tspan fill="#00ff00" font-weight="700">1</tspan>111000000010100100<tspan fill="#00ff00" font-weight="700">0</tspan>00100000</text>
<text x="70" y="457" font-size="18" fill="#008700" textLength="520"><tspan fill="#00ff00" font-weight="700">1</tspan>011010000100101<tspan fill="#00ff00" font-weight="700">0</tspan>0111000100100111000<tspan fill="#00ff00" font-weight="700">0</tspan>1<tspan fill="#00ff00" font-weight="700">1</tspan>010<tspan fill="#00ff00" font-weight="700">0</tspan>1000<tspan fill="#00ff00" font-weight="700">0</tspan></text>
<text x="70" y="479" font-size="18" fill="#008700" textLength="520">100000<tspan fill="#00ff00" font-weight="700">0</tspan>00110<tspan fill="#00ff00" font-weight="700">1</tspan>01000111111011111000110000001110000</text>
<text x="70" y="501" font-size="18" fill="#008700" textLength="520">100<tspan fill="#00ff00" font-weight="700">1</tspan>10101001001001111001010100<tspan fill="#00ff00" font-weight="700">0</tspan><tspan fill="#00ff00" font-weight="700">0</tspan>01000111000000<tspan fill="#00ff00" font-weight="700">0</tspan>1</text>
<text x="70" y="523" font-size="18" fill="#008700" textLength="520">10010101000010101111<tspan fill="#00ff00" font-weight="700">1</tspan>011110001010<tspan fill="#00ff00" font-weight="700">0</tspan>111<tspan fill="#00ff00" font-weight="700">0</tspan>000111<tspan fill="#00ff00" font-weight="700">0</tspan>101</text>
<text x="70" y="545" font-size="18" fill="#008700" textLength="520">10101101110010101101000<tspan fill="#00ff00" font-weight="700">1</tspan>110110101101110000010<tspan fill="#00ff00" font-weight="700">0</tspan>01</text>
<text x="70" y="567" font-size="18" fill="#008700" textLength="520">0010<tspan fill="#00ff00" font-weight="700">0</tspan>10010000011110111011<tspan fill="#00ff00" font-weight="700">0</tspan><tspan fill="#00ff00" font-weight="700">1</tspan>1111<tspan fill="#00ff00" font-weight="700">0</tspan>000<tspan fill="#00ff00" font-weight="700">0</tspan>101001101101</text>
</g>
<circle cx="320" cy="315" r="242" fill="none" stroke="#00ff00" stroke-width="16"/>
<circle cx="320" cy="315" r="216" fill="none" stroke="#00af00" stroke-width="6"/>
<rect x="200" y="263" width="240" height="104" fill="#040608" stroke="#00ff00" stroke-width="4"/>
<rect x="208" y="271" width="224" height="88" fill="none" stroke="#00af00" stroke-width="2"/>
<text x="320" y="332" text-anchor="middle" font-size="50" font-weight="700" fill="#00ff00">root#</text>
<text x="620" y="216" font-size="66" font-weight="700" fill="#00ff00">HACKERFETCH</text>
<text x="623" y="266" font-size="21" fill="#96a0aa">hacker-style neofetch for your Linux server</text>
<text x="623" y="346" font-size="28" fill="#96a0aa">Powered by <tspan font-size="36" font-weight="700" fill="#00ff00">AnkitCoder</tspan></text>
<rect x="620" y="390" width="520" height="56" fill="#0e1216" stroke="#00af00" stroke-width="2"/>
<text x="640" y="428" font-size="30" font-weight="700" fill="#00ff00">$ hackerfetch --green</text>
<rect x="620" y="478" width="36" height="36" fill="#00ff00"/>
<rect x="672" y="478" width="36" height="36" fill="#00afff"/>
<rect x="724" y="478" width="36" height="36" fill="#ff0000"/>
<rect x="776" y="478" width="36" height="36" fill="#00ffff"/>
<rect x="828" y="478" width="36" height="36" fill="#d787ff"/>
<rect x="880" y="478" width="36" height="36" fill="#ffd700"/>
<rect x="932" y="478" width="36" height="36" fill="#ff8700"/>
<rect x="984" y="478" width="36" height="36" fill="#ff87ff"/>
<rect x="1036" y="478" width="36" height="36" fill="#eeeeee"/>
<rect x="1088" y="478" width="36" height="36" fill="url(#g)"/>
<text x="620" y="540" font-size="12" fill="#78828c">green blue red cyan purple yellow orange pink white rainbow</text>
</svg>
SVG_EOF

echo "[4/5] Enabling on SSH login (MOTD), theme: $THEME ..."
mkdir -p "$STATE"
echo "THEME=$THEME" > "$CONF"
: > "$STATE/disabled-motd.list"; : > "$STATE/disabled-bharat.list"
if [ -d /etc/update-motd.d ]; then
  if [ "$KEEP_DEFAULT" -eq 0 ]; then
    for f in /etc/update-motd.d/*; do
      [ "$f" = "$HOOK" ] && continue
      case "$f" in *99-bharatfetch) continue;; esac
      if [ -x "$f" ]; then echo "$f" >> "$STATE/disabled-motd.list"; chmod -x "$f"; fi
    done
  fi
  # switch off BharatFetch banner if it is installed (avoid two banners)
  if [ -x /etc/update-motd.d/99-bharatfetch ]; then
    echo /etc/update-motd.d/99-bharatfetch >> "$STATE/disabled-bharat.list"; chmod -x /etc/update-motd.d/99-bharatfetch
  fi
  printf '#!/bin/sh\nexec /usr/local/bin/hackerfetch --static\n' > "$HOOK"
  chmod +x "$HOOK"
else
  [ -f /etc/profile.d/99-bharatfetch.sh ] && mv /etc/profile.d/99-bharatfetch.sh /etc/profile.d/99-bharatfetch.sh.disabled
  printf '[ -t 1 ] && [ -z "$HACKER_SHOWN" ] && export HACKER_SHOWN=1 && /usr/local/bin/hackerfetch --static\n' > "$PROF"
fi
sed -i '/# bharatfetch-login/d' /root/.bashrc 2>/dev/null || true

echo "[5/5] Warming cache (public IP, updates, ssh stats)..."
"$BIN" --refresh || true

echo
"$BIN" --static
echo "Done! HackerFetch will show on every SSH login (theme: $THEME)."
echo
echo "  hackerfetch --blue            try a color:  --green --blue --red --cyan --purple"
echo "                                              --yellow --orange --pink --white --rainbow"
echo "  sudo hackerfetch --red --save make a color the login default"
echo "  hackerfetch --full            every detail"
echo "  hackerfetch --anim            typing + row animation"
echo "  hackerfetch --list            show all themes"
echo "  sudo bash install.sh --uninstall   remove (restores previous MOTD)"
echo
echo "Powered by AnkitCoder"
