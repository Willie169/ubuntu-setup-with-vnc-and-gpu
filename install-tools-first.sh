#!/bin/bash
set -euxo pipefail
shopt -s expand_aliases
[ "${1:-}" = '--test' ] && TEST=1 || TEST=0
[ "${1:-}" = '--full' ] && FULL=1 || FULL=0
# shellcheck disable=2155
PREDF=$(df --output=used / | tail -n1)
cd ~ || exit
if [ "$FULL" -eq 0 ]; then
sudo -v
while true; do sudo -nv; sleep 29; done & SUDOPIDFIRST=$!
while true; do sudo -nv; sleep 31; done & SUDOPIDSECOND=$!
while true; do sudo -nv; sleep 59; done & SUDOPIDTHIRD=$!
while true; do sudo -nv; sleep 61; done & SUDOPIDFOURTH=$!
fi
sudo sed -i -e 's/^[# ]*HandleLidSwitch=.*/HandleLidSwitch=ignore/' -e 's/^[# ]*HandleLidSwitchDocked=.*/HandleLidSwitchDocked=ignore/' -e 's/^[# ]*HandleLidSwitchExternalPower=.*/HandleLidSwitchExternalPower=ignore/' "/etc/systemd/logind.conf"
sudo grep -q '^HandleLidSwitch=' "/etc/systemd/logind.conf" || echo 'HandleLidSwitch=ignore' | sudo tee -a "/etc/systemd/logind.conf" >/dev/null
sudo grep -q '^HandleLidSwitchDocked=' "/etc/systemd/logind.conf" || echo 'HandleLidSwitchDocked=ignore' | sudo tee -a "/etc/systemd/logind.conf" >/dev/null
sudo grep -q '^HandleLidSwitchExternalPower=' "/etc/systemd/logind.conf" || echo 'HandleLidSwitchExternalPower=ignore' | sudo tee -a "/etc/systemd/logind.conf" >/dev/null
for file in /etc/grub.d/* /etc/default/grub.d/*; do
  [[ -f "$file" ]] && sudo sed -i 's/^quick_boot=.*/quick_boot="0"/' "$file"
