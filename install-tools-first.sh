#!/bin/bash

cd ~
sudo -v
while true; do sudo -v; sleep 60; done & SUDOPID=$!
sudo sed -i -e 's/^[# ]*HandleLidSwitch=.*/HandleLidSwitch=ignore/' -e 's/^[# ]*HandleLidSwitchDocked=.*/HandleLidSwitchDocked=ignore/' -e 's/^[# ]*HandleLidSwitchExternalPower=.*/HandleLidSwitchExternalPower=ignore/' "/etc/systemd/logind.conf"
sudo grep -q '^HandleLidSwitch=' "/etc/systemd/logind.conf" || echo 'HandleLidSwitch=ignore' | sudo tee -a "/etc/systemd/logind.conf" > /dev/null
sudo grep -q '^HandleLidSwitchDocked=' "/etc/systemd/logind.conf" || echo 'HandleLidSwitchDocked=ignore' | sudo tee -a "/etc/systemd/logind.conf" > /dev/null
sudo grep -q '^HandleLidSwitchExternalPower=' "/etc/systemd/logind.conf" || echo 'HandleLidSwitchExternalPower=ignore' | sudo tee -a "/etc/systemd/logind.conf" > /dev/null
for file in "/etc/grub.d/"*_os_prober "/etc/default/grub.d/"*_os_prober; do
  if [[ -f "$file" ]]; then
    if grep -q '^quick_boot=' "$file"; then
      sed -i 's/^quick_boot=.*/quick_boot="0"/' "$file"
    else
      echo 'quick_boot="0"' >> "$file"
    fi
  fi
done
sudo update-grub
sudo timedatectl set-local-rtc 1
sudo timedatectl set-ntp true
sudo apt update
sudo apt install software-properties-common -y
sudo add-apt-repository universe -y
sudo add-apt-repository multiverse -y
sudo add-apt-repository restricted -y
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
sudo add-apt-repository ppa:libreoffice/ppa -y
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
wget https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/00-env.sh -O ~/.bashrc.d/00-env.sh
wget https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/10-exports.sh -O ~/.bashrc.d/10-exports.sh
wget https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/15-color.sh -O ~/.bashrc.d/15-color.sh
wget https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/20-aliases.sh -O ~/.bashrc.d/20-aliases.sh
wget https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/21-cxx.sh -O ~/.bashrc.d/21-cxx.sh
wget https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/22-java.sh -O ~/.bashrc.d/22-java.sh
wget https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/23-vnc.sh -O ~/.bashrc.d/23-vnc.sh
wget https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/24-launchers.sh -O ~/.bashrc.d/24-launchers.sh
wget https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/50-functions.sh -O ~/.bashrc.d/50-functions.sh
wget https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/60-completion.sh -O ~/.bashrc.d/60-completion.sh
wget https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/bashrc.sh -O ~/.bashrc
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
mkdir -p ~/.local
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/applications
mkdir -p ~/Desktop
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
sudo snap remove firefox 2>/dev/null || true
sudo apt install firefox --allow-downgrades -y
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
sudo snap remove thunderbird 2>/dev/null || true
sudo apt install thunderbird --allow-downgrades -y
echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:$(lsb_release -cs)";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-mozilla
sudo ln -sf /etc/apparmor.d/firefox /etc/apparmor.d/disable/
sudo apparmor_parser -R /etc/apparmor.d/firefox
fi
if grep -q '^NAME="Linux Mint"' /etc/os-release; then
sudo apt install chromium -y
else
sudo add-apt-repository ppa:xtradeb/apps -y
echo 'Package: chromium*
Pin: release o=LP-PPA-xtradeb-apps
Pin-Priority: 1001

