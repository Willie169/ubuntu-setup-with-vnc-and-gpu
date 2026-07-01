#!/bin/bash
set -euxo pipefail
shopt -s expand_aliases
TEST=0
FULL=0
[ "${1:-}" = '--test' ] && TEST=1
[ "${2:-}" = '--test' ] && TEST=1
[ "${1:-}" = '--full' ] && FULL=1
[ "${2:-}" = '--full' ] && FULL=1
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
sudo mkdir -p /usr/local/java
sudo mkdir -p /etc/apt/apt.conf.d
sudo mkdir -p /etc/apt/keyrings
sudo mkdir -p /etc/systemd/system
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/applications
mkdir -p ~/.local/share/fonts
mkdir -p ~/Desktop
mkdir -p ~/.config/systemd/user
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
sudo DEBIAN_FRONTEND=noninteractive apt install plasma-workspace-wayland -y -o Dpkg::Options::="--force-confnew"
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
sudo DEBIAN_FRONTEND=noninteractive apt install software-properties-common -y -o Dpkg::Options::="--force-confnew"
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
sudo DEBIAN_FRONTEND=noninteractive apt install apt-transport-https bash build-essential ca-certificates coreutils cmake curl dbus openjdk-21-jdk g++ gcc git gnupg grep gzip jq locales lsb-release make ninja-build openssh-server perl perl-tk pipx python-is-python3 python3 vim-gtk3 wget xz-utils -y -o Dpkg::Options::="--force-confnew"
sudo DEBIAN_FRONTEND=noninteractive apt install apparmor-utils clinfo dnsmasq fcitx5 fcitx5-* flatpak language-pack-gnome-en network-manager pipewire pipewire-audio-client-libraries snapd ufw unattended-upgrades wireplumber -y -o Dpkg::Options::="--force-confnew"
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
sudo DEBIAN_FRONTEND=noninteractive apt install firefox --allow-downgrades -y -o Dpkg::Options::="--force-confnew"
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
sudo DEBIAN_FRONTEND=noninteractive apt install thunderbird --allow-downgrades -y -o Dpkg::Options::="--force-confnew"
sudo rm /var/lib/snapd/desktop/applications/thunderbird*.desktop 2>/dev/null || true
sudo add-apt-repository ppa:xtradeb/apps -y
echo 'Package: chromium*
Pin: release o=LP-PPA-xtradeb-apps
Pin-Priority: 1001

Package: chromium*
Pin: release o=Ubuntu
Pin-Priority: -1' | sudo tee /etc/apt/preferences.d/chromium >/dev/null
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y -o Dpkg::Options::="--force-confnew"
echo 'APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "1";' | sudo tee /etc/apt/apt.conf.d/10periodic >/dev/null
echo 'APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";' | sudo tee /etc/apt/apt.conf.d/20auto-upgrades >/dev/null
sudo mv /etc/apt/apt.conf.d/20apt-esm-hook.conf /etc/apt/apt.conf.d/20apt-esm-hook.conf.bak || true
sudo touch /etc/apt/apt.conf.d/20apt-esm-hook.conf
sudo touch /var/lib/update-notifier/hide-esm-in-motd || true
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
Unattended-Upgrade::Remove-Unused-Dependencies "true";

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
sudo DEBIAN_FRONTEND=noninteractive apt install $PKG -y -o Dpkg::Options::="--force-confnew"
else
sudo DEBIAN_FRONTEND=noninteractive apt install $PKG -y -s -o Dpkg::Options::="--force-confnew"
fi
PKG='apparmor-utils aria2 bridge-utils clang-uml clinfo distrobox dnsmasq fcitx5 fcitx5-* filelight flatpak fwupd gnome-keyring gtkwave kate krita language-pack-gnome-en libvirt-daemon-system libvirt-clients lxc lxc-templates network-manager ntfs-3g obs-studio ovmf pipewire pipewire-audio-client-libraries podman qbittorrent qemu-system-gui qemu-system-x86 qemu-user-binfmt qemu-user qemu-utils qtspeech5-speechd-plugin quickemu remmina remmina-plugin-rdp remmina-plugin-secret snapd spice-vdagent swtpm swtpm-tools testdisk torbrowser-launcher ufw uidmap unattended-upgrades virt-manager virt-viewer wireplumber wl-clipboard xclip'
# shellcheck disable=2086
if [ "$TEST" -eq 0 ]; then
sudo DEBIAN_FRONTEND=noninteractive apt install $PKG -y -o Dpkg::Options::="--force-confnew"
else
sudo DEBIAN_FRONTEND=noninteractive apt install $PKG -y -s -o Dpkg::Options::="--force-confnew"
fi
sudo snap set system refresh.retain=2
systemctl --user restart pipewire pipewire-pulse wireplumber
sudo systemctl disable --now systemd-resolved
echo '[main]
dns=dnsmasq
plugins=ifupdown,keyfile

[ifupdown]
managed=true

[device]
wifi.scan-rand-mac-address=yes' | sudo tee /etc/NetworkManager/NetworkManager.conf >/dev/null
sudo mkdir -p /etc/NetworkManager/dnsmasq.d
sudo tee /etc/NetworkManager/dnsmasq.d/dnsmasq.conf <<'EOF'
# Configuration file for dnsmasq.
#
# Format is one option per line, legal options are the same
# as the long options legal on the command line. See
# "/usr/sbin/dnsmasq --help" or "man 8 dnsmasq" for details.

# Listen on this specific port instead of the standard DNS port
# (53). Setting this to zero completely disables DNS function,
# leaving only DHCP and/or TFTP.
#port=5353