done
[ "$FULL" -eq 0 ] && sudo update-grub
DM=$(basename "$(basename "$(readlink -f /etc/systemd/system/display-manager.service)" || true)" ".service" || true)
if [[ -n "$DM" ]] && [[ -n "$USER" ]]; then
case "$DM" in
gdm|gdm3)
if [ -f "/etc/gdm3/custom.conf" ]; then
CONF="/etc/gdm3/custom.conf"
elif [ -f "/etc/gdm/custom.conf" ]; then
CONF="/etc/gdm/custom.conf"
elif [ -d "/etc/gdm3" ]; then
CONF="/etc/gdm3/custom.conf"
elif [ -d "/etc/gdm" ]; then
CONF="/etc/gdm/custom.conf"
else
CONF="/etc/gdm3/custom.conf"
fi
if [ -f "$CONF" ]; then
sudo sed -i '/^AutomaticLoginEnable/d' "$CONF"
sudo sed -i '/^AutomaticLogin=/d' "$CONF"
sudo sed -i '/^WaylandEnable=/d' "$CONF"
if sudo grep -q "^\[daemon\]" "$CONF"; then
sudo sed -i "/^\[daemon\]/a AutomaticLoginEnable=True\nAutomaticLogin=$USER\nWaylandEnable=true" "$CONF"
else
printf '\n[daemon]\nAutomaticLoginEnable=True\nAutomaticLogin=%s\nWaylandEnable=true\n' "$USER" | sudo tee -a "$CONF" >/dev/null
fi
else
printf '\n[daemon]\nAutomaticLoginEnable=True\nAutomaticLogin=%s\nWaylandEnable=true\n' "$USER" | sudo tee -a "$CONF" >/dev/null
fi
;;
lightdm)
COUNT=0
for CONF in "/etc/lightdm/"*".conf" "/etc/lightdm/lightdm.conf.d/"*; do
sudo test -f "$CONF" || continue
sudo sed -i '/^autologin-user=/d' "$CONF"
sudo sed -i '/^autologin-user-timeout=/d' "$CONF"
if sudo grep -q "^\[Seat:\*\]" "$CONF" && [ "$COUNT" -eq 0 ]; then
sudo sed -i "/^\[Seat:\*\]/a autologin-user=$USER\nautologin-user-timeout=0" "$CONF"
COUNT=1
fi
done
[ "$COUNT" -eq 0 ] && printf '\n[Seat:*]\nautologin-user=%s\nautologin-user-timeout=0\n' "$USER" | sudo tee -a "/etc/lightdm/lightdm.conf" >/dev/null
;;
sddm)
COUNT=0
command -v kinfo >/dev/null 2>&1 && PLASMA_VERSION=$(kinfo 2>/dev/null | grep 'KDE Plasma Version' | sed 's/KDE Plasma Version: //' | cut -d. -f1) || PLASMA_VERSION=''
if [ "$PLASMA_VERSION" -ge 6 ]; then
SESSION='plasma'
elif [ "$PLASMA_VERSION" -le 5 ]; then
SESSION='plasmawayland'
elif command -v lxqt-runner >/dev/null 2>&1; then
SESSION='lxqt.desktop'
fi
if [ -n "$SESSION" ]; then
for CONF in "/etc/sddm.conf" "/etc/sddm.conf.d/"*; do
sudo test -f "$CONF" || continue
sudo sed -i '/^User=/d' "$CONF"
sudo sed -i '/^Session=/d' "$CONF"
if sudo grep -q "^\[Autologin\]" "$CONF" && [ "$COUNT" -eq 0 ]; then
sudo sed -i "/^\[Autologin\]/a User=$USER\nSession=$SESSION" "$CONF"
COUNT=1
fi
done
[ "$COUNT" -eq 0 ] && printf '\n[Autologin]\nUser=%s\nSession=%s\n' "$USER" "$SESSION" | sudo tee -a "/etc/sddm.conf" >/dev/null
fi
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
[ "$FULL" -eq 0 ] && sudo timedatectl set-local-rtc 1
[ "$FULL" -eq 0 ] && sudo timedatectl set-ntp true
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install software-properties-common -y
sudo add-apt-repository universe -y
sudo add-apt-repository multiverse -y
sudo add-apt-repository restricted -y
sudo add-apt-repository ppa:bkryza/clang-uml -y
sudo mv /etc/apt/sources.list.d/bkryza-ubuntu-clang-uml-*.sources /etc/apt/sources.list.d/bkryza-ubuntu-clang-uml-noble.sources || true
sudo sed -i 's/^Suites: .*$/Suites: noble/' /etc/apt/sources.list.d/bkryza-ubuntu-clang-uml-noble.sources
sudo add-apt-repository ppa:flexiondotorg/quickemu -y
sudo add-apt-repository ppa:git-core/ppa -y
sudo add-apt-repository ppa:libreoffice/ppa -y
sudo add-apt-repository ppa:longsleep/golang-backports -y
sudo add-apt-repository ppa:obsproject/obs-studio -y
sudo add-apt-repository ppa:openjdk-r/ppa -y
sudo mv /etc/apt/sources.list.d/openjdk-r-ubuntu-ppa-*.sources /etc/apt/sources.list.d/openjdk-r-ubuntu-ppa-noble.sources || true
sudo sed -i 's/^Suites: .*$/Suites: noble/' /etc/apt/sources.list.d/openjdk-r-ubuntu-ppa-noble.sources
sudo add-apt-repository ppa:remmina-ppa-team/remmina-next -y
sudo mv /etc/apt/sources.list.d/remmina-ppa-team-ubuntu-remmina-next-*.sources /etc/apt/sources.list.d/remmina-ppa-team-ubuntu-remmina-next-noble.sources || true
sudo sed -i 's/^Suites: .*$/Suites: noble/' /etc/apt/sources.list.d/remmina-ppa-team-ubuntu-remmina-next-noble.sources
sudo add-apt-repository ppa:stefanberger/swtpm-noble -y
sudo mv /etc/apt/sources.list.d/stefanberger-ubuntu-swtpm-noble-*.sources /etc/apt/sources.list.d/stefanberger-ubuntu-swtpm-noble-noble.sources || true
sudo sed -i 's/^Suites: .*$/Suites: noble/' /etc/apt/sources.list.d/stefanberger-ubuntu-swtpm-noble-noble.sources
echo 'Package: *
Pin: release o=LP-PPA-stefanberger-swtpm-noble
Pin-Priority: 1001' | sudo tee /etc/apt/preferences.d/swtpm >/dev/null
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
bash <<'EOF'
set -e
f=/etc/apt/sources.list.d/ubuntu.sources
if [ -f "$f" ] && grep -q "^Types:.*deb" "$f"; then
  sudo sed -i 's/^Types: *deb.*/Types: deb deb-src/' "$f"
fi
EOF
sudo apt update
sudo apt purge fcitx* rustup texlive* yq -y
sudo DEBIAN_FRONTEND=noninteractive apt install apt-transport-https bash build-essential ca-certificates coreutils cmake curl dbus openjdk-21-jdk g++ gcc git gnupg grep gzip jq locales lsb-release make ninja-build openssh-server perl perl-tk pipx python-is-python3 python3 vim-gtk3 wget xz-utils -y
sudo DEBIAN_FRONTEND=noninteractive apt install apparmor-utils clinfo dnscrypt-proxy fcitx5 fcitx5-configtool fcitx5-chinese-addons fcitx5-frontend-all flatpak language-pack-gnome-en pipewire pipewire-audio-client-libraries ufw unattended-upgrades wireplumber -y
rm -f .bashrc
mkdir ~/.bashrc.d
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/00-env.sh -O ~/.bashrc.d/00-env.sh
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/10-exports.sh -O ~/.bashrc.d/10-exports.sh
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/15-color.sh -O ~/.bashrc.d/15-color.sh
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/20-aliases.sh -O ~/.bashrc.d/20-aliases.sh
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/21-cxx.sh -O ~/.bashrc.d/21-cxx.sh
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/22-java.sh -O ~/.bashrc.d/22-java.sh
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/23-vnc.sh -O ~/.bashrc.d/23-vnc.sh
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/24-flatpak.sh -O ~/.bashrc.d/24-flatpak.sh
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/50-functions.sh -O ~/.bashrc.d/50-functions.sh
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/60-completion.sh -O ~/.bashrc.d/60-completion.sh
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/bashrc -O ~/.bashrc
cat > ~/.profile <<'EOF'
if [ -n "$BASH_VERSION" ]; then
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi
EOF
if [ -d "$HOME/.bashrc.d" ];  then
  for f in "$HOME/.bashrc.d/"*; do
    [ -r "$f" ] && . "$f"
  done