Package: chromium*
Pin: release o=Ubuntu
Pin-Priority: -1' | sudo tee /etc/apt/preferences.d/chromium
sudo apt update
sudo apt install chromium chromium-driver chromium-l10n -y
fi
echo y | sudo ubuntu-drivers install || true
echo y | sudo ubuntu-drivers install || true
echo y | sudo ubuntu-drivers install || true
echo y | sudo ubuntu-drivers autoinstall || true
echo y | sudo ubuntu-drivers autoinstall || true
echo y | sudo ubuntu-drivers autoinstall || true
sudo apt upgrade -y
sudo apt install aisleriot alsa-utils apksigner apt-transport-https aptitude aria2 autoconf automake bash bc bear bison build-essential bzip2 ca-certificates clang clang-format cmake command-not-found curl dbus default-jdk dnsutils dvipng dvisvgm fastfetch ffmpeg file flex g++ gcc gdb gfortran gh ghc ghostscript git glab gnuchess gnucobol gnugo gnupg golang gperf gpg grep gtkwave gzip info inkscape iproute2 iverilog iverilog jpegoptim jq libboost-all-dev libbz2-dev libconfig-dev libeigen3-dev libffi-dev libfuse2 libgdbm-compat-dev libgdbm-dev libgsl-dev libheif-examples libllvm19 liblzma-dev libncursesw5-dev libopenblas-dev libosmesa6 libportaudio2 libqt5svg5-dev libreadline-dev libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-net-dev libsdl2-ttf-dev libsqlite3-dev libssl-dev libxml2-dev libxmlsec1-dev libzip-dev libzstd-dev llvm make maven mc nano ncompress neovim ngspice ninja-build openjdk-21-jdk openssh-client openssh-server openssl optipng pandoc perl perl-doc perl-tk pipx plantuml poppler-utils procps pv python3-all-dev python3-pip python3-venv qtbase5-dev qtbase5-dev-tools rust-all sudo tar tk-dev tmux tree unrar unzip uuid-dev uuid-runtime valgrind verilator vim wget wget2 x11-utils x11-xserver-utils xdotool xmlstarlet xz-utils zip zlib1g zlib1g-dev zsh -y
sudo apt install clinfo codeblocks* fcitx5 fcitx5-* flatpak libreoffice ocl-icd-opencl-dev opencl-headers openjdk-8-jdk openjdk-11-jdk openjdk-17-jdk qbittorrent testdisk torbrowser-launcher update-manager-core vim-gtk3 wl-clipboard -y
sudo mkdir -p /usr/share/codeblocks/docs
im-config -n fcitx5
cat > ~/.xprofile <<'EOF'
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export INPUT_METHOD=fcitx
EOF
source ~/.xprofile
if [ "$XDG_CURRENT_DESKTOP" = "KDE" ] || [ "$DESKTOP_SESSION" = "plasma" ] || [ "$KDE_FULL_SESSION" = "true" ]; then
  sudo apt install plasma-discover-backend-flatpak -y
else
  mkdir -p ~/.config/autostart
  cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart/
  fcitx5 &