# The following two options make you a better netizen, since they
# tell dnsmasq to filter out queries which the public DNS cannot
# answer, and which load the servers (especially the root servers)
# unnecessarily. If you have a dial-on-demand link they also stop
# these requests from bringing up the link unnecessarily.

# Never forward plain names (without a dot or domain part)
domain-needed
# Never forward addresses in the non-routed address spaces.
bogus-priv

# Uncomment these to enable DNSSEC validation and caching:
# (Requires dnsmasq to be built with DNSSEC option.)
conf-file=/usr/share/dnsmasq/trust-anchors.conf
dnssec

# Replies which are not DNSSEC signed may be legitimate, because the domain
# is unsigned, or may be forgeries. Setting this option tells dnsmasq to
# check that an unsigned reply is OK, by finding a secure proof that a DS
# record somewhere between the root and the domain does not exist.
# The cost of setting this is that even queries in unsigned domains will need
# one or more extra DNS queries to verify.
#dnssec-check-unsigned

# Uncomment this to filter useless windows-originated DNS requests
# which can trigger dial-on-demand links needlessly.
# Note that (amongst other things) this blocks all SRV requests,
# so don't use it if you use eg Kerberos, SIP, XMMP or Google-talk.
# This option only affects forwarding, SRV records originating for
# dnsmasq (via srv-host= lines) are not suppressed by it.
#filterwin2k

# Change this line if you want dns to get its upstream servers from
# somewhere other that /etc/resolv.conf
#resolv-file=

# By  default,  dnsmasq  will  send queries to any of the upstream
# servers it knows about and tries to favour servers to are  known
# to  be  up.  Uncommenting this forces dnsmasq to try each query
# with  each  server  strictly  in  the  order  they   appear   in
# /etc/resolv.conf
#strict-order

# If you don't want dnsmasq to read /etc/resolv.conf or any other
# file, getting its servers from this file instead (see below), then
# uncomment this.
no-resolv

# If you don't want dnsmasq to poll /etc/resolv.conf or other resolv
# files for changes and re-read them then uncomment this.
#no-poll

# Add other name servers here, with domain specs if they are for
# non-public domains.
#server=/localnet/192.168.0.1
server=1.1.1.1
server=1.0.0.1
server=2606:4700:4700::1111
server=2606:4700:4700::1001
server=94.140.14.140
server=94.140.14.141
server=2a10:50c0::1:ff
server=2a10:50c0::2:ff
server=/ts.net/100.100.100.100

# Example of routing PTR queries to nameservers: this will send all
# address->name queries for 192.168.3/24 to nameserver 10.1.2.3
#server=/3.168.192.in-addr.arpa/10.1.2.3

# Add local-only domains here, queries in these domains are answered
# from /etc/hosts or DHCP only.
#local=/localnet/

# Add domains which you want to force to an IP address here.
# The example below send any host in double-click.net to a local
# web-server.
#address=/double-click.net/127.0.0.1

# --address (and --server) work with IPv6 addresses too.
#address=/www.thekelleys.org.uk/fe80::20d:60ff:fe36:f83

# Add the IPs of all queries to yahoo.com, google.com, and their
# subdomains to the vpn and search ipsets:
#ipset=/yahoo.com/google.com/vpn,search

# Add the IPs of all queries to yahoo.com, google.com, and their
# subdomains to netfilters sets, which is equivalent to
# 'nft add element ip test vpn { ... }; nft add element ip test search { ... }'
#nftset=/yahoo.com/google.com/ip#test#vpn,ip#test#search

# Use netfilters sets for both IPv4 and IPv6:
# This adds all addresses in *.yahoo.com to vpn4 and vpn6 for IPv4 and IPv6 addresses.
#nftset=/yahoo.com/4#ip#test#vpn4
#nftset=/yahoo.com/6#ip#test#vpn6

# You can control how dnsmasq talks to a server: this forces
# queries to 10.1.2.3 to be routed via eth1
# server=10.1.2.3@eth1

# and this sets the source (ie local) address used to talk to
# 10.1.2.3 to 192.168.1.1 port 55 (there must be an interface with that
# IP on the machine, obviously).
# server=10.1.2.3@192.168.1.1#55

# If you want dnsmasq to change uid and gid to something other
# than the default, edit the following lines.
#user=
#group=

# If you want dnsmasq to listen for DHCP and DNS requests only on
# specified interfaces (and the loopback) give the name of the
# interface (eg eth0) here.
# Repeat the line for more than one interface.
#interface=
# Or you can specify which interface _not_ to listen on
#except-interface=
# Or which to listen on by address (remember to include 127.0.0.1 if
# you use this.)
listen-address=127.0.0.1
listen-address=::1
# If you want dnsmasq to provide only DNS service on an interface,
# configure it as shown above, and then use the following line to
# disable DHCP and TFTP on it.
#no-dhcp-interface=

# On systems which support it, dnsmasq binds the wildcard address,
# even when it is listening on only some interfaces. It then discards
# requests that it shouldn't reply to. This has the advantage of
# working even when interfaces come and go and change address. If you
# want dnsmasq to really bind only the interfaces it is listening on,
# uncomment this option. About the only time you may need this is when
# running another nameserver on the same machine.
bind-interfaces

# If you don't want dnsmasq to read /etc/hosts, uncomment the
# following line.
#no-hosts
# or if you want it to read another file, as well as /etc/hosts, use
# this.
#addn-hosts=/etc/banner_add_hosts

# Set this (and domain: see below) if you want to have a domain
# automatically added to simple names in a hosts-file.
expand-hosts

# Set the domain for dnsmasq. this is optional, but if it is set, it
# does the following things.
# 1) Allows DHCP hosts to have fully qualified domain names, as long
#     as the domain part matches this setting.
# 2) Sets the "domain" DHCP option thereby potentially setting the
#    domain of all systems configured by DHCP
# 3) Provides the domain part for "expand-hosts"
#domain=thekelleys.org.uk