fi
sudo loginctl enable-linger "$USER"
sudo mkdir -p /usr/local/java
sudo mkdir -p /etc/apt/keyrings
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/applications
mkdir -p ~/.local/share/fonts
mkdir -p ~/Desktop
mkdir -p ~/.config/systemd/user
if ! grep -q '^NAME="Linux Mint"' /etc/os-release; then
sudo add-apt-repository ppa:mozillateam/ppa -y
echo 'Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: firefox*
Pin: release o=Ubuntu
Pin-Priority: -1' | sudo tee /etc/apt/preferences.d/firefox >/dev/null
sudo rm -f /etc/apparmor.d/usr.bin.firefox
sudo rm -f /etc/apparmor.d/local/usr.bin.firefox
sudo systemctl stop var-snap-firefox-common-*.mount 2>/dev/null || true
sudo systemctl disable var-snap-firefox-common-*.mount 2>/dev/null || true
sudo systemctl disable snap-firefox*.mount 2>/dev/null || true
sudo snap remove firefox 2>/dev/null || true
sudo DEBIAN_FRONTEND=noninteractive apt install firefox --allow-downgrades -y
sudo tee /etc/systemd/system/firefox-apparmor.service >/dev/null <<'EOF'
[Unit]
Description=Firefox Apparmor Disable
PartOf=apparmor.service
After=apparmor.service

[Service]
Type=oneshot
User=root
ExecStart=bash -c 'ln -sf /etc/apparmor.d/firefox /etc/apparmor.d/disable/ || true; sudo apparmor_parser -R /etc/apparmor.d/firefox || true'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now firefox-apparmor.service
sudo rm /var/lib/snapd/desktop/applications/firefox*.desktop 2>/dev/null || true
sudo rm /var/lib/snapd/inhibit/firefox.lock 2>/dev/null || true
rm -r snap/firefox 2>/dev/null || true
echo 'Package: thunderbird*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: thunderbird*
Pin: release o=Ubuntu
Pin-Priority: -1' | sudo tee /etc/apt/preferences.d/thunderbird >/dev/null
sudo rm -f /etc/apparmor.d/usr.bin.thunderbird
sudo rm -f /etc/apparmor.d/local/usr.bin.thunderbird
sudo systemctl stop var-snap-thunderbird-common-*.mount 2>/dev/null || true
sudo systemctl disable var-snap-thunderbird-common-*.mount 2>/dev/null || true
sudo systemctl disable snap-thunderbird*.mount 2>/dev/null || true
sudo snap remove thunderbird 2>/dev/null || true
sudo DEBIAN_FRONTEND=noninteractive apt install thunderbird --allow-downgrades -y
sudo rm /var/lib/snapd/desktop/applications/thunderbird*.desktop 2>/dev/null || true
sudo add-apt-repository ppa:xtradeb/apps -y
echo 'Package: chromium*
Pin: release o=LP-PPA-xtradeb-apps
Pin-Priority: 1001

Package: chromium*
Pin: release o=Ubuntu
Pin-Priority: -1' | sudo tee /etc/apt/preferences.d/chromium >/dev/null
sudo apt update
fi
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
echo 'APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "1";' | sudo tee /etc/apt/apt.conf.d/10periodic >/dev/null
echo 'APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";' | sudo tee /etc/apt/apt.conf.d/20auto-upgrades >/dev/null
sudo mv /etc/apt/apt.conf.d/20apt-esm-hook.conf /etc/apt/apt.conf.d/20apt-esm-hook.conf.bak || true
sudo touch /etc/apt/apt.conf.d/20apt-esm-hook.conf
sudo touch /var/lib/update-notifier/hide-esm-in-motd
sudo rm /etc/update-motd.d/88-esm-announce || true
sudo rm /etc/update-motd.d/91-contract-ua-esm-status || true
# shellcheck disable=2016
echo '// Automatically upgrade packages from these (origin:archive) pairs
//
// Note that in Ubuntu security updates may pull in new dependencies
// from non-security sources (e.g. chromium). By allowing the release
// pocket these get automatically pulled in.
// Unattended-Upgrade::Allowed-Origins {
//	"${distro_id}:${distro_codename}";
//	"${distro_id}:${distro_codename}-security";
	// Extended Security Maintenance; doesn'"'"'t necessarily exist for
	// every release and this system may not have it installed, but if
	// available, the policy for updates is such that unattended-upgrades
	// should also install from here by default.
	// "${distro_id}ESMApps:${distro_codename}-apps-security";
	// "${distro_id}ESM:${distro_codename}-infra-security";
//	"${distro_id}:${distro_codename}-updates";
//	"${distro_id}:${distro_codename}-proposed";
//	"${distro_id}:${distro_codename}-backports";
// };

Unattended-Upgrade::Origins-Pattern {
    "origin=*";
};

// Python regular expressions, matching packages to exclude from upgrading
Unattended-Upgrade::Package-Blacklist {
    // The following matches all packages starting with linux-
//  "linux-";

    // Use $ to explicitely define the end of a package name. Without
    // the $, "libc6" would match all of them.
//  "libc6$";
//  "libc6-dev$";
//  "libc6-i686$";

    // Special characters need escaping
//  "libstdc\+\+6$";

    // The following matches packages like xen-system-amd64, xen-utils-4.1,
    // xenstore-utils and libxenstore3.0
//  "(lib)?xen(store)?";

    // For more information about Python regular expressions, see
    // https://docs.python.org/3/howto/regex.html
};

