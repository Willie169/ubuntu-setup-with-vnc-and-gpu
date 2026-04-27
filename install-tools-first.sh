#!/bin/bash

shopt -s expand_aliases
cd ~
sudo -v
while true; do sudo -v; sleep 60; done & SUDOPID=$!
sudo sed -i -e 's/^[# ]*HandleLidSwitch=.*/HandleLidSwitch=ignore/' -e 's/^[# ]*HandleLidSwitchDocked=.*/HandleLidSwitchDocked=ignore/' -e 's/^[# ]*HandleLidSwitchExternalPower=.*/HandleLidSwitchExternalPower=ignore/' "/etc/systemd/logind.conf"
sudo grep -q '^HandleLidSwitch=' "/etc/systemd/logind.conf" || echo 'HandleLidSwitch=ignore' | sudo tee -a "/etc/systemd/logind.conf" > /dev/null
sudo grep -q '^HandleLidSwitchDocked=' "/etc/systemd/logind.conf" || echo 'HandleLidSwitchDocked=ignore' | sudo tee -a "/etc/systemd/logind.conf" > /dev/null
sudo grep -q '^HandleLidSwitchExternalPower=' "/etc/systemd/logind.conf" || echo 'HandleLidSwitchExternalPower=ignore' | sudo tee -a "/etc/systemd/logind.conf" > /dev/null
for file in "/etc/grub.d/30_os-prober" "/etc/default/grub.d/30_os-prober"; do
  if [[ -f "$file" ]]; then
    if grep -q '^quick_boot=' "$file"; then
      sudo sed -i 's/^quick_boot=.*/quick_boot="0"/' "$file"
    else
      echo 'quick_boot="0"' | sudo tee -a "$file"
    fi
  fi
done
sudo update-grub
DM=$(basename "$(basename "$(readlink -f /etc/systemd/system/display-manager.service)" || true)" ".service" || true)
USER_NAME=${SUDO_USER:-$(logname 2>/dev/null || true)}
if [[ -n "$DM" ]] && [[ -n "$USER_NAME" ]]; then
case "$DM" in
gdm|gdm3)
CONF="/etc/gdm/custom.conf"
TMP=$(mktemp)
if sudo test -f "$CONF"; then
    sudo cat "$CONF" > "$TMP"
fi
sed -i '/AutomaticLoginEnable/d' "$TMP"
sed -i '/AutomaticLogin=/d' "$TMP"
sed -i '/WaylandEnable=/d' "$TMP"
if ! grep -q "^\[daemon\]" "$TMP"; then
  printf "\n[daemon]\n" >> "$TMP"
fi
sed -i "/^\[daemon\]/a AutomaticLoginEnable=True\nAutomaticLogin=$USER_NAME\nWaylandEnable=true" "$TMP"
sudo tee "$CONF" < "$TMP" >/dev/null
;;
sddm)
CONF="/etc/sddm.conf"
TMP=$(mktemp)
if sudo test -f "$CONF"; then
  sudo cat "$CONF" > "$TMP"
fi
sed -i '/User=/d' "$TMP"
sed -i '/Session=/d' "$TMP"
if ! grep -q "^\[Autologin\]" "$TMP"; then
  printf "\n[Autologin]\n" >> "$TMP"
fi
sed -i "/^\[Autologin\]/a User=$USER_NAME\nSession=plasmawayland" "$TMP"
sudo tee "$CONF" < "$TMP" >/dev/null
;;
lightdm)
CONF="/etc/lightdm/lightdm.conf"
TMP=$(mktemp)
if sudo test -f "$CONF"; then
  sudo cat "$CONF" > "$TMP"
fi
sed -i '/autologin-user=/d' "$TMP"
sed -i '/autologin-user-timeout=/d' "$TMP"
if ! grep -q "^\[Seat:\*\]" "$TMP"; then
  printf "\n[Seat:*]\n" >> "$TMP"
fi
sed -i "/^\[Seat:\*\]/a autologin-user=$USER_NAME\nautologin-user-timeout=0" "$TMP"
sudo tee "$CONF" < "$TMP" >/dev/null
;;
esac
fi
if dpkg -s kwalletmanager &>/dev/null; then
  if [[ ! -f ~/.config/kwalletrc ]]; then
    touch ~/.config/kwalletrc
  else
    sed -i '/Enabled=/d' ~/.config/kwalletrc
  fi
  if ! grep -q "^\[Wallet\]" ~/.config/kwalletrc; then
    printf "\n[Wallet]\n" >> ~/.config/kwalletrc
  fi
  sed -i "/^\[Wallet\]/a Enabled=false" ~/.config/kwalletrc
fi
sudo timedatectl set-local-rtc 1
sudo timedatectl set-ntp true
sudo apt update
sudo apt install software-properties-common -y
sudo add-apt-repository universe -y
sudo add-apt-repository multiverse -y
sudo add-apt-repository restricted -y
sudo add-apt-repository ppa:bkryza/clang-uml -y
sudo add-apt-repository ppa:fdroid/fdroidserver -y
sudo apt-add-repository ppa:flexiondotorg/quickemu -y
sudo add-apt-repository ppa:libreoffice/ppa -y
sudo add-apt-repository ppa:longsleep/golang-backports -y
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo add-apt-repository ppa:obsproject/obs-studio -y
sudo add-apt-repository ppa:stefanberger/swtpm-noble -y
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
bash <<'EOF'
set -e
f=/etc/apt/sources.list.d/ubuntu.sources
if [ -f "$f" ] && grep -q "^Types:.*deb" "$f"; then
  sudo sed -i 's/^Types: *deb.*/Types: deb deb-src/' "$f"
fi
EOF
sudo apt update
sudo apt purge fcitx* texlive* -y
sudo apt install wget -y
rm -f .bashrc
mkdir ~/.bashrc.d
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/00-env.sh -O ~/.bashrc.d/00-env.sh
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/10-exports.sh -O ~/.bashrc.d/10-exports.sh
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/15-color.sh -O ~/.bashrc.d/15-color.sh
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/20-aliases.sh -O ~/.bashrc.d/20-aliases.sh
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/21-cxx.sh -O ~/.bashrc.d/21-cxx.sh
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/22-java.sh -O ~/.bashrc.d/22-java.sh
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/23-vnc.sh -O ~/.bashrc.d/23-vnc.sh
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/24-launchers.sh -O ~/.bashrc.d/24-launchers.sh
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/50-functions.sh -O ~/.bashrc.d/50-functions.sh
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/60-completion.sh -O ~/.bashrc.d/60-completion.sh
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/bashrc.sh -O ~/.bashrc
cat > ~/.profile <<'EOF'
if [ -n "$BASH_VERSION" ]; then
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi
EOF
if [ -d "$HOME/.bashrc.d"  ];  then
  for f in "$HOME/.bashrc.d/"*; do
    [ -r "$f"  ] && . "$f"
  done
fi
sudo mkdir -p /usr/local/go
sudo mkdir -p /usr/local/java
sudo mkdir -p /etc/apt/keyrings
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/applications
mkdir -p ~/Desktop
mkdir -p ~/.config/systemd/user
if ! grep -q '^NAME="Linux Mint"' /etc/os-release; then
sudo add-apt-repository ppa:mozillateam/ppa -y
echo 'Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: firefox*
Pin: release o=Ubuntu
Pin-Priority: -1' | sudo tee /etc/apt/preferences.d/firefox
sudo rm -f /etc/apparmor.d/usr.bin.firefox
sudo rm -f /etc/apparmor.d/local/usr.bin.firefox
sudo systemctl stop var-snap-firefox-common-*.mount 2>/dev/null || true
sudo systemctl disable var-snap-firefox-common-*.mount 2>/dev/null || true
sudo systemctl disable snap-firefox*.mount 2>/dev/null || true
sudo snap remove firefox 2>/dev/null || true
sudo apt install firefox --allow-downgrades -y
sudo ln -sf /etc/apparmor.d/firefox /etc/apparmor.d/disable/
sudo apparmor_parser -R /etc/apparmor.d/firefox
sudo rm /var/lib/snapd/desktop/applications/firefox*.desktop 2>/dev/null || true
sudo rm /var/lib/snapd/inhibit/firefox.lock 2>/dev/null || true
rm -r snap/firefox 2>/dev/null || true
echo 'Package: thunderbird*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: thunderbird*
Pin: release o=Ubuntu
Pin-Priority: -1' | sudo tee /etc/apt/preferences.d/thunderbird
sudo rm -f /etc/apparmor.d/usr.bin.thunderbird
sudo rm -f /etc/apparmor.d/local/usr.bin.thunderbird
sudo systemctl stop var-snap-thunderbird-common-*.mount 2>/dev/null || true
sudo systemctl disable var-snap-thunderbird-common-*.mount 2>/dev/null || true
sudo systemctl disable snap-thunderbird*.mount 2>/dev/null || true
sudo snap remove thunderbird 2>/dev/null || true
sudo apt install thunderbird --allow-downgrades -y
sudo rm /var/lib/snapd/desktop/applications/thunderbird*.desktop 2>/dev/null || true
echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:$(lsb_release -cs)";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-mozilla
sudo add-apt-repository ppa:xtradeb/apps -y
echo 'Package: chromium*
Pin: release o=LP-PPA-xtradeb-apps
Pin-Priority: 1001

