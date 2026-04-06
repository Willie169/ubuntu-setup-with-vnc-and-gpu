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
sudo tee /etc/systemd/resolved.conf >/dev/null <<'EOF'
[Resolve]
DNS=1.1.1.1 1.0.0.1
FallbackDNS=2606:4700:4700::1111 2606:4700:4700::1001 94.140.14.140 94.140.14.141 2a10:50c0::1:ff 2a10:50c0::2:ff
EOF
sudo systemctl restart systemd-resolved
sudo apt update
sudo apt install software-properties-common -y </dev/null
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
sudo add-apt-repository ppa:xtradeb/apps -y
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
bash <<'EOF'
set -e
f=/etc/apt/sources.list.d/ubuntu.sources
if [ -f "$f" ] && grep -q "^Types:.*deb" "$f"; then
  sudo sed -i 's/^Types: *deb.*/Types: deb deb-src/' "$f"
fi
EOF
sudo apt update
sudo apt purge fcitx* texlive* -y </dev/null
sudo apt install wget -y </dev/null
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
sudo apt install firefox --allow-downgrades -y </dev/null
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
sudo apt install thunderbird --allow-downgrades -y </dev/null
sudo rm /var/lib/snapd/desktop/applications/thunderbird*.desktop 2>/dev/null || true
echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:$(lsb_release -cs)";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-mozilla
echo 'Package: chromium*
Pin: release o=LP-PPA-xtradeb-apps
Pin-Priority: 1001

Package: chromium*
Pin: release o=Ubuntu
Pin-Priority: -1' | sudo tee /etc/apt/preferences.d/chromium
fi
echo y | sudo ubuntu-drivers install || true
echo y | sudo ubuntu-drivers install || true
echo y | sudo ubuntu-drivers install || true
echo y | sudo ubuntu-drivers autoinstall || true
echo y | sudo ubuntu-drivers autoinstall || true
echo y | sudo ubuntu-drivers autoinstall || true
sudo apt upgrade -y </dev/null
sudo apt install abcde aisleriot alien alsa-utils apksigner apt-transport-https aptitude audacity autoconf automake bash bc bear bison bookletimposer build-essential bzip2 caneda ca-certificates clang clangd clang-format cmake command-not-found curl dbus debian-archive-keyring debian-keyring default-jdk dmg2img dnsutils dvisvgm fastfetch ffmpeg file flex fonts-cns11643-kai fonts-cns11643-sung fonts-liberation fonts-noto-cjk fonts-noto-cjk-extra g++ gcc gdb gfortran gh ghc ghostscript git glab gnupg golang-go gopls gperf gpg grep gtkwave gzip info imagemagick inkscape iproute2 iverilog jpegoptim jq libboost-all-dev libbz2-dev libconfig-dev libeigen3-dev libffi-dev libfuse2 libgdbm-compat-dev libgdbm-dev libgsl-dev libguestfs-tools libheif-examples libhwloc-dev libhwloc-plugins libllvm19 liblzma-dev libncursesw5-dev libopenblas-dev libosmesa6 libportaudio2 libqt5svg5-dev libreadline-dev libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-net-dev libsdl2-ttf-dev libsqlite3-dev libssl-dev libuv1t64 libuv1-dev libxml2-dev libxmlsec1-dev libzip-dev libzstd-dev llvm make maven mc nano ncompress neovim netcat-openbsd ngspice ninja-build nmap octave openjdk-21-jdk openssh-client openssh-server openssl optipng pandoc perl perl-doc perl-tk pipx plantuml poppler-utils procps pv python-is-python3 python3-all-dev python3-httpx python3-jinja2 python3-neovim python3-requests python3-pip python3-venv qpdf qtbase5-dev qtbase5-dev-tools rust-all socat sqlite3 sudo tar tk-dev tmux tree ttf-mscorefonts-installer unzip uuid-dev uuid-runtime valgrind verilator vim webp wget wget2 x11-utils x11-xserver-utils xdotool xmlstarlet xz-utils zip zlib1g zlib1g-dev zsh zstd -y </dev/null
sudo apt install apparmor-utils aria2 bridge-utils clang-uml clinfo codeblocks* fcitx5 fcitx5-* fdroidserver flatpak gnome-keyring kate libreoffice libtesseract-dev libvirt-daemon-system libvirt-clients msr-tools obs-studio ocl-icd-opencl-dev opencl-headers openjdk-8-jdk openjdk-17-jdk ovmf podman qbittorrent qemu-kvm qemu-system qemu-user-static qtspeech5-speechd-plugin quickemu quickgui snapd spice-vdagent swtpm swtpm-tools tesseract-ocr-all testdisk torbrowser-launcher uidmap update-manager-core vim-gtk3 virt-manager virt-viewer wl-clipboard -y </dev/null
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
  sudo apt install plasma-discover-backend-flatpak -y </dev/null
else
  mkdir -p ~/.config/autostart
  cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart/
  fcitx5 &