# Set a different domain for a particular subnet
#domain=wireless.thekelleys.org.uk,192.168.2.0/24

# Same idea, but range rather then subnet
#domain=reserved.thekelleys.org.uk,192.68.3.100,192.168.3.200

# Uncomment this to enable the integrated DHCP server, you need
# to supply the range of addresses available for lease and optionally
# a lease time. If you have more than one network, you will need to
# repeat this for each network on which you want to supply DHCP
# service.
#dhcp-range=192.168.0.50,192.168.0.150,12h

# This is an example of a DHCP range where the netmask is given. This
# is needed for networks we reach the dnsmasq DHCP server via a relay
# agent. If you don't know what a DHCP relay agent is, you probably
# don't need to worry about this.
#dhcp-range=192.168.0.50,192.168.0.150,255.255.255.0,12h

# This is an example of a DHCP range which sets a tag, so that
# some DHCP options may be set only for this network.
#dhcp-range=set:red,192.168.0.50,192.168.0.150

# Use this DHCP range only when the tag "green" is set.
#dhcp-range=tag:green,192.168.0.50,192.168.0.150,12h

# Specify a subnet which can't be used for dynamic address allocation,
# is available for hosts with matching --dhcp-host lines. Note that
# dhcp-host declarations will be ignored unless there is a dhcp-range
# of some type for the subnet in question.
# In this case the netmask is implied (it comes from the network
# configuration on the machine running dnsmasq) it is possible to give
# an explicit netmask instead.
#dhcp-range=192.168.0.0,static

# Enable DHCPv6. Note that the prefix-length does not need to be specified
# and defaults to 64 if missing/
#dhcp-range=1234::2, 1234::500, 64, 12h

# Do Router Advertisements, BUT NOT DHCP for this subnet.
#dhcp-range=1234::, ra-only

# Do Router Advertisements, BUT NOT DHCP for this subnet, also try and
# add names to the DNS for the IPv6 address of SLAAC-configured dual-stack
# hosts. Use the DHCPv4 lease to derive the name, network segment and
# MAC address and assume that the host will also have an
# IPv6 address calculated using the SLAAC algorithm.
#dhcp-range=1234::, ra-names

# Do Router Advertisements, BUT NOT DHCP for this subnet.
# Set the lifetime to 46 hours. (Note: minimum lifetime is 2 hours.)
#dhcp-range=1234::, ra-only, 48h

# Do DHCP and Router Advertisements for this subnet. Set the A bit in the RA
# so that clients can use SLAAC addresses as well as DHCP ones.
#dhcp-range=1234::2, 1234::500, slaac

# Do Router Advertisements and stateless DHCP for this subnet. Clients will
# not get addresses from DHCP, but they will get other configuration information.
# They will use SLAAC for addresses.
#dhcp-range=1234::, ra-stateless

# Do stateless DHCP, SLAAC, and generate DNS names for SLAAC addresses
# from DHCPv4 leases.
#dhcp-range=1234::, ra-stateless, ra-names

# Do router advertisements for all subnets where we're doing DHCPv6
# Unless overridden by ra-stateless, ra-names, et al, the router
# advertisements will have the M and O bits set, so that the clients
# get addresses and configuration from DHCPv6, and the A bit reset, so the
# clients don't use SLAAC addresses.
#enable-ra

# Supply parameters for specified hosts using DHCP. There are lots
# of valid alternatives, so we will give examples of each. Note that
# IP addresses DO NOT have to be in the range given above, they just
# need to be on the same network. The order of the parameters in these
# do not matter, it's permissible to give name, address and MAC in any
# order.

# Always allocate the host with Ethernet address 11:22:33:44:55:66
# The IP address 192.168.0.60
#dhcp-host=11:22:33:44:55:66,192.168.0.60

# Always set the name of the host with hardware address
# 11:22:33:44:55:66 to be "fred"
#dhcp-host=11:22:33:44:55:66,fred

# Always give the host with Ethernet address 11:22:33:44:55:66
# the name fred and IP address 192.168.0.60 and lease time 45 minutes
#dhcp-host=11:22:33:44:55:66,fred,192.168.0.60,45m

# Give a host with Ethernet address 11:22:33:44:55:66 or
# 12:34:56:78:90:12 the IP address 192.168.0.60. Dnsmasq will assume
# that these two Ethernet interfaces will never be in use at the same
# time, and give the IP address to the second, even if it is already
# in use by the first. Useful for laptops with wired and wireless
# addresses.
#dhcp-host=11:22:33:44:55:66,12:34:56:78:90:12,192.168.0.60

# Give the machine which says its name is "bert" IP address
# 192.168.0.70 and an infinite lease
#dhcp-host=bert,192.168.0.70,infinite

# Always give the host with client identifier 01:02:02:04
# the IP address 192.168.0.60
#dhcp-host=id:01:02:02:04,192.168.0.60

# Always give the InfiniBand interface with hardware address
# 80:00:00:48:fe:80:00:00:00:00:00:00:f4:52:14:03:00:28:05:81 the
# ip address 192.168.0.61. The client id is derived from the prefix
# ff:00:00:00:00:00:02:00:00:02:c9:00 and the last 8 pairs of
# hex digits of the hardware address.
#dhcp-host=id:ff:00:00:00:00:00:02:00:00:02:c9:00:f4:52:14:03:00:28:05:81,192.168.0.61

# Always give the host with client identifier "marjorie"
# the IP address 192.168.0.60
#dhcp-host=id:marjorie,192.168.0.60