// This option controls whether the development release of Ubuntu will be
// upgraded automatically. Valid values are "true", "false", and "auto".
Unattended-Upgrade::DevRelease "auto";

// This option allows you to control if on a unclean dpkg exit
// unattended-upgrades will automatically run
//   dpkg --force-confold --configure -a
// The default is true, to ensure updates keep getting installed
//Unattended-Upgrade::AutoFixInterruptedDpkg "true";

// Split the upgrade into the smallest possible chunks so that
// they can be interrupted with SIGTERM. This makes the upgrade
// a bit slower but it has the benefit that shutdown while an upgrade
// is running is possible (with a small delay)
//Unattended-Upgrade::MinimalSteps "true";

// Install all updates when the machine is shutting down
// instead of doing it in the background while the machine is running.
// This will (obviously) make shutdown slower.
// Unattended-upgrades increases logind'"'"'s InhibitDelayMaxSec to 30s.
// This allows more time for unattended-upgrades to shut down gracefully
// or even install a few packages in InstallOnShutdown mode, but is still a
// big step back from the 30 minutes allowed for InstallOnShutdown previously.
// Users enabling InstallOnShutdown mode are advised to increase
// InhibitDelayMaxSec even further, possibly to 30 minutes.
//Unattended-Upgrade::InstallOnShutdown "false";

// Send email to this address for problems or packages upgrades
// If empty or unset then no email is sent, make sure that you
// have a working mail setup on your system. A package that provides
// '"'"'mailx'"'"' must be installed. E.g. "user@example.com"
//Unattended-Upgrade::Mail "";

// Set this value to one of:
//    "always", "only-on-error" or "on-change"
// If this is not set, then any legacy MailOnlyOnError (boolean) value
// is used to chose between "only-on-error" and "on-change"
//Unattended-Upgrade::MailReport "on-change";

// Remove unused automatically installed kernel-related packages
// (kernel images, kernel headers and kernel version locked tools).
//Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";

// Do automatic removal of newly unused dependencies after the upgrade
//Unattended-Upgrade::Remove-New-Unused-Dependencies "true";

// Do automatic removal of unused packages after the upgrade
// (equivalent to apt-get autoremove)
Unattended-Upgrade::Remove-Unused-Dependencies "false";

// Automatically reboot *WITHOUT CONFIRMATION* if
//  the file /var/run/reboot-required is found after the upgrade
//Unattended-Upgrade::Automatic-Reboot "false";

// Automatically reboot even if there are users currently logged in
// when Unattended-Upgrade::Automatic-Reboot is set to true
//Unattended-Upgrade::Automatic-Reboot-WithUsers "true";

// If automatic reboot is enabled and needed, reboot at the specific
// time instead of immediately
//  Default: "now"
//Unattended-Upgrade::Automatic-Reboot-Time "02:00";

// Use apt bandwidth limit feature, this example limits the download
// speed to 70kb/sec
//Acquire::http::Dl-Limit "70";

// Enable logging to syslog. Default is False
// Unattended-Upgrade::SyslogEnable "false";

// Specify syslog facility. Default is daemon
// Unattended-Upgrade::SyslogFacility "daemon";

// Download and install upgrades only on AC power
// (i.e. skip or gracefully stop updates on battery)
// Unattended-Upgrade::OnlyOnACPower "true";

// Download and install upgrades only on non-metered connection
// (i.e. skip or gracefully stop updates on a metered connection)
Unattended-Upgrade::Skip-Updates-On-Metered-Connections "false";

// Verbose logging
// Unattended-Upgrade::Verbose "false";

// Print debugging information both in unattended-upgrades and
// in unattended-upgrade-shutdown
// Unattended-Upgrade::Debug "false";

// Allow package downgrade if Pin-Priority exceeds 1000
// Unattended-Upgrade::Allow-downgrade "false";

// When APT fails to mark a package to be upgraded or installed try adjusting
// candidates of related packages to help APT'"'"'s resolver in finding a solution
// where the package can be upgraded or installed.
// This is a workaround until APT'"'"'s resolver is fixed to always find a
// solution if it exists. (See Debian bug #711128.)
// The fallback is enabled by default, except on Debian'"'"'s sid release because
// uninstallable packages are frequent there.
// Disabling the fallback speeds up unattended-upgrades when there are
// uninstallable packages at the expense of rarely keeping back packages which
// could be upgraded or installed.
// Unattended-Upgrade::Allow-APT-Mark-Fallback "true";

// Allow postponing an upgrade by up to this number of days.
// The feature is disabled if the number of days is 0.
// Unattended-Upgrade::Postpone-For-Days "0";

// How long should unattended-upgrade wait for a postpone request
// before proceding with the update.
// If the postponing feature is disabled, this option has no effect
// as unattended-upgrade will not be waiting.
// Unattended-Upgrade::Postpone-Wait-Time "300";
' | sudo tee /etc/apt/apt.conf.d/50unattended-upgrades >/dev/null