Package: chromium*
Pin: release o=Ubuntu
Pin-Priority: -1' | sudo tee /etc/apt/preferences.d/chromium
sudo apt update
sudo apt install chromium -y
fi
echo y | sudo ubuntu-drivers install || true
echo y | sudo ubuntu-drivers install || true
echo y | sudo ubuntu-drivers install || true
echo y | sudo ubuntu-drivers autoinstall || true
echo y | sudo ubuntu-drivers autoinstall || true
echo y | sudo ubuntu-drivers autoinstall || true
sudo apt upgrade -y
sudo apt install abcde alien alsa-utils apksigner apt-transport-https aptitude audacity autoconf automake bash bc bear bindfs bison bookletimposer build-essential bzip2 caneda ca-certificates clang clangd clang-format cmake command-not-found curl dbus debian-archive-keyring debian-keyring default-jdk dmg2img dnsutils dvisvgm fastfetch ffmpeg file flex fonts-cns11643-kai fonts-cns11643-sung fonts-liberation fonts-noto-cjk fonts-noto-cjk-extra g++ gcc gdb gfortran gh ghc ghostscript git glab gnupg golang-go gopls gperf gpg grep gtkwave gzip info imagemagick inkscape iproute2 iverilog jpegoptim jq libboost-all-dev libbz2-dev libconfig-dev libeigen3-dev libffi-dev libfuse2 libgdbm-compat-dev libgdbm-dev libgsl-dev libguestfs-tools libheif-examples libhwloc-dev libhwloc-plugins libllvm19 liblzma-dev libncursesw5-dev libopenblas-dev libosmesa6 libportaudio2 libqt5svg5-dev libreadline-dev libreoffice libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-net-dev libsdl2-ttf-dev libsqlite3-dev libssl-dev libuv1t64 libuv1-dev libxml2-dev libxmlsec1-dev libzip-dev libzstd-dev llvm lzip make maven mc nano ncompress neovim netcat-openbsd ngspice ninja-build nmap octave openjdk-21-jdk openssh-client openssh-server openssl optipng pandoc perl perl-doc perl-tk pipx plantuml poppler-utils procps pv python-is-python3 python3-all-dev python3-httpx python3-jinja2 python3-neovim python3-requests python3-pip python3-venv qpdf qtbase5-dev qtbase5-dev-tools rust-all socat sqlite3 sudo tar tk-dev tmux tree ttf-mscorefonts-installer unzip uuid-dev uuid-runtime valgrind verilator vim webp wget wget2 x11-utils x11-xserver-utils xdotool xmlstarlet xz-utils zip zlib1g zlib1g-dev zsh zstd -y
sudo apt install apparmor-utils aria2 bridge-utils clang-uml clinfo codeblocks* dnscrypt-proxy dunst fcitx5 fcitx5-* fdroidserver filelight flatpak gir1.2-gdk-3.0 gir1.2-gtk-3.0 gnome-keyring gparted kate libspa-0.2-bluetooth libtesseract-dev libvirt-daemon-system libvirt-clients msr-tools ntfs-3g obs-studio ocl-icd-opencl-dev opencl-headers openjdk-8-jdk openjdk-17-jdk ovmf pipewire pipewire-audio-client-libraries podman python3-aiortc python3-gi python3-gi-cairo python3-plyer python3-pystray python3-websocket python3-xxhash qbittorrent qemu-kvm qemu-system qemu-user-static qtspeech5-speechd-plugin quickemu quickgui snapd spice-vdagent swtpm swtpm-tools tesseract-ocr-all testdisk torbrowser-launcher uidmap update-manager-core vim-gtk3 virt-manager virt-viewer wireplumber wl-clipboard xclip -y
sudo cp /usr/share/doc/dnscrypt-proxy/examples/* /etc/dnscrypt-proxy/
sudo mkdir -p /usr/share/dnscrypt-proxy/utils/generate-domains-blocklist
cd /usr/share/dnscrypt-proxy/utils/generate-domains-blocklist
sudo rm -f generate-domains-blocklist.py || true
sudo wget https://raw.githubusercontent.com/DNSCrypt/dnscrypt-proxy/refs/heads/master/utils/generate-domains-blocklist/generate-domains-blocklist.py
sudo tee /usr/share/dnscrypt-proxy/utils/generate-domains-blocklist/domains-blocklist.conf >/dev/null <<'EOF'
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
EOF
sudo tee /etc/systemd/system/dnscrypt-filterlist-update.service >/dev/null <<'EOF'
[Unit]
Description=DNSCrypt Filterlist Update

[Service]
Type=oneshot
User=root
WorkingDirectory=/usr/share/dnscrypt-proxy/utils/generate-domains-blocklist/
ExecStart=/bin/python3 generate-domains-blocklist.py -o blocklist.txt ; sleep 2 ; systemctl restart dnscrypt-proxy.service

[Install]
WantedBy=multi-user.target
EOF
sudo tee /etc/systemd/system/dnscrypt-filterlist-update.timer >/dev/null <<'EOF'
[Unit]
Description=Run 15min after boot and every 5 hours (DNSCrypt Filterlist Update)

[Timer]
OnBootSec=15min
OnUnitActiveSec=5h

[Install]
WantedBy=timers.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now dnscrypt-filterlist-update.service
sudo systemctl enable dnscrypt-filterlist-update.timer
cd /etc/dnscrypt-proxy
sudo tee /etc/dnscrypt-proxy/dnscrypt-proxy.toml >/dev/null <<'EOF'

##############################################
#                                            #
#        dnscrypt-proxy configuration        #
#                                            #
##############################################

## This is an example configuration file.
## You should adjust it to your needs, and save it as "dnscrypt-proxy.toml"
##
## Online documentation is available here: https://dnscrypt.info/doc



##################################
#         Global settings        #
##################################

## List of servers to use
##
## Servers from the "public-resolvers" source (see down below) can
## be viewed here: https://dnscrypt.info/public-servers
##
## The proxy will automatically pick working servers from this list.
## Note that the require_* filters do NOT apply when using this setting.
##
## By default, this list is empty and all registered servers matching the
## require_* filters will be used instead.
##
## Remove the leading # first to enable this; lines starting with # are ignored.

server_names = ['cloudflare', 'cloudflare-ipv6', 'adguard-dns-unfiltered-doh', 'adguard-dns-unfiltered-doh-ipv6']


## List of local addresses and ports to listen to. Can be IPv4 and/or IPv6.
## Example with both IPv4 and IPv6:
## listen_addresses = ['127.0.0.1:53', '[::1]:53']

listen_addresses = ['127.0.0.1:53']


## Maximum number of simultaneous client connections to accept

max_clients = 250


## Switch to a different system user after listening sockets have been created.
## Note (1): this feature is currently unsupported on Windows.
## Note (2): this feature is not compatible with systemd socket activation.
## Note (3): when using -pidfile, the PID file directory must be writable by the new user

# user_name = 'nobody'


## Require servers (from static + remote sources) to satisfy specific properties

# Use servers reachable over IPv4
ipv4_servers = true

# Use servers reachable over IPv6 -- Do not enable if you don't have IPv6 connectivity
ipv6_servers = false

# Use servers implementing the DNSCrypt protocol
dnscrypt_servers = true

# Use servers implementing the DNS-over-HTTPS protocol
doh_servers = true


## Require servers defined by remote sources to satisfy specific properties

# Server must support DNS security extensions (DNSSEC)
require_dnssec = false

# Server must not log user queries (declarative)
require_nolog = true

# Server must not enforce its own blocklist (for parental control, ads blocking...)
require_nofilter = true

# Server names to avoid even if they match all criteria
disabled_server_names = []


## Always use TCP to connect to upstream servers.
## This can be useful if you need to route everything through Tor.
## Otherwise, leave this to `false`, as it doesn't improve security
## (dnscrypt-proxy will always encrypt everything even using UDP), and can
## only increase latency.

force_tcp = false


## SOCKS proxy
## Uncomment the following line to route all TCP connections to a local Tor node
## Tor doesn't support UDP, so set `force_tcp` to `true` as well.

# proxy = 'socks5://127.0.0.1:9050'


## HTTP/HTTPS proxy
## Only for DoH servers

# http_proxy = 'http://127.0.0.1:8888'


## How long a DNS query will wait for a response, in milliseconds.
## If you have a network with *a lot* of latency, you may need to
## increase this. Startup may be slower if you do so.
## Don't increase it too much. 10000 is the highest reasonable value.

timeout = 5000


## Keepalive for HTTP (HTTPS, HTTP/2) queries, in seconds

keepalive = 30


## Add EDNS-client-subnet information to outgoing queries
##
## Multiple networks can be listed; they will be randomly chosen.
## These networks don't have to match your actual networks.

# edns_client_subnet = ["0.0.0.0/0", "2001:db8::/32"]


## Response for blocked queries. Options are `refused`, `hinfo` (default) or
## an IP response. To give an IP response, use the format `a:<IPv4>,aaaa:<IPv6>`.
## Using the `hinfo` option means that some responses will be lies.
## Unfortunately, the `hinfo` option appears to be required for Android 8+

# blocked_query_response = 'refused'


## Load-balancing strategy: 'p2' (default), 'ph', 'p<n>', 'first' or 'random'
## Randomly choose 1 of the fastest 2, half, n, 1 or all live servers by latency.
## The response quality still depends on the server itself.

# lb_strategy = 'p2'

## Set to `true` to constantly try to estimate the latency of all the resolvers
## and adjust the load-balancing parameters accordingly, or to `false` to disable.
## Default is `true` that makes 'p2' `lb_strategy` work well.

# lb_estimator = true


## Log level (0-6, default: 2 - 0 is very verbose, 6 only contains fatal errors)

# log_level = 2


## Log file for the application, as an alternative to sending logs to
## the standard system logging service (syslog/Windows event log).
##
## This file is different from other log files, and will not be
## automatically rotated by the application.

# log_file = 'dnscrypt-proxy.log'


## When using a log file, only keep logs from the most recent launch.

# log_file_latest = true


## Use the system logger (syslog on Unix, Event Log on Windows)

# use_syslog = true


## Delay, in minutes, after which certificates are reloaded

cert_refresh_delay = 240


## DNSCrypt: Create a new, unique key for every single DNS query
## This may improve privacy but can also have a significant impact on CPU usage
## Only enable if you don't have a lot of network load

# dnscrypt_ephemeral_keys = false


## DoH: Disable TLS session tickets - increases privacy but also latency

# tls_disable_session_tickets = false


## DoH: Use a specific cipher suite instead of the server preference
## 49199 = TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
## 49195 = TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
## 52392 = TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305
## 52393 = TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305
##  4865 = TLS_AES_128_GCM_SHA256
##  4867 = TLS_CHACHA20_POLY1305_SHA256
##
## On non-Intel CPUs such as MIPS routers and ARM systems (Android, Raspberry Pi...),
## the following suite improves performance.
## This may also help on Intel CPUs running 32-bit operating systems.
##
## Keep tls_cipher_suite empty if you have issues fetching sources or
## connecting to some DoH servers. Google and Cloudflare are fine with it.

# tls_cipher_suite = [52392, 49199]


## Fallback resolvers
## These are normal, non-encrypted DNS resolvers, that will be only used
## for one-shot queries when retrieving the initial resolvers list, and
## only if the system DNS configuration doesn't work.
##
## No user application queries will ever be leaked through these resolvers,
## and they will not be used after IP addresses of resolvers URLs have been found.
## They will never be used if lists have already been cached, and if stamps
## don't include host names without IP addresses.
##
## They will not be used if the configured system DNS works.
## Resolvers supporting DNSSEC are recommended, and, if you are using
## DoH, fallback resolvers should ideally be operated by a different entity than
## the DoH servers you will be using, especially if you have IPv6 enabled.
##
## People in China may need to use 114.114.114.114:53 here.
## Other popular options include 8.8.8.8 and 1.1.1.1.
##
## If more than one resolver is specified, they will be tried in sequence.

fallback_resolvers = ['1.1.1.1:53', '1.0.0.1:53', '2606:4700:4700::1111:53', '2606:4700:4700::1001:53', '94.140.14.140:53', '94.140.14.141:53', '2a10:50c0::1:ff:53', '2a10:50c0::2:ff:53']


## Always use the fallback resolver before the system DNS settings.

ignore_system_dns = false


## Maximum time (in seconds) to wait for network connectivity before
## initializing the proxy.
## Useful if the proxy is automatically started at boot, and network
## connectivity is not guaranteed to be immediately available.
## Use 0 to not test for connectivity at all (not recommended),
## and -1 to wait as much as possible.

netprobe_timeout = 60

## Address and port to try initializing a connection to, just to check
## if the network is up. It can be any address and any port, even if
## there is nothing answering these on the other side. Just don't use
## a local address, as the goal is to check for Internet connectivity.
## On Windows, a datagram with a single, nul byte will be sent, only
## when the system starts.
## On other operating systems, the connection will be initialized
## but nothing will be sent at all.

netprobe_address = '1.1.1.1:53'


## Offline mode - Do not use any remote encrypted servers.
## The proxy will remain fully functional to respond to queries that
## plugins can handle directly (forwarding, cloaking, ...)

# offline_mode = false


## Additional data to attach to outgoing queries.
## These strings will be added as TXT records to queries.
## Do not use, except on servers explicitly asking for extra data
## to be present.
## encrypted-dns-server can be configured to use this for access control
## in the [access_control] section

# query_meta = ['key1:value1', 'key2:value2', 'token:MySecretToken']


## Automatic log files rotation

# Maximum log files size in MB - Set to 0 for unlimited.
log_files_max_size = 10

# How long to keep backup files, in days
log_files_max_age = 7

# Maximum log files backups to keep (or 0 to keep all backups)
log_files_max_backups = 1



#########################
#        Filters        #
#########################

## Note: if you are using dnsmasq, disable the `dnssec` option in dnsmasq if you
## configure dnscrypt-proxy to do any kind of filtering (including the filters
## below and blocklists).
## You can still choose resolvers that do DNSSEC validation.


## Immediately respond to IPv6-related queries with an empty response
## This makes things faster when there is no IPv6 connectivity, but can
## also cause reliability issues with some stub resolvers.

block_ipv6 = false


## Immediately respond to A and AAAA queries for host names without a domain name

block_unqualified = true


## Immediately respond to queries for local zones instead of leaking them to
## upstream resolvers (always causing errors or timeouts).

block_undelegated = false


## TTL for synthetic responses sent when a request has been blocked (due to
## IPv6 or blocklists).

reject_ttl = 600



##################################################################################
#        Route queries for specific domains to a dedicated set of servers        #
##################################################################################

## See the `example-forwarding-rules.txt` file for an example

# forwarding_rules = 'forwarding-rules.txt'



###############################
#        Cloaking rules       #
###############################

## Cloaking returns a predefined address for a specific name.
## In addition to acting as a HOSTS file, it can also return the IP address
## of a different name. It will also do CNAME flattening.
##
## See the `example-cloaking-rules.txt` file for an example

# cloaking_rules = 'cloaking-rules.txt'

## TTL used when serving entries in cloaking-rules.txt

# cloak_ttl = 600



###########################
#        DNS cache        #
###########################

## Enable a DNS cache to reduce latency and outgoing traffic

cache = true


## Cache size

cache_size = 4096


## Minimum TTL for cached entries

cache_min_ttl = 2400


## Maximum TTL for cached entries

cache_max_ttl = 86400


## Minimum TTL for negatively cached entries

cache_neg_min_ttl = 60


## Maximum TTL for negatively cached entries

cache_neg_max_ttl = 600



########################################
#        Captive portal handling       #
########################################

[captive_portals]

## A file that contains a set of names used by operating systems to
## check for connectivity and captive portals, along with hard-coded
## IP addresses to return.

# map_file = 'example-captive-portals.txt'



##################################
#        Local DoH server        #
##################################

[local_doh]

## dnscrypt-proxy can act as a local DoH server. By doing so, web browsers
## requiring a direct connection to a DoH server in order to enable some
## features will enable these, without bypassing your DNS proxy.

## Addresses that the local DoH server should listen to

# listen_addresses = ['127.0.0.1:3000']


## Path of the DoH URL. This is not a file, but the part after the hostname
## in the URL. By convention, `/dns-query` is frequently chosen.
## For each `listen_address` the complete URL to access the server will be:
## `https://<listen_address><path>` (ex: `https://127.0.0.1/dns-query`)

# path = '/dns-query'


## Certificate file and key - Note that the certificate has to be trusted.
## See the documentation (wiki) for more information.

# cert_file = 'localhost.pem'
# cert_key_file = 'localhost.pem'



###############################
#        Query logging        #
###############################

## Log client queries to a file

[query_log]

  ## Path to the query log file (absolute, or relative to the same directory as the config file)
  ## Can be set to /dev/stdout in order to log to the standard output.

  # file = 'query.log'


  ## Query log format (currently supported: tsv and ltsv)

  format = 'tsv'


  ## Do not log these query types, to reduce verbosity. Keep empty to log everything.

  # ignored_qtypes = ['DNSKEY', 'NS']



############################################
#        Suspicious queries logging        #
############################################

## Log queries for nonexistent zones
## These queries can reveal the presence of malware, broken/obsolete applications,
## and devices signaling their presence to 3rd parties.

[nx_log]

  ## Path to the query log file (absolute, or relative to the same directory as the config file)

  # file = 'nx.log'


  ## Query log format (currently supported: tsv and ltsv)

  format = 'tsv'



######################################################
#        Pattern-based blocking (blocklists)        #
######################################################

## Blocklists are made of one pattern per line. Example of valid patterns:
##
##   example.com
##   =example.com
##   *sex*
##   ads.*
##   ads*.example.*
##   ads*.example[0-9]*.com
##
## Example blocklist files can be found at https://download.dnscrypt.info/blocklists/
## A script to build blocklists from public feeds can be found in the
## `utils/generate-domains-blocklists` directory of the dnscrypt-proxy source code.

[blocked_names]

  ## Path to the file of blocking rules (absolute, or relative to the same directory as the config file)

  blocked_names_file = '/usr/share/dnscrypt-proxy/utils/generate-domains-blocklist/blocklist.txt'
  log_file = '/var/log/dnscrypt-proxy/blocked-names.log'


  ## Optional path to a file logging blocked queries

  # log_file = 'blocked-names.log'


  ## Optional log format: tsv or ltsv (default: tsv)

  # log_format = 'tsv'



###########################################################
#        Pattern-based IP blocking (IP blocklists)        #
###########################################################

## IP blocklists are made of one pattern per line. Example of valid patterns:
##
##   127.*
##   fe80:abcd:*
##   192.168.1.4

[blocked_ips]

  ## Path to the file of blocking rules (absolute, or relative to the same directory as the config file)

  # blocked_ips_file = 'blocked-ips.txt'


  ## Optional path to a file logging blocked queries

  # log_file = 'blocked-ips.log'


  ## Optional log format: tsv or ltsv (default: tsv)

  # log_format = 'tsv'



######################################################
#   Pattern-based allow lists (blocklists bypass)   #
######################################################

## Allowlists support the same patterns as blocklists
## If a name matches an allowlist entry, the corresponding session
## will bypass names and IP filters.
##
## Time-based rules are also supported to make some websites only accessible at specific times of the day.

[allowed_names]

  ## Path to the file of allow list rules (absolute, or relative to the same directory as the config file)

  # allowed_names_file = 'allowed-names.txt'


  ## Optional path to a file logging allowed queries

  # log_file = 'allowed-names.log'


  ## Optional log format: tsv or ltsv (default: tsv)

  # log_format = 'tsv'



#########################################################
#   Pattern-based allowed IPs lists (blocklists bypass) #
#########################################################

## Allowed IP lists support the same patterns as IP blocklists
## If an IP response matches an allow ip entry, the corresponding session
## will bypass IP filters.
##
## Time-based rules are also supported to make some websites only accessible at specific times of the day.

[allowed_ips]

  ## Path to the file of allowed ip rules (absolute, or relative to the same directory as the config file)

  # allowed_ips_file = 'allowed-ips.txt'


  ## Optional path to a file logging allowed queries

  # log_file = 'allowed-ips.log'

  ## Optional log format: tsv or ltsv (default: tsv)

  # log_format = 'tsv'



##########################################
#        Time access restrictions        #
##########################################

## One or more weekly schedules can be defined here.
## Patterns in the name-based blocked_names file can optionally be followed with @schedule_name
## to apply the pattern 'schedule_name' only when it matches a time range of that schedule.
##
## For example, the following rule in a blocklist file:
## *.youtube.* @time-to-sleep
## would block access to YouTube during the times defined by the 'time-to-sleep' schedule.
##
## {after='21:00', before= '7:00'} matches 0:00-7:00 and 21:00-0:00
## {after= '9:00', before='18:00'} matches 9:00-18:00

[schedules]

  # [schedules.'time-to-sleep']
  # mon = [{after='21:00', before='7:00'}]
  # tue = [{after='21:00', before='7:00'}]
  # wed = [{after='21:00', before='7:00'}]
  # thu = [{after='21:00', before='7:00'}]
  # fri = [{after='23:00', before='7:00'}]
  # sat = [{after='23:00', before='7:00'}]
  # sun = [{after='21:00', before='7:00'}]

  # [schedules.'work']
  # mon = [{after='9:00', before='18:00'}]
  # tue = [{after='9:00', before='18:00'}]
  # wed = [{after='9:00', before='18:00'}]
  # thu = [{after='9:00', before='18:00'}]
  # fri = [{after='9:00', before='17:00'}]



#########################
#        Servers        #
#########################

## Remote lists of available servers
## Multiple sources can be used simultaneously, but every source
## requires a dedicated cache file.
##
## Refer to the documentation for URLs of public sources.
##
## A prefix can be prepended to server names in order to
## avoid collisions if different sources share the same for
## different servers. In that case, names listed in `server_names`
## must include the prefixes.
##
## If the `urls` property is missing, cache files and valid signatures
## must already be present. This doesn't prevent these cache files from
## expiring after `refresh_delay` hours.
## Cache freshness is checked every 24 hours, so values for 'refresh_delay'
## of less than 24 hours will have no effect.
## A maximum delay of 168 hours (1 week) is imposed to ensure cache freshness.

[sources]

  ## An example of a remote source from https://github.com/DNSCrypt/dnscrypt-resolvers

  [sources.'public-resolvers']
  urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md', 'https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md', 'https://ipv6.download.dnscrypt.info/resolvers-list/v3/public-resolvers.md', 'https://download.dnscrypt.net/resolvers-list/v3/public-resolvers.md']
  cache_file = 'public-resolvers.md'
  minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
  refresh_delay = 72
  prefix = ''

  ## Anonymized DNS relays

  [sources.'relays']
  urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/relays.md', 'https://download.dnscrypt.info/resolvers-list/v3/relays.md', 'https://ipv6.download.dnscrypt.info/resolvers-list/v3/relays.md', 'https://download.dnscrypt.net/resolvers-list/v3/relays.md']
  cache_file = 'relays.md'
  minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
  refresh_delay = 72
  prefix = ''

  ## Quad9 over DNSCrypt - https://quad9.net/

  # [sources.quad9-resolvers]
  # urls = ['https://www.quad9.net/quad9-resolvers.md']
  # minisign_key = 'RWQBphd2+f6eiAqBsvDZEBXBGHQBJfeG6G+wJPPKxCZMoEQYpmoysKUN'
  # cache_file = 'quad9-resolvers.md'
  # prefix = 'quad9-'

  ## Another example source, with resolvers censoring some websites not appropriate for children
  ## This is a subset of the `public-resolvers` list, so enabling both is useless

  #  [sources.'parental-control']
  #  urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/parental-control.md', 'https://download.dnscrypt.info/resolvers-list/v3/parental-control.md', 'https://ipv6.download.dnscrypt.info/resolvers-list/v3/parental-control.md', 'https://download.dnscrypt.net/resolvers-list/v3/parental-control.md']
  #  cache_file = 'parental-control.md'
  #  minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'



#########################################
#        Servers with known bugs        #
#########################################

[broken_implementations]

# Cisco servers currently cannot handle queries larger than 1472 bytes, and don't
# truncate reponses larger than questions as expected by the DNSCrypt protocol.
# This prevents large responses from being received over UDP and over relays.
#
# Older versions of the `dnsdist` server software had a bug with queries larger
# than 1500 bytes. This is fixed since `dnsdist` version 1.5.0, but
# some server may still run an outdated version.
#
# The list below enables workarounds to make non-relayed usage more reliable
# until the servers are fixed.

fragments_blocked = ['cisco', 'cisco-ipv6', 'cisco-familyshield', 'cisco-familyshield-ipv6', 'cleanbrowsing-adult', 'cleanbrowsing-adult-ipv6', 'cleanbrowsing-family', 'cleanbrowsing-family-ipv6', 'cleanbrowsing-security', 'cleanbrowsing-security-ipv6']



#################################################################
#        Certificate-based client authentication for DoH        #
#################################################################

# Use a X509 certificate to authenticate yourself when connecting to DoH servers.
# This is only useful if you are operating your own, private DoH server(s).
# 'creds' maps servers to certificates, and supports multiple entries.
# If you are not using the standard root CA, an optional "root_ca"
# property set to the path to a root CRT file can be added to a server entry.

[doh_client_x509_auth]

#
# creds = [
#    { server_name='myserver', client_cert='client.crt', client_key='client.key' }
# ]



################################
#        Anonymized DNS        #
################################

[anonymized_dns]

## Routes are indirect ways to reach DNSCrypt servers.
##
## A route maps a server name ("server_name") to one or more relays that will be
## used to connect to that server.
##
## A relay can be specified as a DNS Stamp (either a relay stamp, or a
## DNSCrypt stamp) or a server name.
##
## The following example routes "example-server-1" via `anon-example-1` or `anon-example-2`,
## and "example-server-2" via the relay whose relay DNS stamp is
## "sdns://gRIxMzcuNzQuMjIzLjIzNDo0NDM".
##
## !!! THESE ARE JUST EXAMPLES !!!
##
## Review the list of available relays from the "relays.md" file, and, for each
## server you want to use, define the relays you want connections to go through.
##
## Carefully choose relays and servers so that they are run by different entities.
##
## "server_name" can also be set to "*" to define a default route, for all servers:
## { server_name='*', via=['anon-example-1', 'anon-example-2'] }
##
## If a route is ["*"], the proxy automatically picks a relay on a distinct network.
## { server_name='*', via=['*'] } is also an option, but is likely to be suboptimal.
##
## Manual selection is always recommended over automatic selection, so that you can
## select (relay,server) pairs that work well and fit your own criteria (close by or
## in different countries, operated by different entities, on distinct ISPs...)

# routes = [
#    { server_name='example-server-1', via=['anon-example-1', 'anon-example-2'] },
#    { server_name='example-server-2', via=['sdns://gRIxMzcuNzQuMjIzLjIzNDo0NDM'] }
# ]


# Skip resolvers incompatible with anonymization instead of using them directly

skip_incompatible = false


# If public server certificates for a non-conformant server cannot be
# retrieved via a relay, try getting them directly. Actual queries
# will then always go through relays.

# direct_cert_fallback = false



###############################
#            DNS64            #
###############################

## DNS64 is a mechanism for synthesizing AAAA records from A records.
## It is used with an IPv6/IPv4 translator to enable client-server
## communication between an IPv6-only client and an IPv4-only server,
## without requiring any changes to either the IPv6 or the IPv4 node,
## for the class of applications that work through NATs.
##
## There are two options to synthesize such records:
## Option 1: Using a set of static IPv6 prefixes;
## Option 2: By discovering the IPv6 prefix from DNS64-enabled resolver.
##
## If both options are configured - only static prefixes are used.
## (Ref. RFC6147, RFC6052, RFC7050)
##
## Do not enable unless you know what DNS64 is and why you need it, or else
## you won't be able to connect to anything at all.

[dns64]

## (Option 1) Static prefix(es) as Pref64::/n CIDRs.
# prefix = ['64:ff9b::/96']

## (Option 2) DNS64-enabled resolver(s) to discover Pref64::/n CIDRs.
## These resolvers are used to query for Well-Known IPv4-only Name (WKN) "ipv4only.arpa." to discover only.
## Set with your ISP's resolvers in case of custom prefixes (other than Well-Known Prefix 64:ff9b::/96).
## IMPORTANT: Default resolvers listed below support Well-Known Prefix 64:ff9b::/96 only.
# resolver = ['[2606:4700:4700::64]:53', '[2001:4860:4860::64]:53']



########################################
#            Static entries            #
########################################

## Optional, local, static list of additional servers
## Mostly useful for testing your own servers.

[static]

  # [static.'myserver']
  # stamp = 'sdns://AQcAAAAAAAAAAAAQMi5kbnNjcnlwdC1jZXJ0Lg'
EOF
sudo dnscrypt-proxy -service install
sudo dnscrypt-proxy -service start
cd ~
sudo tee /etc/systemd/resolved.conf >/dev/null <<'EOF'
[Resolve]
DNS=127.0.0.1
EOF
sudo systemctl restart systemd-resolved
systemctl --user restart pipewire pipewire-pulse wireplumber
sudo ln -s /usr/lib/python3/dist-packages/Cryptodome /usr/lib/python3/dist-packages/Crypto
sudo mkdir -p /usr/share/codeblocks/docs
im-config -n fcitx5
cat > ~/.xprofile <<'EOF'
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export INPUT_METHOD=fcitx
export SDL_IM_MODULE=fcitx
export GLFW_IM_MODULE=ibus
EOF
if [ "$XDG_CURRENT_DESKTOP" = "KDE" ] || [ "$DESKTOP_SESSION" = "plasma" ] || [ "$KDE_FULL_SESSION" = "true" ]; then
  sudo apt install plasma-discover-backend-flatpak -y
else
  mkdir -p ~/.config/autostart
  cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart/
  fcitx5 &
fi
wget --tries=100 --retry-connrefused --waitretry=5 -O sdl2_bgi_3.0.4-1_amd64.deb https://sourceforge.net/projects/sdl-bgi/files/sdl2_bgi_3.0.4-1_amd64.deb/download
sudo apt install ./sdl2_bgi_3.0.4-1_amd64.deb -y
rm sdl2_bgi_3.0.4-1_amd64.deb
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo mkdir -p /run/sshd
sudo chmod 0755 /run/sshd
sudo chown root:root /run/sshd
sudo systemctl enable ssh
yes | sudo ufw enable
sudo ufw allow ssh
sudo ufw reload
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
sudo apt update
sudo apt install brave-browser -y
wget -qO - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo tee /etc/apt/keyrings/google.asc >/dev/null
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google.asc] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list'
sudo apt update
sudo apt install google-chrome-stable -y
json="$(curl -fsSL https://api.github.com/repos/xlionjuan/xlion-repo-archive-keyring/releases/latest)" && asset="$(echo "$json" | jq -r '.assets[] | select(.name | endswith(".deb")) | "\(.browser_download_url) \(.digest)"' | head -n1)" && url="${asset%% *}" && digest="${asset##* }" && [ -n "$url" ] && [ "$url" != "null" ] && [ -n "$digest" ] && [ "$digest" != "null" ] || { echo "ERROR: cannot locate .deb asset or SHA256 digest" >&2; return 1 2>/dev/null || false; } && tmpfile="$(mktemp /tmp/xlion-keyring-XXXXXX.deb)" && curl -fL "$url" -o "$tmpfile" || { echo "ERROR: download failed" >&2; return 1 2>/dev/null || false; } && expected="${digest#*:}" && actual="$(sha256sum "$tmpfile" | awk '{print $1}')" && [ "$actual" = "$expected" ] || { echo "ERROR: SHA256 mismatch" >&2; rm -f "$tmpfile"; return 1 2>/dev/null || false; } && sudo dpkg -i "$tmpfile" && rm -f "$tmpfile"
curl -fsSL https://xlionjuan.github.io/rustdesk-apt-repo-latest/latest.sources | sudo tee /etc/apt/sources.list.d/xlion-rustdesk-repo.source
sudo apt install rustdesk rustdesk-server -y
sudo ufw allow 21118/udp
sudo ufw allow 21118/tcp
sudo ufw allow 21115:21119/tcp
sudo ufw allow 21116/udp
sudo ufw reload
PROFILE=/dev/null bash -c 'curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install --lts
corepack enable npm
corepack enable yarn
corepack enable pnpm
npm install jsdom markdown-toc marked marked-gfm-heading-id node-html-markdown showdown
npm install -g bash-language-server dockerfile-language-server-nodejs http-server pyright tree-sitter-cli
curl --retry 100 --retry-connrefused --retry-delay 5 -fsSL https://bun.com/install | bash
pipx install cmake-language-server gh2md libretranslate notebook jupyterlab jupytext meson poetry pylatexenc uv
cat > ~/.config/systemd/user/libretranslate.service <<EOF
[Unit]
Description=LibreTranslate

[Service]
ExecStart=$HOME/.local/bin/libretranslate
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now libretranslate
uv tool install --force --python python3.11 open-webui@latest
cat > ~/.config/systemd/user/open-webui.service <<EOF
[Unit]
Description=Open WebUI

[Service]
ExecStart=$HOME/.local/bin/open-webui serve
Environment=DATA_DIR=$HOME/.open-webui
Environment=OLLAMA_BASE_URL=http://127.0.0.1:11434
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now open-webui
wget --tries=100 --retry-connrefused --waitretry=5 https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh -b -p ${HOME}/conda
rm Miniforge3-Linux-x86_64.sh
export MAMBA_ROOT_PREFIX="${HOME}/conda"
source "${HOME}/conda/etc/profile.d/conda.sh" 2>/dev/null || true
source "${HOME}/conda/etc/profile.d/mamba.sh" 2>/dev/null || true
conda config --set auto_activate_base false
conda config --add channels bioconda
conda config --add channels pypi
conda config --add channels pytorch
conda config --add channels microsoft
conda config --add channels defaults
conda config --add channels conda-forge
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
brew install gurgeous/tap/tennis
sudo git clone --depth=1 https://github.com/Willie169/vimrc.git /opt/vim_runtime && sudo sh /opt/vim_runtime/install_awesome_parameterized.sh /opt/vim_runtime --all
mkdir -p ~/.config/nvim/lua/config
mkdir -p ~/.config/nvim/lua/plugins
cat > ~/.config/nvim/init.lua <<'EOF'
vim.cmd("set runtimepath^=~/.vim runtimepath+=~/.vim/after")
vim.cmd("let &packpath = &runtimepath")
vim.cmd("source ~/.vimrc")
require("config.lazy")
EOF
cat > ~/.config/nvim/lua/config/lazy.lua <<'EOF'
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
EOF
curl --retry 100 --retry-connrefused --retry-delay 5 -fsSL https://raw.githubusercontent.com/Willie169/bashrc/main/nvim.sh | bash
curl -fsSL https://apt.gitcomet.dev/gitcomet-archive-keyring.gpg | sudo tee /usr/share/keyrings/gitcomet-archive-keyring.gpg >/dev/null
curl -fsSL https://apt.gitcomet.dev/gitcomet.sources | sudo tee /etc/apt/sources.list.d/gitcomet.sources >/dev/null
sudo apt update
sudo apt install gitcomet -y
curl --retry 100 --retry-connrefused --retry-delay 5 -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/trusted.gpg.d/docker.asc > /dev/null
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-rootless-extras -y
dockerd-rootless-setuptool.sh install
curl --retry 100 --retry-connrefused --retry-delay 5 -fsSL "https://pkgs.tailscale.com/stable/ubuntu/$UBUNTU_CODENAME.noarmor.gpg" | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl --retry 100 --retry-connrefused --retry-delay 5 -fsSL "https://pkgs.tailscale.com/stable/ubuntu/$UBUNTU_CODENAME.tailscale-keyring.list" | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt update
sudo apt install tailscale -y
sudo systemctl daemon-reload
sudo systemctl enable tailscaled
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
echo -e 'Types: deb\nURIs: https://download.vscodium.com/debs\nSuites: vscodium\nComponents: main\nArchitectures: amd64 arm64\nSigned-by: /usr/share/keyrings/vscodium-archive-keyring.gpg' | sudo tee /etc/apt/sources.list.d/vscodium.sources
sudo apt update
sudo apt install codium -y
sudo add-apt-repository ppa:remmina-ppa-team/remmina-next -y
sudo apt update
sudo apt install remmina remmina-plugin-rdp remmina-plugin-secret -y
wget --tries=100 --retry-connrefused --waitretry=5 "https://packages.microsoft.com/config/ubuntu/$UBUNTU_VERSION_ID/packages-microsoft-prod.deb" -O packages-microsoft-prod.deb
sudo apt install ./packages-microsoft-prod.deb -y
rm packages-microsoft-prod.deb
sudo apt update
sudo apt install dotnet-sdk-10.0 aspnetcore-runtime-10.0 -y
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list >/dev/null
sudo apt update
sudo apt install glow -y
wget --tries=100 --retry-connrefused --waitretry=5 -O- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | sudo tee /usr/share/keyrings/deb.torproject.org-keyring.gpg >/dev/null
sudo tee /etc/apt/sources.list.d/tor.list > /dev/null <<EOF
deb [arch=amd64 signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org ${UBUNTU_CODENAME} main
deb-src [arch=amd64 signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org ${UBUNTU_CODENAME} main
EOF
sudo apt update
sudo apt install tor deb.torproject.org-keyring -y
sudo wget --tries=100 --retry-connrefused --waitretry=5 -O /usr/local/java/antlr-4.13.2-complete.jar https://www.antlr.org/download/antlr-4.13.2-complete.jar
sudo wget --tries=100 --retry-connrefused --waitretry=5 -O /usr/local/java/plantuml.jar https://sourceforge.net/projects/plantuml/files/plantuml.jar/download
sudo apt install postgresql-common -y
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y
sudo apt install postgresql-17 -y
sudo mkdir -p /var/log/postgresql
sudo chown -R postgres:postgres /var/log/postgresql
sudo chmod 755 /var/log/postgresql
sudo chmod 640 /var/log/postgresql/* 2>/dev/null || true
wget --tries=100 --retry-connrefused --waitretry=5 https://cdn.fastly.steamstatic.com/client/installer/steam.deb
sudo apt install ./steam.deb -y
rm steam.deb
cd ~/.local
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' godotengine/godot Godot_*-stable_mono_linux_x86_64.zip
unzip Godot_*-stable_mono_linux_x86_64.zip
rm Godot_*-stable_mono_linux_x86_64.zip
mv Godot_*-stable_mono_linux_x86_64 godot
ln -s ~/.local/godot/Godot_*-stable_mono_linux.x86_64 ~/.local/bin/godoit
cd ~/.local/godot
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/godotengine/godot/refs/heads/master/icon.png
cd ~
cat > ~/.local/share/applications/godot.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Godot Engine
Comment=Develop your 2D & 3D games, cross-platform projects, or even XR ideas
Exec=$HOME/.local/bin/godot %f
Icon=$HOME/.local/godot/icon.png
Terminal=false
Categories=Development;IDE;
StartupNotify=true
EOF
sudo wget -O /usr/share/keyrings/element-io-archive-keyring.gpg https://packages.element.io/debian/element-io-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/element-io-archive-keyring.gpg] https://packages.element.io/debian/ default main" | sudo tee /etc/apt/sources.list.d/element-io.list
sudo apt update
sudo apt install element-desktop -y
docker pull ghcr.io/gchq/cyberchef:latest
cat > ~/.config/systemd/user/cyberchef.service <<EOF
[Unit]
Description=CyberChef
After=docker.service

[Service]
ExecStart=/usr/bin/docker run --rm --name cyberchef -p 8081:80 ghcr.io/gchq/cyberchef:latest
ExecStop=/usr/bin/docker stop cyberchef
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now cyberchef
wget --tries=100 --retry-connrefused --waitretry=5 https://edgedl.me.gvt1.com/android/studio/ide-zips/2025.3.2.6/android-studio-panda2-linux.tar.gz
sudo tar -xzf android-studio-*-linux.tar.gz -C /opt/
rm android-studio-*-linux.tar.gz
echo '[Desktop Entry]
Version=1.0
Type=Application
Name=Android Studio
Comment=Android IDE
Exec=/opt/android-studio/bin/studio %f
Icon=/opt/android-studio/bin/studio.png
Terminal=false
Categories=Development;IDE;
StartupNotify=true
StartupWMClass=android-studio' | sudo tee /usr/share/applications/android-studio.desktop > /dev/null
sudo chmod 644 /usr/share/applications/android-studio.desktop
wget --tries=100 --retry-connrefused --waitretry=5 https://dl.google.com/android/repository/commandlinetools-linux-14742923_latest.zip
unzip commandlinetools-linux-14742923_latest.zip
rm commandlinetools-linux-14742923_latest.zip
mkdir Android
cd Android
mkdir Sdk
cd Sdk
mkdir cmdline-tools
cd cmdline-tools
mkdir latest
cd latest
mv $HOME/cmdline-tools/* .
rm -r $HOME/cmdline-tools
cd bin
echo y | ./sdkmanager "build-tools;30.0.3" "build-tools;36.1.0" "emulator" "ndk;29.0.14206865" "platform-tools" "platforms;android-33" "platforms;android-36" "sources;android-33" "sources;android-36.1"
echo y | ./sdkmanager "system-images;android-33;google_apis_playstore;x86_64"
echo y | ./sdkmanager "system-images;android-36.1;google_apis_playstore;x86_64"
cd ~
sudo rm /bin/sdkmanager 2>/dev/null || true
wget --tries=100 --retry-connrefused --waitretry=5 https://proton.me/download/mail/linux/1.12.1/ProtonMail-desktop-beta.deb
sudo apt install ./ProtonMail-desktop-beta.deb -y
rm ProtonMail-desktop-beta.deb
wget --tries=100 --retry-connrefused --waitretry=5 https://proton.me/download/bridge/protonmail-bridge_3.21.2-1_amd64.deb
sudo apt install ./protonmail-bridge_*_amd64.deb -y
rm protonmail-bridge_*_amd64.deb
wget --tries=100 --retry-connrefused --waitretry=5 http://archive.ubuntu.com/ubuntu/pool/universe/g/gdk-pixbuf-xlib/libgdk-pixbuf2.0-0_2.40.2-3build2_amd64.deb
sudo apt install ./libgdk-pixbuf2.0-0_2.40.2-3build2_amd64.deb -y
rm libgdk-pixbuf2.0-0_2.40.2-3build2_amd64.deb
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' balena-io/etcher balena-etcher_*_amd64.deb
sudo apt install ./balena-etcher_*_amd64.deb -y
rm balena-etcher_*_amd64.deb
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' arduino/arduino-cli arduino-cli_*_amd64.deb
sudo apt install ./arduino-cli_*_amd64.deb -y
rm arduino-cli_*_amd64.deb
mkdir ~/.local/arduino-ide
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' arduino/arduino-ide arduino-ide_*_Linux_64bit.zip
unzip arduino-ide_*_Linux_64bit.zip
rm arduino-ide_*_Linux_64bit.zip
mv ~/arduino-ide_*_Linux_64bit ~/.local/arduino-ide/
cat > ~/.local/bin/arduino-ide <<'EOF'
#!/bin/bash
~/.local/arduino-ide/arduino-ide_*_Linux_64bit/arduino-ide --no-sandbox "$@"
EOF
chmod +x ~/.local/bin/arduino-ide
echo 'SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", GROUP="plugdev", MODE="0666"' | sudo tee /etc/udev/rules.d/99-arduino.rules >/dev/null
sudo tee /etc/udev/rules.d/52-xilinx-usb.rules <<'EOF'
SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE="0666", GROUP="plugdev"
EOF
sudo udevadm control --reload-rules
sudo udevadm trigger
sudo usermod -aG plugdev $USER
wget --tries=100 --retry-connrefused --waitretry=5 https://downloads.kicad.org/kicad/linux/explore/stable/download/kicad-10.0.0-x86_64.AppImage.tar
tar -xf kicad-*-x86_64.AppImage.tar
rm kicad-*-x86_64.AppImage.tar
chmod +x kicad-*-x86_64.AppImage
mkdir -p ~/.local/kicad
mv kicad-*-x86_64.AppImage ~/.local/kicad
cat > ~/.local/bin/kicad <<'EOF'
#!/bin/bash
~/.local/kicad/kicad-*-x86_64.AppImage "$@"
EOF
chmod +x ~/.local/bin/kicad
cd ~/.local/kicad
wget --tries=100 --retry-connrefused --waitretry=5 https://gitlab.com/kicad/code/kicad/-/raw/master/resources/bitmaps_png/icons/icon_kicad.ico
cd ~
cat > ~/.local/share/applications/kicad.desktop <<EOF
[Desktop Entry]
Type=Application
Name=KiCad
Comment=KiCad - Schematic Capture & PCB Design Software
Exec=$HOME/.local/kicad/kicad-*-x86_64.AppImage
Icon=$HOME/.local/kicad/icon_kicad.ico
Terminal=false
Categories=Development;
EOF
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' kristoff-it/superhtml x86_64-linux-musl.tar.xz
tar -xJf x86_64-linux-musl.tar.xz
rm x86_64-linux-musl.tar.xz
mv superhtml ~/.local/bin
mkdir eclipse.jdt.ls
cd eclipse.jdt.ls
wget --tries=100 --retry-connrefused --waitretry=5 'https://www.eclipse.org/downloads/download.php?file=/jdtls/milestones/1.57.0/jdt-language-server-1.57.0-202602261110.tar.gz'
tar -xzf 'download.php?file=%2Fjdtls%2Fmilestones%2F1.57.0%2Fjdt-language-server-1.57.0-202602261110.tar.gz'
rm 'download.php?file=%2Fjdtls%2Fmilestones%2F1.57.0%2Fjdt-language-server-1.57.0-202602261110.tar.gz'
cd ~
wget https://www.win-rar.com/fileadmin/winrar-versions/rarlinux-x64-720.tar.gz
tar -xzf rarlinux-x64-720.tar.gz
rm rarlinux-x64-720.tar.gz
git clone https://github.com/lightvector/KataGo.git
cd KataGo/cpp
if [ -n "$(clinfo -l | grep '#0')" ]; then
cmake . -G Ninja -DUSE_BACKEND=OPENCL
else
cmake . -G Ninja -DUSE_BACKEND=EIGEN
fi
ninja
cd ../..
mkdir katago-networks
cd katago-networks
wget --tries=100 --retry-connrefused --waitretry=5 https://media.katagotraining.org/uploaded/networks/models/kata1/kata1-b6c96-s175395328-d26788732.txt.gz
cd ~
git clone https://github.com/yzyray/lizzieyzy.git
cd lizzieyzy
mvn clean package
cd ~
cat > ~/.local/share/applications/lizzieyzy.desktop <<EOF
[Desktop Entry]
Type=Application
Name=LizzieYzy
Comment=LizzieYzy - GUI for Game of Go
Exec=sh -c 'cd $HOME/.lizzieyzy && java -jar "$HOME/lizzieyzy/target/lizzie-yzy2.5.3-shaded.jar"'
Icon=$HOME/lizzieyzy/src/main/resources/assets/logo.png
Terminal=false
Categories=Game;
StartupWMClass=featurecat-lizzie-Lizzie
EOF
update_lizzieyzy_config
git clone https://github.com/fairy-stockfish/Fairy-Stockfish.git
cd Fairy-Stockfish/src
make -j ARCH=x86-64 profile-build largeboards=yes nnue=yes
cd ~
git clone https://github.com/cutechess/cutechess.git
cd cutechess
mkdir build
cd build
cmake -G Ninja ..
ninja
cd ~
cat > ~/.local/share/applications/cutechess.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Cute Chess
Comment=Cute Chess - GUI for Playing Chess
Exec=$HOME/cutechess/build/cutechess
Icon=$HOME/cutechess/projects/gui/res/icons/cutechess_128x128.png
Terminal=false
Categories=Game;
EOF
update_cutechess_config
git clone https://github.com/hotfics/Sylvan.git
cd Sylvan
qmake
make
cd ~
cat > ~/.local/share/applications/sylvan.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Sylvan
Comment=Sylvan - GUI for Playing Xiangqi
Exec=$HOME/Sylvan/projects/gui/sylvan
Icon=$HOME/Sylvan/projects/gui/res/icons/app.ico
Terminal=false
Categories=Game;
EOF
update_sylvan_config
curl --retry 100 --retry-connrefused --retry-delay 5 -fsSL https://ollama.com/install.sh | sh
sudo env SYSTEMD_EDITOR=tee systemctl edit ollama <<EOF
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
EOF
sudo systemctl daemon-reload
sudo systemctl restart ollama
mkdir ~/.open-notebook
cat > ~/.open-notebook/docker-compose.yml<<EOF
services:
  surrealdb:
    image: surrealdb/surrealdb:v2
    command: start --log info --user root --pass root rocksdb:/mydata/mydatabase.db
    user: root
    network_mode: host
    volumes:
      - ./surreal_data:/mydata
    restart: always

  open_notebook:
    image: lfnovo/open_notebook:v1-latest
    network_mode: host
    environment:
      - OPEN_NOTEBOOK_ENCRYPTION_KEY=change-me-to-a-secret-string
      - SURREAL_URL=ws://localhost:8000/rpc
      - SURREAL_USER=root
      - SURREAL_PASSWORD=root
      - SURREAL_NAMESPACE=open_notebook
      - SURREAL_DATABASE=open_notebook
      - OLLAMA_API_BASE=http://localhost:11434
    volumes:
      - ./notebook_data:/app/data
    depends_on:
      - surrealdb
    restart: always
EOF
cd ~/.open-notebook
docker compose up -d
cd ~
curl --retry 100 --retry-connrefused --retry-delay 5 -fsSL https://raw.githubusercontent.com/AlexsJones/llmfit/main/install.sh | sh
mkdir -p ~/dev/llm
cd ~/dev/llm
git clone https://github.com/KhronosGroup/OpenCL-Headers && cd OpenCL-Headers
mkdir build && cd build
cmake .. -G Ninja \
  -DBUILD_TESTING=OFF \
  -DOPENCL_HEADERS_BUILD_TESTING=OFF \
  -DOPENCL_HEADERS_BUILD_CXX_TESTS=OFF \
  -DCMAKE_INSTALL_PREFIX="$HOME/dev/llm/opencl"
cmake --build . --target install
cd ~/dev/llm
git clone https://github.com/KhronosGroup/OpenCL-ICD-Loader && cd OpenCL-ICD-Loader
mkdir build && cd build
cmake .. -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="$HOME/dev/llm/opencl" \
  -DCMAKE_INSTALL_PREFIX="$HOME/dev/llm/opencl"
cmake --build . --target install
cd ~/dev/llm
git clone https://github.com/ggml-org/llama.cpp && cd llama.cpp
mkdir build && cd build
cmake .. -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="$HOME/dev/llm/opencl" \
  -DBUILD_SHARED_LIBS=OFF \
  -DGGML_OPENCL=ON
ninja
cd ~
mkdir ~/stirlingpdf
cd ~/stirlingpdf
cat > docker-compose.yml <<'EOF'
services:
  stirling-pdf:
    image: stirlingtools/stirling-pdf:latest
    ports:
      - '8083:8080'
    volumes:
      - ./stirling-data/tessdata:/usr/share/tessdata
      - ./stirling-data/configs:/configs
      - ./stirling-data/logs:/logs
      - ./stirling-data/pipeline:/pipeline
    environment:
      - DOCKER_ENABLE_SECURITY=false
      - INSTALL_BOOK_AND_ADVANCED_HTML_OPS=true
      - LANGS=en_GB
    restart: unless-stopped
EOF
docker compose up -d
cd ~
mkdir ~/.litellm
cd ~/.litellm
cat ~/API_KEY.sh | grep LITELLM_MASTER_KEY >> .env || true
cat ~/API_KEY.sh | grep LITELLM_SALT_KEY >> .env || true
cat ~/API_KEY.sh | grep OPENAI_API_KEY >> .env || true
cat ~/API_KEY.sh | grep ANTHROPIC_API_KEY >> .env || true
cat ~/API_KEY.sh | grep GEMINI_API_KEY >> .env || true
cat ~/API_KEY.sh | grep DEEPSEEK_API_KEY >> .env || true
cat ~/API_KEY.sh | grep OPENROUTER_API_KEY >> .env || true
cat ~/API_KEY.sh | grep MISTRAL_API_KEY >> .env || true
source .env
curl -O https://raw.githubusercontent.com/BerriAI/litellm/refs/heads/main/prometheus.yml
cat > docker-compose.yml <<'EOF'
services:
  litellm:
    build:
      context: .
      args:
        target: runtime
    image: docker.litellm.ai/berriai/litellm:main-stable
    volumes:
      - ./config.yaml:/app/config.yaml
    command:
      - "--config=/app/config.yaml"
    extra_hosts:
      - "host.docker.internal:host-gateway"
    ports:
      - "4000:4000" # Map the container port to the host, change the host port if necessary
    environment:
      DATABASE_URL: "postgresql://llmproxy:dbpassword9090@db:5432/litellm"
      STORE_MODEL_IN_DB: "True" # allows adding models to proxy via UI
    env_file:
      - .env # Load local .env file
    depends_on:
      - db  # Indicates that this service depends on the 'db' service, ensuring 'db' starts first
    healthcheck:  # Defines the health check configuration for the container
      test:
        - CMD-SHELL
        - python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:4000/health/liveliness')"  # Command to execute for health check
      interval: 30s  # Perform health check every 30 seconds
      timeout: 10s   # Health check command times out after 10 seconds
      retries: 3     # Retry up to 3 times if health check fails
      start_period: 40s  # Wait 40 seconds after container start before beginning health checks

  db:
    image: postgres:16
    restart: always
    container_name: litellm_db
    environment:
      POSTGRES_DB: litellm
      POSTGRES_USER: llmproxy
      POSTGRES_PASSWORD: dbpassword9090
    volumes:
      - postgres_data:/var/lib/postgresql/data # Persists Postgres data across container restarts
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -d litellm -U llmproxy"]
      interval: 1s
      timeout: 5s
      retries: 10

  prometheus:
    image: prom/prometheus
    volumes:
      - prometheus_data:/prometheus
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
      - "--storage.tsdb.path=/prometheus"
      - "--storage.tsdb.retention.time=15d"
    restart: always

volumes:
  prometheus_data:
    driver: local
  postgres_data:
    name: litellm_postgres_data # Named volume for Postgres data persistence
EOF
cat > ~/.litellm/config.yaml <<'EOF'
environment_variables:
    LITELLM_SALT_KEY: os.environ/LITELLM_SALT_KEY

model_list:
    - model_name: openai/*
      litellm_params:
        model: openai/*
        api_key: os.environ/OPENAI_API_KEY
    - model_name: anthropic/*
      litellm_params:
        model: anthropic/*
        api_key: os.environ/ANTHROPIC_API_KEY
    - model_name: gemini/*
      litellm_params:
        model: gemini/*
        api_key: os.environ/GEMINI_API_KEY
    - model_name: deepseek/*
      litellm_params:
        model: deepseek/*
        api_key: os.environ/DEEPSEEK_API_KEY
    - model_name: openrouter/*
      litellm_params:
        model: openrouter/*
        api_key: os.environ/OPENROUTER_API_KEY
    - model_name: mistral/*
      litellm_params:
        model: mistral/*
        api_key: os.environ/MISTRAL_API_KEY

litellm_settings:
    check_provider_endpoint: true

general_settings:
    master_key: os.environ/LITELLM_MASTER_KEY
EOF
docker compose up -d
cd ~
cat > ~/.config/systemd/user/litellm.service <<EOF
[Unit]
Description=LiteLLM
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
WorkingDirectory=$HOME/.litellm
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
RemainAfterExit=yes

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now litellm
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' Sathvik-Rao/ClipCascade ClipCascade-Server-JRE_21.jar
sudo mv ClipCascade-Server-JRE_21.jar /usr/local/java/
cat > ~/.config/systemd/user/clipcascade-server.service <<EOF
[Unit]
Description=ClipCascade Server
After=network.target

[Service]
Type=simple
ExecStart=java -jar /usr/local/java/ClipCascade-Server-JRE_21.jar
Restart=on-failure
RestartSec=5
Environment=CC_PORT=8082

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now clipcascade-server
sudo ufw allow 8082/tcp
sudo ufw reload
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' Sathvik-Rao/ClipCascade ClipCascade_Linux.tar.xz
tar -xJf ClipCascade_Linux.tar.xz
rm ClipCascade_Linux.tar.xz
cat > ~/.config/systemd/user/clipcascade-client.service <<EOF
[Unit]
Description=ClipCascade Client
Requires=clipcascade-server.service
After=clipcascade-server.service

[Service]
Type=simple
WorkingDirectory=$HOME/ClipCascade
ExecStartPre=/bin/bash -c '(while ! nc -z -w1 localhost 8082 2>/dev/null; do sleep 2; done); sleep 2'
ExecStart=/usr/bin/python3 $HOME/ClipCascade/main.py
Restart=on-failure
RestartSec=5
Environment=PYTHONUNBUFFERED=1
Environment=CC_PORT=8082

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now clipcascade-client
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo chmod o+r /usr/share/keyrings/caddy-stable-archive-keyring.gpg
sudo chmod o+r /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy -y
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' matrix-construct/tuwunel *-release-all-x86_64-$(cat /proc/cpuinfo | grep -Po '(avx|sse)[235]' | sort -u | sed 's/avx5/v4/;s/avx2/v3/;s/sse3/v2/;s/sse2/v1/' | sort | tail -1)-linux-gnu-tuwunel.deb
sudo apt install -f ./*-release-all-x86_64-$(cat /proc/cpuinfo | grep -Po '(avx|sse)[235]' | sort -u | sed 's/avx5/v4/;s/avx2/v3/;s/sse3/v2/;s/sse2/v1/' | sort | tail -1)-linux-gnu-tuwunel.deb -y
rm *-release-all-x86_64-$(cat /proc/cpuinfo | grep -Po '(avx|sse)[235]' | sort -u | sed 's/avx5/v4/;s/avx2/v3/;s/sse3/v2/;s/sse2/v1/' | sort | tail -1)-linux-gnu-tuwunel.deb*
sudo chown -R root:root /etc/tuwunel
sudo chmod -R 755 /etc/tuwunel
sudo mkdir -p /var/lib/tuwunel/
sudo chown -R tuwunel:tuwunel /var/lib/tuwunel/
sudo chmod 700 /var/lib/tuwunel/
sudo tee /etc/tuwunel/tuwunel.toml > /dev/null <<'EOF'
[global]
server_name = 'matrix.lan'
database_path = "/var/lib/tuwunel"
port = 8008
max_request_size = 1073741824
allow_registration = false
allow_federation = false
EOF
sudo mkdir -p /etc/caddy/conf.d
sudo tee /etc/caddy/conf.d/tuwunel_caddyfile > /dev/null <<'EOF'
matrix.lan, matrix.lan:8448 {
    # TCP reverse_proxy
    reverse_proxy localhost:8008
    # UNIX socket (alternative - comment out the line above and uncomment this)
    #reverse_proxy unix//run/tuwunel/tuwunel.sock
}
EOF
sudo systemctl enable --now caddy
sudo systemctl enable --now tuwunel
wget --tries=100 --retry-connrefused --waitretry=5 https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xzf install-tl-unx.tar.gz
rm install-tl-unx.tar.gz
cd install-tl-*
sudo perl ./install-tl --no-interaction
cd ~
rm -rf install-tl-*
sudo /usr/local/texlive/2026/bin/x86_64-linux/tlmgr update --all --self --reinstall-forcibly-removed
mkdir -p ~/.config/fontconfig/conf.d
cat > ~/.config/fontconfig/conf.d/99-texlive.conf <<'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <dir>/usr/local/texlive/2026/texmf-dist/fonts</dir>
</fontconfig>
EOF
sudo fc-cache -fv
cd /usr/share
sudo git clone https://github.com/Willie169/LaTeX-ToolKit
cd ~
mkdir -p texmf
cd texmf
mkdir -p tex
cd tex
mkdir -p latex
cd latex
git clone https://github.com/Willie169/physics-patch
cd physics-patch
git checkout dev
cd ~
sudo apt update
sudo apt install -f -y
sudo apt upgrade -y
sudo apt autoremove --purge -y
sudo apt clean
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
kill "$SUDOPID"
sudo reboot