# Enable the address given for "judge" in /etc/hosts
# to be given to a machine presenting the name "judge" when
# it asks for a DHCP lease.
#dhcp-host=judge

# Never offer DHCP service to a machine whose Ethernet
# address is 11:22:33:44:55:66
#dhcp-host=11:22:33:44:55:66,ignore

# Ignore any client-id presented by the machine with Ethernet
# address 11:22:33:44:55:66. This is useful to prevent a machine
# being treated differently when running under different OS's or
# between PXE boot and OS boot.
#dhcp-host=11:22:33:44:55:66,id:*

# Send extra options which are tagged as "red" to
# the machine with Ethernet address 11:22:33:44:55:66
#dhcp-host=11:22:33:44:55:66,set:red

# Send extra options which are tagged as "red" to
# any machine with Ethernet address starting 11:22:33:
#dhcp-host=11:22:33:*:*:*,set:red

# Give a fixed IPv6 address and name to client with
# DUID 00:01:00:01:16:d2:83:fc:92:d4:19:e2:d8:b2
# Note the MAC addresses CANNOT be used to identify DHCPv6 clients.
# Note also that the [] around the IPv6 address are obligatory.
#dhcp-host=id:00:01:00:01:16:d2:83:fc:92:d4:19:e2:d8:b2, fred, [1234::5]

# Ignore any clients which are not specified in dhcp-host lines
# or /etc/ethers. Equivalent to ISC "deny unknown-clients".
# This relies on the special "known" tag which is set when
# a host is matched.
#dhcp-ignore=tag:!known

# Send extra options which are tagged as "red" to any machine whose
# DHCP vendorclass string includes the substring "Linux"
#dhcp-vendorclass=set:red,Linux

# Send extra options which are tagged as "red" to any machine one
# of whose DHCP userclass strings includes the substring "accounts"
#dhcp-userclass=set:red,accounts

# Send extra options which are tagged as "red" to any machine whose
# MAC address matches the pattern.
#dhcp-mac=set:red,00:60:8C:*:*:*

# If this line is uncommented, dnsmasq will read /etc/ethers and act
# on the ethernet-address/IP pairs found there just as if they had
# been given as --dhcp-host options. Useful if you keep
# MAC-address/host mappings there for other purposes.
#read-ethers

# Send options to hosts which ask for a DHCP lease.
# See RFC 2132 for details of available options.
# Common options can be given to dnsmasq by name:
# run "dnsmasq --help dhcp" to get a list.
# Note that all the common settings, such as netmask and
# broadcast address, DNS server and default route, are given
# sane defaults by dnsmasq. You very likely will not need
# any dhcp-options. If you use Windows clients and Samba, there
# are some options which are recommended, they are detailed at the
# end of this section.

# Override the default route supplied by dnsmasq, which assumes the
# router is the same machine as the one running dnsmasq.
#dhcp-option=3,1.2.3.4

# Do the same thing, but using the option name
#dhcp-option=option:router,1.2.3.4

# Override the default route supplied by dnsmasq and send no default
# route at all. Note that this only works for the options sent by
# default (1, 3, 6, 12, 28) the same line will send a zero-length option
# for all other option numbers.
#dhcp-option=3

# Set the NTP time server addresses to 192.168.0.4 and 10.10.0.5
#dhcp-option=option:ntp-server,192.168.0.4,10.10.0.5

# Send DHCPv6 option. Note [] around IPv6 addresses.
#dhcp-option=option6:dns-server,[1234::77],[1234::88]

# Send DHCPv6 option for namservers as the machine running
# dnsmasq and another.
#dhcp-option=option6:dns-server,[::],[1234::88]

# Ask client to poll for option changes every six hours. (RFC4242)
#dhcp-option=option6:information-refresh-time,6h

# Set option 58 client renewal time (T1). Defaults to half of the
# lease time if not specified. (RFC2132)
#dhcp-option=option:T1,1m

# Set option 59 rebinding time (T2). Defaults to 7/8 of the
# lease time if not specified. (RFC2132)
#dhcp-option=option:T2,2m

# Set the NTP time server address to be the same machine as
# is running dnsmasq
#dhcp-option=42,0.0.0.0

# Set the NIS domain name to "welly"
#dhcp-option=40,welly

# Set the default time-to-live to 50
#dhcp-option=23,50

# Set the "all subnets are local" flag
#dhcp-option=27,1

# Send the etherboot magic flag and then etherboot options (a string).
#dhcp-option=128,e4:45:74:68:00:00
#dhcp-option=129,NIC=eepro100

# Specify an option which will only be sent to the "red" network
# (see dhcp-range for the declaration of the "red" network)
# Note that the tag: part must precede the option: part.
#dhcp-option = tag:red, option:ntp-server, 192.168.1.1

# The following DHCP options set up dnsmasq in the same way as is specified
# for the ISC dhcpcd in
# https://web.archive.org/web/20040313070105/http://us1.samba.org/samba/ftp/docs/textdocs/DHCP-Server-Configuration.txt
# adapted for a typical dnsmasq installation where the host running
# dnsmasq is also the host running samba.
# you may want to uncomment some or all of them if you use
# Windows clients and Samba.
#dhcp-option=19,0           # option ip-forwarding off
#dhcp-option=44,0.0.0.0     # set netbios-over-TCP/IP nameserver(s) aka WINS server(s)
#dhcp-option=45,0.0.0.0     # netbios datagram distribution server
#dhcp-option=46,8           # netbios node type

# Send an empty WPAD option. This may be REQUIRED to get windows 7 to behave.
#dhcp-option=252,"\n"

# Send RFC-3397 DNS domain search DHCP option. WARNING: Your DHCP client
# probably doesn't support this......
#dhcp-option=option:domain-search,eng.apple.com,marketing.apple.com