PKG='alsa-utils apksigner apt-transport-https aptitude audacity automake bash bc bear bindfs bison bookletimposer build-essential bzip2 ca-certificates calcurse clang clang-format clangd cmake command-not-found cronie curl dbus dbus-x11 debconf-utils distro-info dnsutils dvisvgm fastfetch ffmpeg file flex fontconfig fonts-cns11643-kai fonts-cns11643-sung fonts-liberation fonts-noto fonts-noto-cjk fonts-noto-cjk-extra fonts-noto-color-emoji fonts-wqy-zenhei g++ gcc gdb gh ghostscript git glab gnupg gnupg2 golang-go gopls gperf grep gzip hyperfine iftop imagemagick info inkscape iotop-c iproute2 jpegoptim jq lftp libheif-examples libreoffice lsb-release lsd lzip make maven mesa-utils mpv nano ncdu neovim netcat-openbsd nethogs net-tools ngspice ninja-build nmap ocrmypdf octave openjdk-21-jdk openssh-client openssh-server openssl optipng p7zip-full pandoc perl perl-tk pipx pkg-config poppler-utils procps pv pwgen python-is-python3 python3-all-dev python3-argcomplete python3-httpx python3-jinja2 python3-neovim python3-pip python3-requests python3-venv qpdf shellcheck shfmt socat sqlite3 sudo tar tesseract-ocr tesseract-ocr-chi-sim tesseract-ocr-chi-sim-vert tesseract-ocr-chi-tra tesseract-ocr-chi-tra-vert tesseract-ocr-eng tesseract-ocr-jpn tesseract-ocr-jpn-vert tmux tree tree-sitter-cli tsocks unrar unzip uuid-runtime verilator vim-gtk3 w3m webp wget wget2 xdotool xmlstarlet xz-utils zip zsh zstd'
# shellcheck disable=2086
if [ "$TEST" -eq 0 ]; then
sudo DEBIAN_FRONTEND=noninteractive apt install $PKG -y
else
sudo DEBIAN_FRONTEND=noninteractive apt install $PKG -y -s
fi
PKG='apparmor-utils aria2 bridge-utils clang-uml clinfo distrobox dnscrypt-proxy fcitx5 fcitx5-configtool fcitx5-chinese-addons fcitx5-frontend-all filelight flatpak fwupd gnome-keyring gtkwave kate krita language-pack-gnome-en libvirt-daemon-system libvirt-clients ntfs-3g obs-studio ovmf pipewire pipewire-audio-client-libraries podman qbittorrent qemu-system-gui qemu-system-x86 qemu-user-binfmt qemu-user qemu-utils qtspeech5-speechd-plugin quickemu remmina remmina-plugin-rdp remmina-plugin-secret snapd spice-vdagent swtpm swtpm-tools testdisk torbrowser-launcher ufw uidmap unattended-upgrades virt-manager virt-viewer wireplumber wl-clipboard xclip'
# shellcheck disable=2086
if [ "$TEST" -eq 0 ]; then
sudo DEBIAN_FRONTEND=noninteractive apt install $PKG -y
else
sudo DEBIAN_FRONTEND=noninteractive apt install $PKG -y -s
fi
sudo snap set system refresh.retain=2
sudo cp /usr/share/doc/dnscrypt-proxy/examples/* /etc/dnscrypt-proxy/
sudo mkdir -p /usr/share/dnscrypt-proxy/utils/generate-domains-blocklist
cd /usr/share/dnscrypt-proxy/utils/generate-domains-blocklist || exit
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
cd /etc/dnscrypt-proxy || exit
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
cd ~ || exit
sudo tee /etc/systemd/resolved.conf >/dev/null <<'EOF'
[Resolve]
DNS=127.0.0.1
EOF
sudo systemctl restart systemd-resolved
systemctl --user restart pipewire pipewire-pulse wireplumber
im-config -n fcitx5
cat > ~/.xprofile <<'EOF'
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export INPUT_METHOD=fcitx
export SDL_IM_MODULE=fcitx
EOF
if [ "${XDG_CURRENT_DESKTOP:-}" = "KDE" ] || [[ "${DESKTOP_SESSION:-}" == *plasma* ]] || [ "${KDE_FULL_SESSION:-}" = "true" ]; then
  sudo DEBIAN_FRONTEND=noninteractive apt install plasma-discover-backend-flatpak -y
else
  mkdir -p ~/.config/autostart
  cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart/
fi
mkdir ~/.JetBrainsMono
cd ~/.JetBrainsMono || exit
wget --tries=100 --retry-connrefused --waitretry=5 https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip
unzip JetBrainsMono.zip
mv JetBrainsMonoNerdFontMono-Regular.ttf ~/.local/share/fonts/
cd ~ || exit
rm -rf .JetBrainsMono
[ "$TEST" -eq 0 ] && sudo fc-cache -fv
sudo systemctl enable --now ssh
sudo ufw --force enable
sudo ufw allow ssh
sudo ufw reload
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path -y
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install brave-browser -y
curl -fsSL https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE | gpg --no-default-keyring --keyring gnupg-ring:/tmp/onlyoffice.gpg --import
chmod 644 /tmp/onlyoffice.gpg
sudo chown root:root /tmp/onlyoffice.gpg
sudo mv /tmp/onlyoffice.gpg /usr/share/keyrings/onlyoffice.gpg
echo 'deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] https://download.onlyoffice.com/repo/debian squeeze main' | sudo tee /etc/apt/sources.list.d/onlyoffice.list >/dev/null
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install onlyoffice-desktopeditors -y
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' rustdesk/rustdesk 'rustdesk-*-x86_64.deb'
sudo DEBIAN_FRONTEND=noninteractive apt install ./rustdesk-*-x86_64.deb -y
rm rustdesk-*-x86_64.deb*
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' rustdesk/rustdesk-server 'rustdesk-server-hbbs_*_amd64.deb'
sudo DEBIAN_FRONTEND=noninteractive apt install ./rustdesk-server-hbbs_*_amd64.deb -y
rm rustdesk-server-hbbs_*_amd64.deb*
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' rustdesk/rustdesk-server 'rustdesk-server-hbbr_*_amd64.deb'
sudo DEBIAN_FRONTEND=noninteractive apt install ./rustdesk-server-hbbr_*_amd64.deb -y
rm rustdesk-server-hbbr_*_amd64.deb*
sudo systemctl enable --now rustdesk-hbbs.service
sudo systemctl enable --now rustdesk-hbbr.service
sudo systemctl enable --now rustdesk.service
sudo ufw allow 21118/udp
sudo ufw allow 21118/tcp
sudo ufw allow 21114:21119/tcp
sudo ufw allow 21116/udp
sudo ufw reload
curl -sS https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/debian.griffo.io.gpg
echo "deb https://debian.griffo.io/apt $(lsb_release -sc 2>/dev/null) main" | sudo tee /etc/apt/sources.list.d/debian.griffo.io.list >/dev/null
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install lazygit -y
wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
chmod +x apktool
sudo mv apktool /usr/local/bin/
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' iBotPeaches/Apktool 'apktool_*.jar'
chmod +x apktool_*.jar
sudo mv apktool_*.jar /usr/local/bin/
mkdir jadx
cd jadx || exit
gh_latest_r -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' skylot/jadx 'jadx-[0-9\.]*\.zip'
unzip jadx*.zip
rm jadx*.zip*
chmod +x bin/jadx
chmod +x bin/jadx-gui
cd ~ || exit
NVM_VERSION=$(curl -fsSL "https://api.github.com/repos/nvm-sh/nvm/releases/latest" | jq -r '.tag_name')
PROFILE=/dev/null bash -c "curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install --lts
echo y | corepack enable npm
echo y | npm --help || true
echo y | corepack enable yarn
echo y | yarn --help || true
npm i -g --allow-scripts=opencode-ai bash-language-server deno dockerfile-language-server-nodejs http-server opencode-ai pyright @linthtml/linthtml @openai/codex
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' yt-dlp/yt-dlp yt-dlp
chmod +x yt-dlp
mv yt-dlp ~/.local/bin/
pipx install cmake-language-server gh2md img2pdf jupyterlab jupytext libretranslate meson notebook pylatexenc tldr uv xmljson yamllint
pipx install fdroidserver gallery-dl
cat > ~/.config/systemd/user/libretranslate.service <<EOF
[Unit]
Description=LibreTranslate

[Service]
ExecStart=$HOME/.local/bin/libretranslate
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now libretranslate.service
wget --tries=100 --retry-connrefused --waitretry=5 https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh -b -p "${HOME}/conda"
rm Miniforge3-Linux-x86_64.sh*
export MAMBA_ROOT_PREFIX="${HOME}/conda"
source "${HOME}/conda/etc/profile.d/conda.sh" 2>/dev/null
source "${HOME}/conda/etc/profile.d/mamba.sh" 2>/dev/null
conda config --set auto_activate_base false
conda config --add channels pypi
conda config --add channels pytorch
conda config --add channels conda-forge
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
brew trust gurgeous/tap
BREW='bat bottom broot dust fd fzf git-delta gurgeous/tap/tennis procs resvg ripgrep sevenzip yazi yq zoxide'
# shellcheck disable=2086
if [ "$TEST" -eq 0 ]; then
echo y | brew install $BREW
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global merge.conflictStyle zdiff3
else
echo y | brew install $BREW --dry-run
fi
git clone --depth=1 https://github.com/Willie169/vimrc.git ~/.vim_runtime && sh ~/.vim_runtime/install_awesome_vimrc.sh
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
curl --retry 100 --retry-connrefused --retry-delay 5 -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/trusted.gpg.d/docker.asc >/dev/null
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras -y
sudo systemctl disable --now docker.service docker.socket
sudo rm /var/run/docker.sock
dockerd-rootless-setuptool.sh install
curl --retry 100 --retry-connrefused --retry-delay 5 -fsSL "https://pkgs.tailscale.com/stable/ubuntu/$UBUNTU_CODENAME.noarmor.gpg" | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl --retry 100 --retry-connrefused --retry-delay 5 -fsSL "https://pkgs.tailscale.com/stable/ubuntu/$UBUNTU_CODENAME.tailscale-keyring.list" | sudo tee /etc/apt/sources.list.d/tailscale.list >/dev/null
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install tailscale -y
sudo systemctl daemon-reload
sudo systemctl enable tailscaled
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
echo -e 'Types: deb\nURIs: https://download.vscodium.com/debs\nSuites: vscodium\nComponents: main\nArchitectures: amd64 arm64\nSigned-by: /usr/share/keyrings/vscodium-archive-keyring.gpg' | sudo tee /etc/apt/sources.list.d/vscodium.sources >/dev/null
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install codium -y
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list >/dev/null
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install glow -y
wget --tries=100 --retry-connrefused --waitretry=5 -O- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | sudo tee /usr/share/keyrings/deb.torproject.org-keyring.gpg >/dev/null
sudo tee /etc/apt/sources.list.d/tor.list > /dev/null <<EOF
deb [arch=amd64 signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org ${UBUNTU_CODENAME} main
deb-src [arch=amd64 signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org ${UBUNTU_CODENAME} main
EOF
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install tor torsocks deb.torproject.org-keyring -y
sudo wget --tries=100 --retry-connrefused --waitretry=5 -O /usr/local/java/antlr-4.13.2-complete.jar https://www.antlr.org/download/antlr-4.13.2-complete.jar
sudo wget --tries=100 --retry-connrefused --waitretry=5 -O /usr/local/java/plantuml.jar https://sourceforge.net/projects/plantuml/files/plantuml.jar/download
sudo wget -O /usr/share/keyrings/element-io-archive-keyring.gpg https://packages.element.io/debian/element-io-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/element-io-archive-keyring.gpg] https://packages.element.io/debian/ default main" | sudo tee /etc/apt/sources.list.d/element-io.list >/dev/null
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install element-desktop -y
docker pull ghcr.io/gchq/cyberchef:latest
cat > ~/.config/systemd/user/cyberchef.service <<EOF
[Unit]
Description=CyberChef
After=docker.service

[Service]
ExecStart=/usr/bin/docker run -it --name cyberchef -p 8081:8080 ghcr.io/gchq/cyberchef:latest
ExecStop=/usr/bin/docker stop cyberchef
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now cyberchef.service
mkdir -p ~/stirlingpdf/stirling-data/configs
cd ~/stirlingpdf || exit
cat > docker-compose.yml <<'EOF'
services:
  stirling-pdf:
    image: stirlingtools/stirling-pdf:latest
    ports:
      - '9000:8080'
    volumes:
      - /usr/share/tesseract-ocr/5/tessdata:/usr/share/tessdata
      - ./stirling-data/configs:/configs
    environment:
      - SECURITY_ENABLELOGIN=false
      - LANGS=en_GB
    restart: unless-stopped
EOF
cd ~ || exit
cat > ~/.config/systemd/user/stirlingpdf.service <<EOF
[Unit]
Description=Stirling PDF
After=docker.service

[Service]
WorkingDirectory=${HOME}/stirlingpdf
ExecStart=/usr/bin/docker compose up
ExecStop=/usr/bin/docker compose stop
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now stirlingpdf.service
wget --tries=100 --retry-connrefused --waitretry=5 -O studio.html https://developer.android.com/studio
# shellcheck disable=2155
export CMDLINETOOLS="$(awk '/<table class="download">/ { count++ }
count >= 2 {
  if (match($0, /commandlinetools-linux-.*zip/)) {
    print substr($0, RSTART, RLENGTH)
    exit
  }
}' studio.html)"
rm studio.html*
wget --tries=100 --retry-connrefused --waitretry=5 "https://dl.google.com/android/repository/${CMDLINETOOLS}"
unzip "$CMDLINETOOLS"
mkdir -p ~/Android/Sdk/cmdline-tools/latest
mv cmdline-tools/* ~/Android/Sdk/cmdline-tools/latest
rm -r cmdline-tools
rm "$CMDLINETOOLS"*
cd ~/Android/Sdk/cmdline-tools/latest/bin || exit
echo y | ./sdkmanager "platform-tools"
cd ~ || exit
sudo tee /etc/udev/rules.d/52-xilinx-usb.rules >/dev/null <<'EOF'
SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE="0666", GROUP="plugdev"
EOF
sudo udevadm control --reload-rules
sudo udevadm trigger
sudo usermod -aG plugdev "$USER"
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' kristoff-it/superhtml x86_64-linux-musl.tar.xz
tar -xJf x86_64-linux-musl.tar.xz
rm x86_64-linux-musl.tar.xz
mv superhtml ~/.local/bin/
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
systemctl --user enable --now clipcascade-server.service
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
systemctl --user enable clipcascade-client.service
sudo DEBIAN_FRONTEND=noninteractive apt install libxml2-utils libxslt1.1 -y
git clone --depth=1 https://codeberg.org/c4ffe14e/phice.git
cd phice || exit
uv sync
cp config.example.toml config.toml
cd ~ || exit
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' gulp79/rclone-extra rclone-linux-amd64.zip
unzip rclone-linux-amd64.zip
rm rclone-linux-amd64.zip*
mv rclone ~/.local/bin/
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' Genymobile/scrcpy 'scrcpy-linux-x86_64-*.tar.gz'
tar -xzf scrcpy-linux-x86_64-*.tar.gz
mv scrcpy-linux-x86_64-*/adb ~/.local/bin/
mv scrcpy-linux-x86_64-*/scrcpy ~/.local/bin/
rm -r scrcpy-linux-x86_64-*
wget --tries=100 --retry-connrefused --waitretry=5 https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt -O ~/.eff_large_wordlist.txt
sudo DEBIAN_FRONTEND=noninteractive apt install libeigen3-dev libzip-dev zlib1g-dev -y
sudo DEBIAN_FRONTEND=noninteractive apt install clinfo ocl-icd-opencl-dev -y
git clone --depth=1 https://github.com/lightvector/KataGo.git
cd KataGo/cpp || exit
if clinfo -l | grep -q 'Platform'; then
cmake . -G Ninja -DUSE_BACKEND=OPENCL
else
cmake . -G Ninja -DUSE_BACKEND=EIGEN
fi
ninja
cd ../.. || exit
mkdir katago-networks
cd katago-networks || exit
wget --tries=100 --retry-connrefused --waitretry=5 https://media.katagotraining.org/uploaded/networks/models/kata1/kata1-b6c96-s175395328-d26788732.txt.gz
cd ~ || exit
sudo DEBIAN_FRONTEND=noninteractive apt install maven -y
git clone --depth=1 https://github.com/yzyray/lizzieyzy.git
cd lizzieyzy || exit
mvn clean package
cd ~ || exit
rm -rf ~/.m2/repository
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
git clone --depth=1 https://github.com/fairy-stockfish/Fairy-Stockfish.git
cd Fairy-Stockfish/src || exit
make -j ARCH=x86-64 profile-build largeboards=yes nnue=yes
cd ~ || exit
sudo DEBIAN_FRONTEND=noninteractive apt install qt6-base-dev qt6-base-dev-tools qt6-svg-dev qt6-5compat-dev -y
git clone --depth=1 https://github.com/cutechess/cutechess.git
cd cutechess || exit
mkdir build
cd build || exit
cmake -G Ninja ..
ninja
cd ~ || exit
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
sudo DEBIAN_FRONTEND=noninteractive apt install libqt5svg5-dev qt5-qmake qtbase5-dev qtbase5-dev-tools -y
git clone --depth=1 https://github.com/hotfics/Sylvan.git
cd Sylvan || exit
qmake
make
cd ~ || exit
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
if [ "$TEST" -eq 0 ]; then
wget --tries=100 --retry-connrefused --waitretry=5 https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xzf install-tl-unx.tar.gz
rm install-tl-unx.tar.gz*
cd install-tl-* || exit
sudo perl ./install-tl --no-interaction
cd ~ || exit
rm -rf install-tl-*
sudo /usr/local/texlive/2026/bin/x86_64-linux/tlmgr update --all --self --reinstall-forcibly-removed
fi
mkdir -p ~/.config/fontconfig/conf.d
cat > ~/.config/fontconfig/conf.d/00-noto.conf <<'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
<match target="pattern">
  <test name="family">
    <string>system-ui</string>
  </test>
  <edit name="family" mode="prepend" binding="strong">
    <string>sans-serif</string>
  </edit>