fi
wget --tries=100 --retry-connrefused --waitretry=5 -O sdl2_bgi_3.0.4-1_amd64.deb https://sourceforge.net/projects/sdl-bgi/files/sdl2_bgi_3.0.4-1_amd64.deb/download
sudo apt install ./sdl2_bgi_3.0.4-1_amd64.deb -y </dev/null
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
sudo apt install brave-browser -y </dev/null
wget -qO - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo tee /etc/apt/keyrings/google.asc >/dev/null
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google.asc] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list'
sudo apt update
sudo apt install google-chrome-stable -y </dev/null
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
corepack enable yarn
corepack enable pnpm
npm install jsdom markdown-toc marked marked-gfm-heading-id node-html-markdown showdown
npm install -g bash-language-server dockerfile-language-server-nodejs http-server pyright tree-sitter-cli @google/gemini-cli @openai/codex
curl --retry 100 --retry-connrefused --retry-delay 5 -fsSL https://bun.com/install | bash
pipx install cmake-language-server libretranslate notebook jupyterlab jupytext meson poetry pylatexenc uv
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
systemctl --user enable open-webui
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
systemctl --user enable cyberchef
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
sudo apt install docker-ce docker-ce-rootless-extras -y </dev/null
dockerd-rootless-setuptool.sh install
curl --retry 100 --retry-connrefused --retry-delay 5 -fsSL "https://pkgs.tailscale.com/stable/ubuntu/$UBUNTU_CODENAME.noarmor.gpg" | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl --retry 100 --retry-connrefused --retry-delay 5 -fsSL "https://pkgs.tailscale.com/stable/ubuntu/$UBUNTU_CODENAME.tailscale-keyring.list" | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt update
sudo apt install tailscale -y </dev/null
sudo systemctl daemon-reload
sudo systemctl enable tailscaled
curl --retry 100 --retry-connrefused --retry-delay 5 -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
echo "Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/microsoft.gpg" | sudo tee /etc/apt/sources.list.d/vscode.sources > /dev/null
sudo apt update
sudo apt install code -y </dev/null
wget --tries=100 --retry-connrefused --waitretry=5 "https://packages.microsoft.com/config/ubuntu/$UBUNTU_VERSION_ID/packages-microsoft-prod.deb" -O packages-microsoft-prod.deb
sudo apt install ./packages-microsoft-prod.deb -y </dev/null
rm packages-microsoft-prod.deb
sudo apt update
sudo apt install dotnet-sdk-10.0 aspnetcore-runtime-10.0 -y </dev/null
wget --tries=100 --retry-connrefused --waitretry=5 -O- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | sudo tee /usr/share/keyrings/deb.torproject.org-keyring.gpg >/dev/null
sudo tee /etc/apt/sources.list.d/tor.list > /dev/null <<EOF
deb [arch=amd64 signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org ${UBUNTU_CODENAME} main
deb-src [arch=amd64 signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org ${UBUNTU_CODENAME} main
EOF
sudo apt update
sudo apt install tor deb.torproject.org-keyring -y </dev/null
sudo wget -O /usr/local/java/antlr-4.13.2-complete.jar https://www.antlr.org/download/antlr-4.13.2-complete.jar
sudo wget -O /usr/local/java/plantuml.jar https://sourceforge.net/projects/plantuml/files/plantuml.jar/download
sudo apt install postgresql-common -y </dev/null
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y
sudo apt install postgresql-17 -y </dev/null
sudo mkdir -p /var/log/postgresql
sudo chown -R postgres:postgres /var/log/postgresql
sudo chmod 755 /var/log/postgresql
sudo chmod 640 /var/log/postgresql/* 2>/dev/null || true
wget --tries=100 --retry-connrefused --waitretry=5 https://cdn.fastly.steamstatic.com/client/installer/steam.deb
sudo apt install ./steam.deb -y </dev/null
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
sudo apt install element-desktop -y </dev/null
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
wget --tries=100 --retry-connrefused --waitretry=5 -O discord.deb 'https://discord.com/api/download?platform=linux&format=deb'
sudo apt install ./discord.deb </dev/null
rm discord.deb
wget --tries=100 --retry-connrefused --waitretry=5 https://proton.me/download/mail/linux/1.12.1/ProtonMail-desktop-beta.deb
sudo apt install ./ProtonMail-desktop-beta.deb -y </dev/null
rm ProtonMail-desktop-beta.deb
wget --tries=100 --retry-connrefused --waitretry=5 https://proton.me/download/bridge/protonmail-bridge_3.21.2-1_amd64.deb
sudo apt install ./protonmail-bridge_*_amd64.deb -y </dev/null
rm protonmail-bridge_*_amd64.deb
wget --tries=100 --retry-connrefused --waitretry=5 http://archive.ubuntu.com/ubuntu/pool/universe/g/gdk-pixbuf-xlib/libgdk-pixbuf2.0-0_2.40.2-3build2_amd64.deb
sudo apt install ./libgdk-pixbuf2.0-0_2.40.2-3build2_amd64.deb -y </dev/null
rm libgdk-pixbuf2.0-0_2.40.2-3build2_amd64.deb
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' balena-io/etcher balena-etcher_*_amd64.deb
sudo apt install ./balena-etcher_*_amd64.deb -y </dev/null
rm balena-etcher_*_amd64.deb
gh_latest -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' arduino/arduino-cli arduino-cli_*_amd64.deb
sudo apt install ./arduino-cli_*_amd64.deb -y </dev/null
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
docker compose stop
cd ~
curl --retry 100 --retry-connrefused --retry-delay 5 -fsSL https://opencode.ai/install | bash
curl --retry 100 --retry-connrefused --retry-delay 5 -fsSL https://claude.ai/install.sh | bash
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
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo chmod o+r /usr/share/keyrings/caddy-stable-archive-keyring.gpg
sudo chmod o+r /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy -y </dev/null
gh_latest matrix-construct/tuwunel *-release-all-x86_64-$(cat /proc/cpuinfo | grep -Po '(avx|sse)[235]' | sort -u | sed 's/avx5/v4/;s/avx2/v3/;s/sse3/v2/;s/sse2/v1/' | sort | tail -1)-linux-gnu-tuwunel.deb
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
sudo apt install -f -y </dev/null
sudo apt upgrade -y </dev/null
sudo apt autoremove --purge -y </dev/null
sudo apt clean
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
kill "$SUDOPID"
sudo reboot