# Send RFC-3442 classless static routes (note the netmask encoding)
#dhcp-option=121,192.168.1.0/24,1.2.3.4,10.0.0.0/8,5.6.7.8

# Send vendor-class specific options encapsulated in DHCP option 43.
# The meaning of the options is defined by the vendor-class so
# options are sent only when the client supplied vendor class
# matches the class given here. (A substring match is OK, so "MSFT"
# matches "MSFT" and "MSFT 5.0"). This example sets the
# mtftp address to 0.0.0.0 for PXEClients.
#dhcp-option=vendor:PXEClient,1,0.0.0.0

# Send microsoft-specific option to tell windows to release the DHCP lease
# when it shuts down. Note the "i" flag, to tell dnsmasq to send the
# value as a four-byte integer - that's what microsoft wants. See
# http://technet2.microsoft.com/WindowsServer/en/library/a70f1bb7-d2d4-49f0-96d6-4b7414ecfaae1033.mspx?mfr=true
#dhcp-option=vendor:MSFT,2,1i

# Send the Encapsulated-vendor-class ID needed by some configurations of
# Etherboot to allow is to recognise the DHCP server.
#dhcp-option=vendor:Etherboot,60,"Etherboot"

# Send options to PXELinux. Note that we need to send the options even
# though they don't appear in the parameter request list, so we need
# to use dhcp-option-force here.
# See http://syslinux.zytor.com/pxe.php#special for details.
# Magic number - needed before anything else is recognised
#dhcp-option-force=208,f1:00:74:7e
# Configuration file name
#dhcp-option-force=209,configs/common
# Path prefix
#dhcp-option-force=210,/tftpboot/pxelinux/files/
# Reboot time. (Note 'i' to send 32-bit value)
#dhcp-option-force=211,30i

# Set the boot filename for netboot/PXE. You will only need
# this if you want to boot machines over the network and you will need
# a TFTP server; either dnsmasq's built-in TFTP server or an
# external one. (See below for how to enable the TFTP server.)
#dhcp-boot=pxelinux.0

# The same as above, but use custom tftp-server instead machine running dnsmasq
#dhcp-boot=pxelinux,server.name,192.168.1.100

# Boot for iPXE. The idea is to send two different
# filenames, the first loads iPXE, and the second tells iPXE what to
# load. The dhcp-match sets the ipxe tag for requests from iPXE.
#dhcp-boot=undionly.kpxe
#dhcp-match=set:ipxe,175 # iPXE sends a 175 option.
#dhcp-boot=tag:ipxe,http://boot.ipxe.org/demo/boot.php

# Encapsulated options for iPXE. All the options are
# encapsulated within option 175
#dhcp-option=encap:175, 1, 5b         # priority code
#dhcp-option=encap:175, 176, 1b       # no-proxydhcp
#dhcp-option=encap:175, 177, string   # bus-id
#dhcp-option=encap:175, 189, 1b       # BIOS drive code
#dhcp-option=encap:175, 190, user     # iSCSI username
#dhcp-option=encap:175, 191, pass     # iSCSI password

# Test for the architecture of a netboot client. PXE clients are
# supposed to send their architecture as option 93. (See RFC 4578)
#dhcp-match=peecees, option:client-arch, 0 #x86-32
#dhcp-match=itanics, option:client-arch, 2 #IA64
#dhcp-match=hammers, option:client-arch, 6 #x86-64
#dhcp-match=mactels, option:client-arch, 7 #EFI x86-64

# Do real PXE, rather than just booting a single file, this is an
# alternative to dhcp-boot.
#pxe-prompt="What system shall I netboot?"
# or with timeout before first available action is taken:
#pxe-prompt="Press F8 for menu.", 60

# Available boot services. for PXE.
#pxe-service=x86PC, "Boot from local disk"

# Loads <tftp-root>/pxelinux.0 from dnsmasq TFTP server.
#pxe-service=x86PC, "Install Linux", pxelinux

# Loads <tftp-root>/pxelinux.0 from TFTP server at 1.2.3.4.
# Beware this fails on old PXE ROMS.
#pxe-service=x86PC, "Install Linux", pxelinux, 1.2.3.4

# Use bootserver on network, found my multicast or broadcast.
#pxe-service=x86PC, "Install windows from RIS server", 1

# Use bootserver at a known IP address.
#pxe-service=x86PC, "Install windows from RIS server", 1, 1.2.3.4

# If you have multicast-FTP available,
# information for that can be passed in a similar way using options 1
# to 5. See page 19 of
# http://download.intel.com/design/archives/wfm/downloads/pxespec.pdf


# Enable dnsmasq's built-in TFTP server
#enable-tftp

# Set the root directory for files available via FTP.
#tftp-root=/var/ftpd

# Do not abort if the tftp-root is unavailable
#tftp-no-fail

# Make the TFTP server more secure: with this set, only files owned by
# the user dnsmasq is running as will be send over the net.
#tftp-secure

# This option stops dnsmasq from negotiating a larger blocksize for TFTP
# transfers. It will slow things down, but may rescue some broken TFTP
# clients.
#tftp-no-blocksize

# Set the boot file name only when the "red" tag is set.
#dhcp-boot=tag:red,pxelinux.red-net

# An example of dhcp-boot with an external TFTP server: the name and IP
# address of the server are given after the filename.
# Can fail with old PXE ROMS. Overridden by --pxe-service.
#dhcp-boot=/var/ftpd/pxelinux.0,boothost,192.168.0.3