fi
wget -O sdl2_bgi_3.0.4-1_amd64.deb https://sourceforge.net/projects/sdl-bgi/files/sdl2_bgi_3.0.4-1_amd64.deb/download
sudo apt install ./sdl2_bgi_3.0.4-1_amd64.deb -y
rm sdl2_bgi_3.0.4-1_amd64.deb
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl enable ssh
yes | sudo ufw enable
sudo ufw allow ssh
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
sudo apt update
sudo apt install brave-browser -y
PROFILE=/dev/null bash -c 'curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 24
corepack enable yarn
corepack enable pnpm
npm install jsdom markdown-toc marked marked-gfm-heading-id node-html-markdown showdown
npm install -g http-server @openai/codex
curl -fsSL https://bun.com/install | bash
curl -fsSL https://claude.ai/install.sh | bash
pipx install poetry uv
uv tool install --force --python python3.12 --with pip aider-chat@latest --with playwright
uv tool run playwright install --with-deps chromium
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh -b -p ${HOME}/conda
source .bashrc
conda config --set auto_activate_base false
conda config --add channels bioconda
conda config --add channels pypi
conda config --add channels pytorch
conda config --add channels microsoft
conda config --add channels defaults
conda config --add channels conda-forge
rm Miniforge3-Linux-x86_64.sh
sudo git clone --depth=1 https://github.com/Willie169/vimrc.git /opt/vim_runtime && sudo sh /opt/vim_runtime/install_awesome_parameterized.sh /opt/vim_runtime --all
mkdir -p ~/.config/nvim
echo 'set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
' | tee ~/.config/nvim/init.vim > /dev/null
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/trusted.gpg.d/docker.asc > /dev/null
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce -y
sudo systemctl enable docker
sudo usermod -aG docker $(whoami)
curl -fsSL "https://pkgs.tailscale.com/stable/ubuntu/$UBUNTU_CODENAME.noarmor.gpg" | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL "https://pkgs.tailscale.com/stable/ubuntu/$UBUNTU_CODENAME.tailscale-keyring.list" | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt update
sudo apt install tailscale -y
sudo systemctl enable tailscaled
sudo add-apt-repository ppa:fdroid/fdroidserver -y
sudo apt update
sudo apt install fdroidserver -y
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
echo "Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/microsoft.gpg" | sudo tee /etc/apt/sources.list.d/vscode.sources > /dev/null
sudo apt update
sudo apt install code -y
wget "https://packages.microsoft.com/config/ubuntu/$UBUNTU_VERSION_ID/packages-microsoft-prod.deb" -O packages-microsoft-prod.deb
sudo apt install ./packages-microsoft-prod.deb -y
rm packages-microsoft-prod.deb
sudo apt update
sudo apt install dotnet-sdk-10.0 aspnetcore-runtime-10.0 -y
mkdir ~/.local/godot
wget -O Godot_v4.5.1-stable_mono_linux_x86_64.zip 'https://downloads.godotengine.org/?version=4.5.1&flavor=stable&slug=mono_linux_x86_64.zip&platform=linux.64'
unzip Godot_v4.5.1-stable_mono_linux_x86_64.zip
rm Godot_v4.5.1-stable_mono_linux_x86_64.zip
mv ~/Godot_v4.5.1-stable_mono_linux_x86_64 ~/.local/godot/
ln -s ~/.local/godot/Godot_v4.5.1-stable_mono_linux_x86_64/Godot_v4.5.1-stable_mono_linux.x86_64 ~/.local/bin/godot
wget -O- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | sudo tee /usr/share/keyrings/deb.torproject.org-keyring.gpg >/dev/null
sudo tee /etc/apt/sources.list.d/tor.list > /dev/null <<EOF
deb [arch=amd64 signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org ${UBUNTU_CODENAME} main
deb-src [arch=amd64 signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org ${UBUNTU_CODENAME} main
EOF
sudo apt update
sudo apt install tor deb.torproject.org-keyring -y
sudo wget -O /usr/local/java/antlr-4.13.2-complete.jar https://www.antlr.org/download/antlr-4.13.2-complete.jar
sudo wget -O /usr/local/java/plantuml.jar https://sourceforge.net/projects/plantuml/files/plantuml.jar/download
sudo add-apt-repository ppa:bkryza/clang-uml -y
sudo apt update
sudo apt install clang-uml -y
sudo apt install postgresql-common -y
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y
sudo apt install postgresql-17 -y
sudo add-apt-repository ppa:obsproject/obs-studio -y
sudo apt update
sudo apt install obs-studio -y
curl -fsSL https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt update
sudo apt install spotify-client -y
wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash
wget https://cdn.fastly.steamstatic.com/client/installer/steam.deb
sudo apt install ./steam.deb -y
rm steam.deb
wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2025.2.2.8/android-studio-2025.2.2.8-linux.tar.gz
sudo tar -xzf android-studio-2025.2.2.8-linux.tar.gz -C /opt/
rm android-studio-2025.2.2.8-linux.tar.gz
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
wget https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip
unzip commandlinetools-linux-13114758_latest.zip
rm commandlinetools-linux-13114758_latest.zip
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
echo y | ./sdkmanager "build-tools;30.0.3" "build-tools;35.0.0" "build-tools;36.1.0" "emulator" "ndk;29.0.14206865" "platform-tools" "platforms;android-33" "platforms;android-36" "sources;android-33" "sources;android-36"
echo y | ./sdkmanager "system-images;android-33;google_apis_playstore;x86_64"
echo y | ./sdkmanager "system-images;android-36.1;google_apis_playstore;x86_64"
cd ~
sudo rm /bin/sdkmanager 2>/dev/null || true
gh_latest -A ente-io/ente -t auth* ente-auth-v*-x86_64.deb
sudo apt install ./ente-auth-v*-x86_64.deb -y
rm ente-auth-v*-x86_64.deb
wget -O discord.deb 'https://discord.com/api/download?platform=linux&format=deb'
sudo apt install ./discord.deb
rm discord.deb
wget https://proton.me/download/mail/linux/1.11.0/ProtonMail-desktop-beta.deb
sudo apt install ./ProtonMail-desktop-beta.deb -y
rm ProtonMail-desktop-beta.deb
wget https://proton.me/download/bridge/protonmail-bridge_3.21.2-1_amd64.deb
sudo apt install ./protonmail-bridge_3.21.2-1_amd64.deb -y
rm protonmail-bridge_3.21.2-1_amd64.deb
wget http://archive.ubuntu.com/ubuntu/pool/universe/g/gdk-pixbuf-xlib/libgdk-pixbuf2.0-0_2.40.2-3build2_amd64.deb
sudo apt install ./libgdk-pixbuf2.0-0_2.40.2-3build2_amd64.deb -y
rm libgdk-pixbuf2.0-0_2.40.2-3build2_amd64.deb
gh_latest -A balena-io/etcher balena-etcher_*_amd64.deb
sudo apt install ./balena-etcher_*_amd64.deb -y
rm balena-etcher_*_amd64.deb
gh_latest -A arduino/arduino-cli arduino-cli_*_amd64.deb
sudo apt install ./arduino-cli_*_amd64.deb -y
rm arduino-cli_*_amd64.deb
mkdir ~/.local/arduino-ide
gh_latest -A -C arduino/arduino-ide arduino-ide_*_Linux_64bit.zip
unzip arduino-ide_*_Linux_64bit.zip
rm arduino-ide_*_Linux_64bit.zip
mv ~/arduino-ide_*_Linux_64bit ~/.local/arduino-ide/
cat > ~/.local/bin/arduino-ide <<'EOF'
#!/bin/bash
~/.local/arduino-ide/arduino-ide_*_Linux_64bit/arduino-ide --no-sandbox "$@"
EOF
chmod +x ~/.local/bin/arduino-ide
echo 'SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", GROUP="plugdev", MODE="0666"' | sudo tee /etc/udev/rules.d/99-arduino.rules >/dev/null
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
wget https://media.katagotraining.org/uploaded/networks/models/kata1/kata1-b6c96-s175395328-d26788732.txt.gz
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
wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz --no-check-certificate
tar -xzf install-tl-unx.tar.gz
rm install-tl-unx.tar.gz
cd install-tl-*
sudo perl install-tl --no-interaction
cd ~
rm -rf install-tl-*
sudo /usr/local/texlive/2025/bin/x86_64-linux/tlmgr update --all --self --reinstall-forcibly-removed
mkdir -p ~/.config/fontconfig/conf.d
cat > ~/.config/fontconfig/conf.d/99-texlive.conf <<'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <dir>/usr/local/texlive/2025/texmf-dist/fonts</dir>
</fontconfig>
EOF
sudo mkdir -p /usr/share/fonts/opentype/xits
cd /usr/share/fonts/opentype/xits
sudo wget https://github.com/aliftype/xits/releases/download/v1.302/XITS-1.302.zip
sudo unzip XITS-1.302.zip
cd XITS-1.302
sudo mv *.otf ..
cd ..
sudo rm -rf XITS-1.302*
sudo mkdir -p /usr/share/fonts/noto-cjk
cd /usr/share/fonts/noto-cjk
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/TC/NotoSansTC-Thin.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/TC/NotoSansTC-Regular.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/TC/NotoSansTC-Medium.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/TC/NotoSansTC-Light.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/TC/NotoSansTC-DemiLight.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/TC/NotoSansTC-Bold.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/TC/NotoSansTC-Black.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/SC/NotoSansSC-Thin.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/SC/NotoSansSC-Regular.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/SC/NotoSansSC-Medium.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/SC/NotoSansSC-Light.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/SC/NotoSansSC-DemiLight.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/SC/NotoSansSC-Bold.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/SC/NotoSansSC-Black.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/HK/NotoSansHK-Thin.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/HK/NotoSansHK-Regular.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/HK/NotoSansHK-Medium.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/HK/NotoSansHK-Light.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/HK/NotoSansHK-DemiLight.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/HK/NotoSansHK-Bold.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/HK/NotoSansHK-Black.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/JP/NotoSansJP-Thin.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/JP/NotoSansJP-Regular.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/JP/NotoSansJP-Medium.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/JP/NotoSansJP-Light.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/JP/NotoSansJP-DemiLight.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/JP/NotoSansJP-Bold.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/JP/NotoSansJP-Black.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/KR/NotoSansKR-Thin.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/KR/NotoSansKR-Regular.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/KR/NotoSansKR-Medium.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/KR/NotoSansKR-Light.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/KR/NotoSansKR-DemiLight.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/KR/NotoSansKR-Bold.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/KR/NotoSansKR-Black.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/TC/NotoSerifTC-ExtraLight.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/TC/NotoSerifTC-Regular.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/TC/NotoSerifTC-Medium.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/TC/NotoSerifTC-Light.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/TC/NotoSerifTC-SemiBold.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/TC/NotoSerifTC-Bold.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/TC/NotoSerifTC-Black.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/SC/NotoSerifSC-ExtraLight.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/SC/NotoSerifSC-Regular.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/SC/NotoSerifSC-Medium.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/SC/NotoSerifSC-Light.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/SC/NotoSerifSC-SemiBold.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/SC/NotoSerifSC-Bold.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/SC/NotoSerifSC-Black.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/HK/NotoSerifHK-ExtraLight.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/HK/NotoSerifHK-Regular.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/HK/NotoSerifHK-Medium.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/HK/NotoSerifHK-Light.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/HK/NotoSerifHK-SemiBold.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/HK/NotoSerifHK-Bold.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/HK/NotoSerifHK-Black.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/JP/NotoSerifJP-ExtraLight.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/JP/NotoSerifJP-Regular.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/JP/NotoSerifJP-Medium.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/JP/NotoSerifJP-Light.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/JP/NotoSerifJP-SemiBold.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/JP/NotoSerifJP-Bold.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/JP/NotoSerifJP-Black.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/KR/NotoSerifKR-ExtraLight.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/KR/NotoSerifKR-Regular.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/KR/NotoSerifKR-Medium.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/KR/NotoSerifKR-Light.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/KR/NotoSerifKR-SemiBold.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/KR/NotoSerifKR-Bold.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/KR/NotoSerifKR-Black.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Mono/NotoSansMonoCJKtc-Regular.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Mono/NotoSansMonoCJKtc-Bold.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Mono/NotoSansMonoCJKsc-Regular.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Mono/NotoSansMonoCJKsc-Bold.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Mono/NotoSansMonoCJKhk-Regular.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Mono/NotoSansMonoCJKhk-Bold.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Mono/NotoSansMonoCJKjp-Regular.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Mono/NotoSansMonoCJKjp-Bold.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Mono/NotoSansMonoCJKkr-Regular.otf
sudo wget https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Mono/NotoSansMonoCJKkr-Bold.otf
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
cd ~
sudo apt update
sudo apt install -f -y
sudo apt upgrade -y
sudo apt autoremove --purge -y
sudo apt clean
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
kill "$SUDOPID"
sudo reboot