</match>
<match target="pattern">
  <test name="family">
    <string>sans-serif</string>
  </test>
  <edit name="family" mode="prepend" binding="strong">
    <string>Noto Sans</string>
    <string>Noto Sans CJK TC</string>
    <string>Noto Sans CJK SC</string>
    <string>Noto Sans CJK JP</string>
    <string>Noto Sans CJK KR</string>
    <string>Noto Sans CJK HK</string>
    <string>Noto Color Emoji</string>
  </edit>
</match>
<match target="pattern">
  <test name="family">
    <string>serif</string>
  </test>
  <edit name="family" mode="prepend" binding="strong">
    <string>Noto Serif</string>
    <string>Noto Serif CJK TC</string>
    <string>Noto Serif CJK SC</string>
    <string>Noto Serif CJK JP</string>
    <string>Noto Serif CJK KR</string>
    <string>Noto Serif CJK HK</string>
    <string>Noto Color Emoji</string>
  </edit>
</match>
<match target="pattern">
  <test name="family">
    <string>monospace</string>
  </test>
  <edit name="family" mode="prepend" binding="strong">
    <string>Noto Sans Mono</string>
    <string>Noto Sans Mono CJK TC</string>
    <string>Noto Sans Mono CJK SC</string>
    <string>Noto Sans Mono CJK JP</string>
    <string>Noto Sans Mono CJK KR</string>
    <string>Noto Sans Mono CJK HK</string>
    <string>Noto Color Emoji</string>
  </edit>