# If there are multiple external tftp servers having a same name
# (using /etc/hosts) then that name can be specified as the
# tftp_servername (the third option to dhcp-boot) and in that
# case dnsmasq resolves this name and returns the resultant IP
# addresses in round robin fashion. This facility can be used to
# load balance the tftp load among a set of servers.
#dhcp-boot=/var/ftpd/pxelinux.0,boothost,tftp_server_name

# Set the limit on DHCP leases, the default is 150
#dhcp-lease-max=150

# The DHCP server needs somewhere on disk to keep its lease database.
# This defaults to a sane location, but if you want to change it, use
# the line below.
#dhcp-leasefile=/var/lib/misc/dnsmasq.leases

# Set the DHCP server to authoritative mode. In this mode it will barge in
# and take over the lease for any client which broadcasts on the network,
# whether it has a record of the lease or not. This avoids long timeouts
# when a machine wakes up on a new network. DO NOT enable this if there's
# the slightest chance that you might end up accidentally configuring a DHCP
# server for your campus/company accidentally. The ISC server uses
# the same option, and this URL provides more information:
# http://www.isc.org/files/auth.html
#dhcp-authoritative

# Set the DHCP server to enable DHCPv4 Rapid Commit Option per RFC 4039.
# In this mode it will respond to a DHCPDISCOVER message including a Rapid Commit
# option with a DHCPACK including a Rapid Commit option and fully committed address
# and configuration information. This must only be enabled if either the server is
# the only server for the subnet, or multiple servers are present and they each
# commit a binding for all clients.
#dhcp-rapid-commit

# Run an executable when a DHCP lease is created or destroyed.
# The arguments sent to the script are "add" or "del",
# then the MAC address, the IP address and finally the hostname
# if there is one.
#dhcp-script=/bin/echo

# Set the cachesize here.
cache-size=1000

# If you want to disable negative caching, uncomment this.
no-negcache

# Normally responses which come from /etc/hosts and the DHCP lease
# file have Time-To-Live set as zero, which conventionally means
# do not cache further. If you are happy to trade lower load on the
# server for potentially stale date, you can set a time-to-live (in
# seconds) here.
#local-ttl=

# If you want dnsmasq to detect attempts by Verisign to send queries
# to unregistered .com and .net hosts to its sitefinder service and
# have dnsmasq instead return the correct NXDOMAIN response, uncomment
# this line. You can add similar lines to do the same for other
# registries which have implemented wildcard A records.
#bogus-nxdomain=64.94.110.11

# If you want to fix up DNS results from upstream servers, use the
# alias option. This only works for IPv4.
# This alias makes a result of 1.2.3.4 appear as 5.6.7.8
#alias=1.2.3.4,5.6.7.8
# and this maps 1.2.3.x to 5.6.7.x
#alias=1.2.3.0,5.6.7.0,255.255.255.0
# and this maps 192.168.0.10->192.168.0.40 to 10.0.0.10->10.0.0.40
#alias=192.168.0.10-192.168.0.40,10.0.0.0,255.255.255.0

# Change these lines if you want dnsmasq to serve MX records.

# Return an MX record named "maildomain.com" with target
# servermachine.com and preference 50
#mx-host=maildomain.com,servermachine.com,50

# Set the default target for MX records created using the localmx option.
#mx-target=servermachine.com

# Return an MX record pointing to the mx-target for all local
# machines.
#localmx

# Return an MX record pointing to itself for all local machines.
#selfmx

# Change the following lines if you want dnsmasq to serve SRV
# records.  These are useful if you want to serve ldap requests for
# Active Directory and other windows-originated DNS requests.
# See RFC 2782.
# You may add multiple srv-host lines.
# The fields are <name>,<target>,<port>,<priority>,<weight>
# If the domain part if missing from the name (so that is just has the
# service and protocol sections) then the domain given by the domain=
# config option is used. (Note that expand-hosts does not need to be
# set for this to work.)

# A SRV record sending LDAP for the example.com domain to
# ldapserver.example.com port 389
#srv-host=_ldap._tcp.example.com,ldapserver.example.com,389

# A SRV record sending LDAP for the example.com domain to
# ldapserver.example.com port 389 (using domain=)
#domain=example.com
#srv-host=_ldap._tcp,ldapserver.example.com,389

# Two SRV records for LDAP, each with different priorities
#srv-host=_ldap._tcp.example.com,ldapserver.example.com,389,1
#srv-host=_ldap._tcp.example.com,ldapserver.example.com,389,2

# A SRV record indicating that there is no LDAP server for the domain
# example.com
#srv-host=_ldap._tcp.example.com

# The following line shows how to make dnsmasq serve an arbitrary PTR
# record. This is useful for DNS-SD. (Note that the
# domain-name expansion done for SRV records _does_not
# occur for PTR records.)
#ptr-record=_http._tcp.dns-sd-services,"New Employee Page._http._tcp.dns-sd-services"

# Change the following lines to enable dnsmasq to serve TXT records.
# These are used for things like SPF and zeroconf. (Note that the
# domain-name expansion done for SRV records _does_not
# occur for TXT records.)

#Example SPF.
#txt-record=example.com,"v=spf1 a -all"

#Example zeroconf
#txt-record=_http._tcp.example.com,name=value,paper=A4

# Provide an alias for a "local" DNS name. Note that this _only_ works
# for targets which are names from DHCP or /etc/hosts. Give host
# "bert" another name, bertrand
#cname=bertrand,bert

# For debugging purposes, log each DNS query as it passes through
# dnsmasq.
#log-queries

# Log lots of extra information about DHCP transactions.
#log-dhcp

# Include another lot of configuration options.
#conf-file=/etc/dnsmasq.more.conf
#conf-dir=/etc/dnsmasq.d

# Include all the files in a directory except those ending in .bak
#conf-dir=/etc/dnsmasq.d,.bak

# Include all files in a directory which end in .conf
#conf-dir=/etc/dnsmasq.d/,*.conf

# If a DHCP client claims that its name is "wpad", ignore that.
# This fixes a security hole. see CERT Vulnerability VU#598349
#dhcp-name-match=set:wpad-ignore,wpad
#dhcp-ignore-names=tag:wpad-ignore

addn-hosts=/etc/dnsmasq.d/hosts
EOF
echo 'nameserver 127.0.0.1
nameservser ::1
options trust-ad' | sudo tee /etc/resolv.conf >/dev/null
sudo systemctl restart NetworkManager
sudo tee /etc/dnsmasq.d/fetch-hosts.sh <<'EOF'
#!/usr/bin/env bash
set -u

URL="https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
DIR="/etc/dnsmasq.d"
TARGET="$DIR/hosts"
TMP="$DIR/hosts.tmp"
exec 9>"$DIR/.lock"
flock -n 9 || exit 0

if curl -fsSL --max-time 10 "$URL" -o "$TMP"; then
    if [ -s "$TMP" ]; then
        mv "$TMP" "$TARGET"
    else
        rm -f "$TMP"
        exit 0
    fi
else
    rm -f "$TMP"
    exit 0
fi

exit 0
EOF
sudo chmod +x /etc/dnsmasq.d/fetch-hosts.sh
sudo tee /etc/systemd/system/fetch-hosts.service <<'EOF'
[Unit]
Description=Fetch hosts
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/etc/dnsmasq.d/fetch-hosts.sh
EOF
sudo tee /etc/systemd/system/fetch-hosts.timer <<'EOF'
[Unit]
Description=Fetch hosts timer

[Timer]
OnBootSec=1min
OnUnitActiveSec=1day

[Install]
WantedBy=timers.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now fetch-hosts.timer
sudo systemctl restart NetworkManager
im-config -n fcitx5
cat > ~/.xprofile <<'EOF'
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export INPUT_METHOD=fcitx
export SDL_IM_MODULE=fcitx
EOF
if [ "${XDG_CURRENT_DESKTOP:-}" = "KDE" ] || [[ "${DESKTOP_SESSION:-}" == *plasma* ]] || [ "${KDE_FULL_SESSION:-}" = "true" ]; then
  sudo DEBIAN_FRONTEND=noninteractive apt install plasma-discover-backend-flatpak -y -o Dpkg::Options::="--force-confnew"
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
sudo DEBIAN_FRONTEND=noninteractive apt install brave-browser -y -o Dpkg::Options::="--force-confnew"
curl -fsSL https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE | gpg --no-default-keyring --keyring gnupg-ring:/tmp/onlyoffice.gpg --import
chmod 644 /tmp/onlyoffice.gpg
sudo chown root:root /tmp/onlyoffice.gpg
sudo mv /tmp/onlyoffice.gpg /usr/share/keyrings/onlyoffice.gpg
echo 'deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] https://download.onlyoffice.com/repo/debian squeeze main' | sudo tee /etc/apt/sources.list.d/onlyoffice.list >/dev/null
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install onlyoffice-desktopeditors -y -o Dpkg::Options::="--force-confnew"
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' rustdesk/rustdesk 'rustdesk-*-x86_64.deb'
sudo DEBIAN_FRONTEND=noninteractive apt install ./rustdesk-*-x86_64.deb -y -o Dpkg::Options::="--force-confnew"
rm rustdesk-*-x86_64.deb*
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' rustdesk/rustdesk-server 'rustdesk-server-hbbs_*_amd64.deb'
sudo DEBIAN_FRONTEND=noninteractive apt install ./rustdesk-server-hbbs_*_amd64.deb -y -o Dpkg::Options::="--force-confnew"
rm rustdesk-server-hbbs_*_amd64.deb*
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' rustdesk/rustdesk-server 'rustdesk-server-hbbr_*_amd64.deb'
sudo DEBIAN_FRONTEND=noninteractive apt install ./rustdesk-server-hbbr_*_amd64.deb -y -o Dpkg::Options::="--force-confnew"
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
sudo DEBIAN_FRONTEND=noninteractive apt install lazygit -y -o Dpkg::Options::="--force-confnew"
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
pipx install 'git+https://github.com/jpstotz/better-adb-sync#BetterADBSync'
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
BREW='bat bottom broot dust fd fzf git-delta procs resvg ripgrep sevenzip yazi yq zoxide'
# shellcheck disable=2086
if [ "$TEST" -eq 0 ]; then
echo y | brew install $BREW || true
echo y | brew install $BREW
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global merge.conflictStyle zdiff3
else
echo y | brew install $BREW --dry-run
fi
brew cleanup
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
sudo DEBIAN_FRONTEND=noninteractive apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras uidmap -y -o Dpkg::Options::="--force-confnew"
sudo systemctl disable --now docker.service docker.socket
sudo rm /var/run/docker.sock
# dockerd-rootless-setuptool.sh install needs uidmap
dockerd-rootless-setuptool.sh install
sudo wget --tries=100 --retry-connrefused --waitretry=5 -O /etc/apt/keyrings/zabbly.asc https://pkgs.zabbly.com/key.asc
echo "Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/incus/stable
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/zabbly.asc
" | sudo tee /etc/apt/sources.list.d/zabbly-incus-stable.sources >/dev/null
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install incus -y -o Dpkg::Options::="--force-confnew"
sudo adduser "$USER" incus-admin
if findmnt -no FSTYPE / | grep -q btrfs; then
sudo DEBIAN_FRONTEND=noninteractive apt install btrfs-progs -y -o Dpkg::Options::="--force-confnew"
STORAGE_DRIVER=btrfs
elif findmnt -no FSTYPE / | grep -q zfs; then
sudo DEBIAN_FRONTEND=noninteractive apt install zfsutils-linux -y -o Dpkg::Options::="--force-confnew"
STORAGE_DRIVER=zfs
else
STORAGE_DRIVER=dir
fi
cat <<EOF | sudo incus admin init --preseed
config: {}
networks:
  - config:
      ipv4.address: auto
      ipv6.address: auto
    description: ""
    name: incusbr0
    type: ""
    project: default