</match>
</fontconfig>
EOF
cat > ~/.config/fontconfig/conf.d/01-replace.conf <<'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
<match target="pattern">
  <test name="family">
    <string>DFKai-SB</string>
  </test>
  <edit name="family" mode="prepend" binding="strong">
    <string>TW-Kai</string>
  </edit>
</match>
<match target="pattern">
  <test name="family">
    <string>MingLiu</string>
  </test>
  <edit name="family" mode="prepend" binding="strong">
    <string>TW-Sung</string>
  </edit>
</match>
<match target="pattern">
  <test name="family">
    <string>PMingLiu</string>
  </test>
  <edit name="family" mode="prepend" binding="strong">
    <string>TW-Sung</string>
  </edit>
</match>
<match target="pattern">
  <test name="family">
    <string>Microsoft JhengHei</string>
  </test>
  <edit name="family" mode="prepend" binding="strong">
    <string>WenQuanYi Zen Hei</string>
  </edit>
</match>
</fontconfig>
EOF
cat > ~/.config/fontconfig/conf.d/99-texlive.conf <<'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <dir>/usr/local/texlive/2026/texmf-dist/fonts</dir>
</fontconfig>
EOF
[ "$TEST" -eq 0 ] && sudo fc-cache -fv
cd /usr/share || exit
sudo git clone https://github.com/Willie169/LaTeX-ToolKit
cd ~ || exit
mkdir -p texmf
cd texmf || exit
mkdir -p tex
cd tex || exit
mkdir -p latex
cd latex || exit
git clone https://github.com/Willie169/physics-patch
cd physics-patch || exit
git checkout dev
cd ~ || exit
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -f -y
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
sudo DEBIAN_FRONTEND=noninteractive apt autoremove --purge -y
sudo apt clean
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
if [ "$FULL" -eq 0 ];then
kill "$SUDOPIDFIRST"
kill "$SUDOPIDSECOND"
kill "$SUDOPIDTHIRD"
kill "$SUDOPIDFOURTH"
fi
# shellcheck disable=2155
POSTDF=$(df --output=used / | tail -n1)
echo "PREDF: $PREDF"
echo "POSTDF: $POSTDF"
[ "$TEST" -eq 0 ] && [ "$FULL" -eq 0 ] && sudo reboot || true