storage_pools:
  - config:
      source: /var/lib/incus/storage-pools/default
    description: ""
    name: default
    driver: $STORAGE_DRIVER
storage_volumes: []
profiles:
  - config: {}
    description: ""
    devices:
      eth0:
        name: eth0
        network: incusbr0
        type: nic
      root:
        path: /
        pool: default
        type: disk
    name: default
    project: default
projects: []
certificates: []
cluster_groups: []
cluster: null
EOF
sudo ufw allow in on incusbr0
sudo ufw route allow in on incusbr0
sudo ufw route allow out on incusbr0
curl --retry 100 --retry-connrefused --retry-delay 5 -fsSL "https://pkgs.tailscale.com/stable/ubuntu/$UBUNTU_CODENAME.noarmor.gpg" | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl --retry 100 --retry-connrefused --retry-delay 5 -fsSL "https://pkgs.tailscale.com/stable/ubuntu/$UBUNTU_CODENAME.tailscale-keyring.list" | sudo tee /etc/apt/sources.list.d/tailscale.list >/dev/null
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install tailscale -y -o Dpkg::Options::="--force-confnew"
sudo systemctl daemon-reload
sudo systemctl enable tailscaled
wget --tries=100 --retry-connrefused --waitretry=5 -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
echo -e 'Types: deb\nURIs: https://download.vscodium.com/debs\nSuites: vscodium\nComponents: main\nArchitectures: amd64 arm64\nSigned-by: /usr/share/keyrings/vscodium-archive-keyring.gpg' | sudo tee /etc/apt/sources.list.d/vscodium.sources >/dev/null
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install codium -y -o Dpkg::Options::="--force-confnew"
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list >/dev/null
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install glow -y -o Dpkg::Options::="--force-confnew"
wget --tries=100 --retry-connrefused --waitretry=5 -O- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | sudo tee /usr/share/keyrings/deb.torproject.org-keyring.gpg >/dev/null
sudo tee /etc/apt/sources.list.d/tor.list > /dev/null <<EOF
deb [arch=amd64 signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org ${UBUNTU_CODENAME} main
deb-src [arch=amd64 signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org ${UBUNTU_CODENAME} main
EOF
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install tor torsocks deb.torproject.org-keyring -y -o Dpkg::Options::="--force-confnew"
sudo wget --tries=100 --retry-connrefused --waitretry=5 -O /usr/local/java/antlr-4.13.2-complete.jar https://www.antlr.org/download/antlr-4.13.2-complete.jar
sudo wget --tries=100 --retry-connrefused --waitretry=5 -O /usr/local/java/plantuml.jar https://sourceforge.net/projects/plantuml/files/plantuml.jar/download
sudo wget --tries=100 --retry-connrefused --waitretry=5 -O /usr/share/keyrings/element-io-archive-keyring.gpg https://packages.element.io/debian/element-io-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/element-io-archive-keyring.gpg] https://packages.element.io/debian/ default main" | sudo tee /etc/apt/sources.list.d/element-io.list >/dev/null
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install element-desktop -y -o Dpkg::Options::="--force-confnew"
docker pull ghcr.io/gchq/cyberchef:latest
cat > ~/.config/systemd/user/cyberchef.service <<EOF
[Unit]
Description=CyberChef
After=docker.service

[Service]
ExecStart=/usr/bin/docker run --name cyberchef -p 8081:8080 ghcr.io/gchq/cyberchef:latest
ExecStop=/usr/bin/docker stop cyberchef
Restart=always
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
Restart=always
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
[ "$FULL" -eq 0  ] && sudo udevadm control --reload-rules
[ "$FULL" -eq 0  ] && sudo udevadm trigger
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
Restart=always
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
Restart=always
RestartSec=5
Environment=PYTHONUNBUFFERED=1
Environment=CC_PORT=8082

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable clipcascade-client.service
sudo DEBIAN_FRONTEND=noninteractive apt install libxml2-utils libxslt1.1 -y -o Dpkg::Options::="--force-confnew"
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
sudo DEBIAN_FRONTEND=noninteractive apt install libeigen3-dev libzip-dev zlib1g-dev -y -o Dpkg::Options::="--force-confnew"
sudo DEBIAN_FRONTEND=noninteractive apt install clinfo ocl-icd-opencl-dev -y -o Dpkg::Options::="--force-confnew"
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
sudo DEBIAN_FRONTEND=noninteractive apt install maven -y -o Dpkg::Options::="--force-confnew"
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
sudo DEBIAN_FRONTEND=noninteractive apt install qt6-base-dev qt6-base-dev-tools qt6-svg-dev qt6-5compat-dev -y -o Dpkg::Options::="--force-confnew"
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
sudo DEBIAN_FRONTEND=noninteractive apt install libqt5svg5-dev qt5-qmake qtbase5-dev qtbase5-dev-tools -y -o Dpkg::Options::="--force-confnew"
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
sudo DEBIAN_FRONTEND=noninteractive apt install -f -y -o Dpkg::Options::="--force-confnew"
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y -o Dpkg::Options::="--force-confnew"
sudo DEBIAN_FRONTEND=noninteractive apt autoremove --purge -y -o Dpkg::Options::="--force-confnew"
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
