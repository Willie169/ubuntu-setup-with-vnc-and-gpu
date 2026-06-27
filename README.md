# ubuntu-setup-with-vnc-and-gpu

Scripts and instructions for setting up Ubuntu derivatives on AMD64 with tools for development, productivity, graphics, remote control, multimedia, communication, and more.

## Main Installation Scripts

### Prerequisites

* Sufficient storage: (calculated using GitHub Action, typically a bit more on a real device)
  * [`install-tools-first.sh`](install-tools-first.sh): approximately 30.74 GB.
  * [`install-tools-second.sh`](install-tools-second.sh): approximately 11.26 GB.
* Sufficient power supply.
* Stable internet connection.
* In power management settings, disable suspension when inactive.
* Ubuntu >= 24.04 or their derivative.

### USB Flashing and Dual Boot

Refer to my [**dual-boot-windows-linux-and-recovery**](https://github.com/Willie169/dual-boot-windows-linux-and-recovery) repo.

### WPA PEAP TLS Network

If you fail to connect to a WPA PEAP Network that you are supposed to be able to connect to, it may be due to deprecated TLS protocols and can be fixed by according to my [**WPA-PEAP-TLS-network-Linux**](https://github.com/Willie169/WPA-PEAP-TLS-network-Linux) repo.

### Btrfs

If you are using Btrfs, you may want to set it up first. Refer to my [**btrfs-debian-ubuntu**](https://github.com/Willie169/btrfs-debian-ubuntu) repo.

### SSH

SSH provides a secure way for accessing remote hosts and replaces tools such as telnet, rlogin, rsh, ftp. OpenSSH, also known as OpenBSD Secure Shell, is a suite of secure networking utilities based on the Secure Shell (SSH) protocol, which provides a secure channel over an unsecured network in a client–server architecture.

To install and enable SSH server on your computer, run:
```
sudo apt update
sudo apt install openssh-server -y
sudo systemctl enable --now ssh
```
If UFW is enabled, allow SSH:
```
sudo ufw allow ssh
```
Check IP by running:
```
sudo apt install net-tools -y
ifconfig
```
Password authentication is typically allowed by default. If not and you haven't setup public key authentication, run
```
sudo sed -Ei 's/^#?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd
```
For better security, using public key authentication is recommended. First generate a key pair in client and optionally set a passphrase. Press Enter to accept default path `~/.ssh/id_ed25519`. `~/.ssh/id_ed25519` is your private key. Keep it secure. Skip if you already has one.
```
ssh-keygen -t ed25519 -a 100
```
And then, copy the public key to the server. Replace `user@server` with your actual server.
```
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@server
```
Test whether it works.
```
ssh -i ~/.ssh/id_ed25519 user@server
```
If it works, you can disable password authentication on server by running
```
sudo sed -Ei 's/^#?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd
```
If your SSH connection is unstable. You may try adding keepalive packets sending on client by running:
```
cat >> ~/.ssh/config <<EOF
Host *
    ServerAliveInterval 15
    ServerAliveCountMax 8
EOF
```
and reconnect.

You can use Android as SSH client. [**Termux**](https://f-droid.org/packages/com.termux) is suggested if you do not have a client of your choice. See my [**Android-Non-Root**](https://github.com/Willie169/Android-Non-Root) and [**termux-ssh**](https://github.com/Willie169/termux-sh) repos for more information.

You can adjust more SSH server config by editing `/etc/ssh/sshd_config`:
```
sudo vim /etc/ssh/sshd_config
```
Some configs include:

<ul>
<li>SSH Port:<pre><code>#Port 22
</code></pre>default to port <code>22</code>.</li>
<li>Ports Listening to<pre><code>#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::
</code></pre></li>
<li>Password authentication:<pre><code>#PasswordAuthentication yes
</code></pre></li>
<li>Public key authentication:<pre><code>#PubkeyAuthentication yes
</code></pre></li>
</ul>

### Usage

Note that the computer will reboot multiple times duing the process, so do not do other things on it while running these scripts.

<ol>
<li>Clone the repository:
<pre><code>cd ~
sudo apt update
sudo apt install git -y
git clone https://github.com/Willie169/ubuntu-setup-with-vnc-and-gpu.git
</code></pre></li>
<li>If you are using an NVIDIA GPU, run:
<pre><code>cd ~/ubuntu-setup-with-vnc-and-gpu
./nvidia.sh
</code></pre></li>
<li>Run:
<pre><code>cd ~/ubuntu-setup-with-vnc-and-gpu
./install-drivers.sh
</code></pre>
and wait for the computer to reboot automatically.</li>
<li>Run:
<pre><code>cd ~/ubuntu-setup-with-vnc-and-gpu
./install-tools-first.sh
</code></pre>
and follow the prompts until the computer reboots automatically.</li>
<li>Run:
<pre><code>cd ~/ubuntu-setup-with-vnc-and-gpu
./install-tools-second.sh
</code></pre>
and wait for the shell to exit automatically. It may prompt you to choose password for a new keying called "Default keyring". Set a password for it. It will also be used in other apps with <code>gnome-keyring</code> such as Ente Auth.</li></li>
<li>Remove the repository:
<pre><code>rm -r ~/ubuntu-setup-with-vnc-and-gpu
</code></pre></li>
</ol>

### Stuff You May Want to Do Afterwards

<ol>
<li>Set JetBrainsMono Nerd Font as your system mono/fixed-width font or terminal emulator default font for displaying icons in Yazi.</li>
<li>Go to <a href="http://localhost:8082">http://localhost:8082</a>, enter default user name <code>admin</code> and password <code>admin123</code>, change user name and password, and login in the pop-up window of ClipCascade client.</li>
<li>Snap Firefox and Thunderbird are replaced with Deb Firefox and Thunderbird from Mozilla Team PPA, and thus you may want to re-configure launchers in your Desktop Environment.</li>
<li>Run
<pre><code>sudo tailscale up
</code></pre>
to login to Tailscale via the URL shown and click <strong>Connect</strong>. Google, Microsoft, GitHub, Apple, and passkey are available.</li>
<li>Run <code>element-desktop --password-store="gnome-libsecret"</code>. It may prompt you to choose password for a new keying called "Default keyring". Set a password for it. It will also be used in other apps with <code>gnome-keyring</code> such as Ente Auth. And then you can login to your Matrix account.</li>
<li>Launch Ente Auth by running <code>enteauth</code> or with desktop entry. Type password of "Default keyring" of <code>gnome-keyring</code> if prompted. And then you can login to your Ente account.</li>
<li>Run
<pre><code>gh auth login --scopes repo,read:org,admin:org,workflow,gist,notifications,delete_repo,write:packages,read:packages
</code></pre>
to login to GitHub and optionally run
<pre><code>gh config set git_protocol ssh
git config --global url."git@github.com:".insteadOf "https://github.com/"
</code></pre> if you want to use ssh instead of https.</li>
<li>Config git with <code>git config --global user.name [your_name] &amp;&amp; git config --global user.email [your_email]</code>, <code>git config --global pull.rebase true</code> etc.</li>
<li>Run <code>flatpak run com.mikeasoft.pied</code> to setup Pied.</li>
<li>Setup RustDesk. To use it with Tailscale, click three dots besides ID to enter <code>Settings</code>, click <code>Security</code>, click <code>Unlock security settings</code>, enter your password, and check <code>Enable direct IP access</code>. To use self-hosted server, click three dots besides ID to enter <code>Settings</code>, click <code>Network</code>, click <code>Unlock security settings</code>, enter your password, in ID server, enter the IP of the RustDesk ID/Rendezvous server, which is <code>localhost</code> as installed here, in relay server, enter the IP of the RustDesk relay server, which is <code>localhost</code> as installed here, and in Key, paste the content of <code>/var/lib/rustdesk-server/id_ed25519.pub</code> in the RustDesk ID/Rendezvous server. To use Android RustDesk app with Tailscale, go to <code>Settings</code> and toggle on <code>Direct IP access</code>. To use self-hosted server in Android RustDesk app, go to <code>Settings > ID/Relay server</code>, in ID server, enter the IP of the RustDesk ID/Rendezvous server, in relay server, enter the IP of the RustDesk relay server, and in Key, paste the content of <code>/var/lib/rustdesk-server/id_ed25519.pub</code> in the RustDesk ID/Rendezvous server. Sometimes it fails to connect to computer from Android while it succeeds to connect to Android from computer, you may use VNC instead for the former.</li>
<li>Run <code>code</code> or click the <strong>VSCodium</strong> icon to setup VSCodium.</li>
<li>Run <code>torbrowser-launcher</code> or click the <strong>Tor Browser</strong> icon to finish installing Tor Browser.</li>
<li>Go to <a href="#other-scripts">Other Scripts</a> section for other scripts in this repository.</li>
<li>Go to <a href="#instructions">Instructions</a> section for instructions.</li>
</ol>

### Content of Main Installation Scripts

Configures dual-boot friendly configurations, enables automatic login if on GDM, LightDM, KDE Plasma, or LXQt, enables Wayland if on GDM or KDE Plasma, disables KDE Wallet if installed, installs recommended drivers and tools for C, C++, Python3, Java21, Node.js LTS (via NVM), Rust, Perl, Aptitude, GitHub CLI, GitLab CLI, Kate, GVim, OpenSSL, OpenSSH, Tailscale, GNOME Keyring, jq, mikefarah's yq, FFMPEG, Fcitx5, 
Snap, Flatpak (all Flatpak apps are defined with CLI aliases to be able to be run like native apps), QEMU full system emulation (x86), QEMU user mode emulation, Quickemu, UFW, TeX Live (via regular installation instead of APT for unrestricted `tlmgr` and updates, can be updated with `update_texlive`), Pandoc, NTFS-3G, Maven, Zsh, iproute2, net-tools, Nmap, aria2, nvm, npm, Yarn, Deno, http-server, LintHTML, OpenCode, Codex, yt-dlp, Lazygit, DNSCrypt-Proxy, Homebrew, Filelight, Glow, bat, fd, ncdu, dust, fzf, Delta, Tennis, ripgrep (rg), Yazi, zoxide, Miniforge, pipx, uv, procs, tldr, xmljson, JADX, Apktool, broot, bottom (btm), hyperfine, lsd, Dangerzone, 
lftp, LibreTranslate, gh2md, img2pdf, English, Chinese - Simplified, Chinese - Simplified (vertical), Chinese - Traditional, and Chinese - Traditional (vertical) Tesseract OCR, OCRmyPDF, Jupyter Notebook, JupyterLab, Jupytext, Meson, Tree-sitter CLI, pylatexenc, lazy.nvim and Neovim plugins from my [**bashrc**](https://github.com/Willie169/bashrc) repo (can be updated by running `update_nvim`), LSP servers, RARLAB UnRAR, Verilator, Ngspice, jpegoptim, optipng, libheif, LibWebP, ImageMagick, Inkscape, 
Poppler, qpdf, PDFtk, Ghostscript, Bookletimposer, Tesseract with English, Chinese - Simplified, Chinese - Simplified (vertical), Chinese - Traditional, Chinese - Traditional (vertical), Japanese, and Japanese (vertical), OCRmyPDF, Audacity, w3m, XMLStarlet, GTKWave, rclone-extra, Docker Rootless mode, Podman, LXC (Linux Container), Distrobox, CyberChef (server enabled with `systemctl --user enable --now cyberchef` on `http://localhost:8081`), Stirling PDF (in `~/stirlingpdf`, server enabled with `systemctl --user enable --now stirlingpdf` on `http://localhost:9000`, can be started by running `stirlingpdf-up`, stopped by running `stirlingpdf-stop`, and downed by running `stirlingpdf-down`), Element Desktop (can be started with `element-desktop --password-store="gnome-libsecret"` at the first time, and then you can use `element-desktop` or desktop entry to launch it), Tokodon, Newsflash, JamesDSP, Octave, VSCodium, qBittorrent, Remmina, ANTLR 4 (JAR in `/usr/local/java`), Tor, Tor Browser, PlantUML (JAR in `/usr/local/java`), clang-uml, SQLite 3, mpv, iotop-c, netcat, NetHogs, net-tools, iftop, LocalSend, RustDesk ID/Rendezvous server, RustDesk relay server, RustDesk, 
Android SDK Command-line tools and platform-tools, fdroidserver, gallery-dl, Brave Browser, Bottles, Ente Auth, OBS Studio, HandBrake, FreeTube, GIMP, Luanti, vokoscreenNG, Telegram, Pied (run `flatpak run com.mikeasoft.pied` to setup it), FreeCAD, Kdenlive, ClipCascade (server enabled with `systemctl --user enable --now clipcascade-server` on 
`http://localhost:8082`, client enabled with `systemctl --user enable --now clipcascade-client`), Phice (can be started by running `cd ~/phice && uv run gunicorn -b 127.0.0.1:<port> -w 4 "app:app"`, or `phice [port]`, where if port is not specified, `5001` is used, and accessed on `localhost:<port>`), scrcpy, Krita, MuseScore, OnlyOffice, VLC, 
KataGo (`~/KataGo/cpp/katago` and can be run with `katago`) and KataGo network `kata1-b6c96-s175395328-d26788732` (in `~/katago-networks`, other networks can be downloaded from <https://katagotraining.org/networks>), LizzieYzy (can be launched by running `lizzieyzy` or with desktop entry `~/.local/share/applications/lizzieyzy.desktop`, runtime directory `~/.lizzieyzy`, KataGo network `kata1-b6c96-s175395328-d26788732` configured as default engine and estimate engine in `~/.lizzieyzy/config.txt`, which can be updated by running `update_lizzieyzy_config`), 
Fairy-Stockfish (`~/Fairy-Stockfish/src/stockfish` and can be run with `stockfish`), Cute Chess (GUI at `~/cutechess/build/cutechess` and can be launched by running `cutechess` or with desktop entry `~/.local/share/applications/cutechess.desktop`, CLI at `~/cutechess/build/cutechess-cli` and can be run with `cutechess-cli`, Fairy-Stockfish configured as engine in `~/.config/cutechess/engines.json`, which can be updated by running `update_cutechess_config`), 
Sylvan (GUI at `~/Sylvan/projects/gui/sylvan` and can be launched by running `sylvan` or with desktop entry `~/.local/share/applications/sylvan.desktop`, CLI at `~/Sylvan/projects/cli/sylvan-cli` and can be run with `sylvan-cli`, Fairy-Stockfish configured as engine in `~/.config/EterCyber/engines.json`, which can be updated by running `update_sylvan_config`), 
Noto Fonts (set as default font for system ui), Noto CJK Fonts (set as fallback font for system ui), Noto Color Emoji (set as fallback font for system ui), 全字庫正楷體 TW-Kai (set as fallback font for 標楷體 DFKai-SB), 全字庫正宋體 TW-Sung (set as fallback font for 細明體 MingLiu and 新細明體 PMingLiu), 文泉驛正黑 WenQuanYi Zen Hei (set as fallback font for 微軟正黑體 Microsoft JhengHei), JetBrainsMono Nerd Font (downloaded in `~/.local/share/fonts`), [my modified version](https://github.com/Willie169/vimrc) of [vimrc by Amir Salihefendic (amix)](https://github.com/amix/vimrc) for both Vim and Neovim (can be updated by running `update_vimrc`), my LaTeX package [`physics-patch`](https://github.com/Willie169/physics-patch) (in `~/texmf/tex/latex/physics-patch`, checked out `dev` branch, and can be updated with `update_latex`), my LaTeX template [`LaTeX-ToolKit`](https://github.com/Willie169/LaTeX-ToolKit) (in `/usr/share/LaTeX-ToolKit/template.tex` and can be updated with `update_latex`), 
switches from Snap Firefox and Thunderbird to Deb Firefox and Thunderbird from Mozilla Team PPA, adds XtraDeb PPA, where you can install Deb Chromium from by running `sudo apt install chromium -y`, prevents Snap Chromium from being installed, and disables Ubuntu Pro-related MOTD messages and APT hook if not on Linux Mint, using scripts from my [switch-firefox-from-snap-to-deb](https://github.com/Willie169/switch-firefox-from-snap-to-deb), enables unattended upgrades for all origins, downloads EFF Large Wordlist for Passphrases in `~/.eff_large_wordlist.txt`, copies `~/.bashrc.d` and `~/.bashrc` from my [**bashrc**](https://github.com/Willie169/bashrc) repo (can be updated by running `update_bashrc`, tools installed by this script that is not managed by a package manager can be updated by running `update_tools`, tools installed by this script and package managers can be updated by running `update_all`), and more.

## Other Scripts

### [`clamav-install.sh`](clamav-install.sh) and [`clamscan.sh`](clamscan.sh)

[`clamav-install.sh`](clamav-install.sh) installs ClamAV on Debian derivatives.

[`clamscan.sh`](clamscan.sh) scans the following directories recursively with ClamAV:
```
/home /etc /var /usr/share /usr/local /opt /tmp
```

### [`cuda.sh`](cuda.sh)

Installs NVIDIA drivers and CUDA Toolkit on Ubuntu derivatives with Nvidia GPU and reboot.

Restart your computer after running the script and then test with:
```
nvidia-smi
nvcc --version
```

### [`kicad.sh`](kicad.sh)

Installs KiCad and creates desktop entry `~/.local/share/applications/kicad.desktop` for it.

### [`steam.sh`](steam.sh)

Installs [Steam](https://store.steampowered.com).

### [`virtualgl-turbovnc.sh`](virtualgl-turbovnc.sh)

Installs VirtualGL, TurboVNC, and XFCE desktop environment on Debian derivatives on AMD 64, configure TurboVNC to start XFCE desktop environment by default, and reboot. It is compatible with most GPU. You may want to use TigerVNC instead if your computer does not have a GPU. See [VirtualGL and TurboVNC](#virtualgl-and-turbovnc) section for more information.

### [`waydroid.sh`](waydroid.sh)

Installs Waydroid on Debian derivatives on AMD 64. See [Waydroid](#waydroid) section for it does and what to do after running this script and more information.

### [`winrar.sh`](winrar.sh)

Installs [WinRAR](https://www.win-rar.com).

### [`xmrig-install.sh`](xmrig-install.sh), [`xmrig-xmr.sh`](xmrig-xmr.sh), and [`xmrig-rvn.sh`](xmrig-rvn.sh)

- [`xmrig-install.sh`](xmrig-install.sh): Builds my modified version of [XMRig](https://github.com/Willie169/xmrig), an open source, cross-platform RandomX, KawPow, CryptoNight and GhostRider CPU/GPU miner, RandomX benchmark, and stratum proxy.
- [`xmrig-xmr.sh`](xmrig-xmr.sh): Mines XMR to [the repository owner](https://github.com/Willie169)'s wallet, `48j6iQDeCSDeH46gw4dPJnMsa6TQzPa6WJaYbBS9JJucKqg9Mkt5EDe9nSkES3b8u7V6XJfL8neAPAtbEpmV2f4XC7bdbkv`, using my modified version of [XMRig](https://github.com/Willie169/xmrig) and through Tor. Change the wallet address and other configurations if you want.
- [`xmrig-rvn.sh`](xmrig-rvn.sh): Mines RVN to [the repository owner](https://github.com/Willie169)'s wallet, `RCo4QqzEnEtEVv749TJfNz293p2xVVhXFx`, using my modified version of [XMRig](https://github.com/Willie169/xmrig) and through Tor. Change the wallet address and other configurations if you want.

### [`ruview.sh`](ruview.sh) (no longer actively maintained)

Installs [RuView](https://github.com/ruvnet/RuView) from source (Rust), which requires approximately 13.8 GB storage. The binaries are at `~/RuView/v2/target/release`, which has been added to `$PATH` in [`install-tools-first.sh`](install-tools-first.sh). See <https://github.com/ruvnet/RuView/blob/main/docs/user-guide.md> for more information.

## Instructions

### Table of Contents

+ [Desktop Environment](#desktop-environment)
+ [Wayland](#wayland)
+ [Linux Mint Ubuntu Version Tweak](#linux-mint-ubuntu-version-tweak)
+ [Desktop App Launchers](#desktop-app-launchers)
+ [Fcitx5](#fcitx5)
+ [Tailscale](#tailscale)
+ [VirtualGL and TurboVNC](#virtualgl-and-turbovnc)
+ [Waydroid](#waydroid)
+ [Solution for Closing Lip Overrides Power Off](#solution-for-closing-lip-overrides-power-off)
+ [Bottles](#bottles)
+ [My Related Repositories](#my-related-repositories)

### Desktop Environment

#### GNOME 3

- Ubuntu uses it.
- Uses GDM.
- Supports both X11 and Wayland.
- Built upon GTK.

#### KDE Plasma

- Kubuntu uses it.
- Uses SDDM.
- Supports both X11 and Wayland.
- Built upon Qt.

#### Cinnamon

- Linux Mint Cinnamon Edition uses it.
- Uses LightDM.
- Supports X11.
- Not fully supports Wayland currently.
- Built upon GTK.

### Wayland

#### Prerequisites

Run `echo $XDG_SESSION_TYPE`. If it prints `wayland`, you're already using Wayland. Otherwise, determine your Desktop Environment and follow the corresponding section below:
<ul>
<li>GNOME 3, which Ubuntu usually uses, supports Wayland.</li>
<li>KDE Plasma, which Kubuntu uses, supports Wayland.</li>
<li>Cinnamon, which Linux Mint usually uses, doesn't fully support Wayland currently. This instruction does not cover how to switch to Wayland on Cinnamon. Sorry.</li>
</ul>
See <a href="#desktop-environment">Desktop Environment</a> section for more information.

#### Enable Wayland for GNOME3

<ol>
<li>Log out.</li>
<li>In the down right corner of the login page, choose <code>Ubuntu on Wayland</code>.</li>
</ol>

#### Enable Wayland for KDE Plasma

<ol>
<li>Run:
<pre><code>sudo apt install plasma-workspace-wayland -y
</code></pre></li>
<li>Log out.</li>
<li>In the down left corner of the login page, choose <code>Plasma (Wayland)</code>.</li>
</ol>

### Linux Mint Ubuntu Version Tweak

To make a script for Ubuntu work for both Ubuntu and Linux Mint, do the following tweaks:

<ol>
<li><code>$(lsb_release -cs)</code>: Replace it with <code>$(. /etc/os-release && echo ${UBUNTU_CODENAME})</code>.</li>
<li><code>$VERSION_ID</code> from <code>/etc/os-release</code>: Add
<pre><code>export UBUNTU_VERSION_ID=$(
if grep -q '^NAME="Linux Mint"' /etc/os-release; then
    inxi -Sx | awk -F': ' '/base/{print $2}' | awk '{print $2}'
else
    . /etc/os-release
    echo "$VERSION_ID"
fi
)
</code></pre>
before it and replace it with <code>$UBUNTU_VERSION_ID</code>.</li>
</ol>
These have been added to <code>~/.bashrc</code> in <a href="install-tools-first.sh"><code>install-tools-first.sh</code></a>.

### Desktop App Launchers

#### Command line

```
cp /usr/share/applications/<application_name>.desktop ~/Desktop/
chmod +x ~/Desktop/<application_name>.desktop
```

#### Linux Mint GUI

1. Click **Mint menu button** (lower left corner).
2. Find the app you want.
3. Right-click and click `Add to desktop`.

#### KDE Plasma GUI

1. Click **Application Launcher** (lower left corner).
2. Find the app you want.
3. Right-click and click `Add to Desktop`.

### Fcitx5

#### GNOME 3 and Cinnamon

You can configure Fcitx5 input methods in `Fcitx Configuration`.

#### KDE Plasma

1. It usually will automatically detect and setup Fcitx5 after running [`install-tools-first.sh`](install-tools-first.sh). If not, go to `System Settings` > `Input & Output` or `Keyboard` > `Virtual Keyboard`, then select `Fcitx5`.
2. You can configure Fcitx5 input methods in `Input Method`, which can be launched by either right-clicking the keyboard icon at the bottom right corner of the `Task Manager` and clicking `Configure` or going to `System Settings` and searching `Input Method`.

### Tailscale

#### Install

The script below has been included in [`install-tools-first.sh`](install-tools-first.sh).
```
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt update
sudo apt install tailscale -y
```

#### Log in

```
sudo tailscale up
```

Log in via the URL shown and click **Connect**. Google, Microsoft, GitHub, Apple, and passkey are available.

#### Systemd

```
sudo systemctl enable tailscaled
sudo systemctl start tailscaled
```

#### Tailscale IP

Your tailscale ip will be

```
tailscale ip
```

You can connect to it from another device logged in with the same account.

#### Tailscale in Android

Tailscale (`com.tailscale.ipn`) can be installed from [F-Droid](https://f-droid.org/packages/com.tailscale.ipn) or [Google Play](https://play.google.com/store/apps/details?id=com.tailscale.ipn).

You can view the devices logged in and their Tailscale IPs in the app.

See my [**Android-Non-Root**](https://github.com/Willie169/Android-Non-Root) repo for more information.

### VirtualGL and TurboVNC

#### VNC Server Usage

* Set password for VNC client to access the VNC server on the computer: `vncpasswd`.
* Start VNC server: `vncserver`.
* List VNC servers: `vncserver -list`.
* Kill VNC server: `vncserver -kill :1`. Replace `:1` with your actual display number.

#### TigerVNC

You may want to use TigerVNC instead if your computer does not have a GPU or don't want to use GPU acceleration. It can be installed via:
```
sudo apt install tigervnc-standalone-server -y
```
Its usage is the same as TurboVNC.

#### Android as SSH and VNC/X Client

If you do not have a VNC client of your choice, I suggest either of the following apps:
- [Haven](https://github.com/GlassHaven/Haven) from [F-Droid](https://f-droid.org/packages/sh.haven.app): an open-source SSH, VNC, RDP, and SFTP client for Android with a native Wayland desktop and cloud storage.
- [AVNC](https://github.com/gujjwal00/avnc) from [F-Droid](https://f-droid.org/packages/com.gaurav.avnc): an open source VNC client for Android.

### Waydroid

See [offficial site](https://waydro.id), [documentation](https://docs.waydro.id), and [repo](https://github.com/waydroid/waydroid) for more information.

#### Wayland

Waydroid runs natively on Wayland, see [Wayland](#wayland) section for how to switch to Wayland.

#### X11

If you want to use it on X11, use Weston. First install it with
```
sudo apt install weston -y
```
Each time using Waydroid, run
```
weston --socket=mysocket
```
and run Waydroid in the Weston terminal.

See <https://gist.github.com/1999AZZAR/5c881fdaeb841fc4476259bfcc69b98c> for more information.

#### Install

```
sudo apt update
sudo apt install curl ca-certificates wget liblxc1 liblxc-common lxc -y
curl -s https://repo.waydro.id | sudo bash
sudo apt update
sudo apt install waydroid -y
```
Done in [`waydroid.sh`](waydroid.sh).

#### Network

For UFW,
```
sudo ufw allow 53
sudo ufw allow 67
sudo ufw default allow FORWARD
```
Done in [`waydroid.sh`](waydroid.sh).

#### Install Android

1. Open Waydroid by running `waydroid` or with desktop entry.
2. Choose options you want. In `Android Type`, there are `Minimal Android` or `Vanilla`, which refers to a pure AOSP (Android Open-Source Project) build without any Google services and occupies approximately 1.0 GB, and `Android with Google Apps` or `Gapps`, which refers to a build that provides access to Google services and occupies approximately 1.4 GB. For beginners, `Android with Google Apps` is recommended.
3. Press `Download`, wait until `Done` button is shown, and press it.

#### NVIDIA GPU

Currently Waydroid needs to run on the same GPU the host compositor is running on. NVIDIA GPUs don't support Waydroid.

If you have integrated GPU alongside it, you may switch to the integrated GPU for the whole desktop session or use
```
waydroid session stop
wget https://github.com/Quackdoc/waydroid-scripts/raw/refs/heads/main/waydroid-choose-gpu.sh
sudo bash waydroid-choose-gpu.sh
```
to select it, and then run:
```
sudo waydroid upgrade --offline
sudo systemctl restart waydroid-container
```
and then reboot your computer.

Alternatively, switch software rendering by editing `/var/lib/waydroid/waydroid.cfg` and adding
```
ro.hardware.gralloc=default
ro.hardware.egl=swiftshader
```
under `[properties]`, and then running:
```
waydroid session stop
sudo waydroid upgrade --offline
sudo systemctl restart waydroid-container
```

To undo it, remove those lines in `/var/lib/waydroid/waydroid.cfg`, and edit `/var/lib/waydroid/waydroid_base.prop` and replace those lines with
```
ro.hardware.gralloc=gbm
ro.hardware.egl=mesa
```
and then run:
```
waydroid session stop
sudo waydroid upgrade --offline
sudo systemctl restart waydroid-container
```

See <https://github.com/Quackdoc/waydroid-scripts> for more information.

#### Prevent Flutter Apps Crashes

To prevent Vulkan from crashing in Flutter apps, edit `/var/lib/waydroid/waydroid.cfg` and add
```
ro.product.model=gphone_x64
```
under `[properties]`, and then run:
```
waydroid session stop
sudo waydroid upgrade --offline
sudo systemctl restart waydroid-container
```

#### Spoof Device to Bypass Root Detections

Some root detections can be bypassed by editting `/var/lib/waydroid/waydroid.cfg` and adding
```
ro.product.brand=google
ro.product.manufacturer=Google
ro.system.build.product=redfin
ro.product.name=redfin
ro.product.device=redfin
ro.product.model=gphone_x64
ro.system.build.flavor=redfin-user
ro.build.fingerprint=google/redfin/redfin:11/RQ3A.211001.001/eng.electr.20230318.111310:user/release-keys
ro.system.build.description=redfin-user 11 RQ3A.211001.001 eng.electr.20230318.111310 release-keys
ro.bootimage.build.fingerprint=google/redfin/redfin:11/RQ3A.211001.001/eng.electr.20230318.111310:user/release-keys
ro.build.display.id=google/redfin/redfin:11/RQ3A.211001.001/eng.electr.20230318.111310:user/release-keys
ro.build.tags=release-keys
ro.build.description=redfin-user 11 RQ3A.211001.001 eng.electr.20230318.111310 release-keys
ro.vendor.build.fingerprint=google/redfin/redfin:11/RQ3A.211001.001/eng.electr.20230318.111310:user/release-keys
ro.vendor.build.id=RQ3A.211001.001
ro.vendor.build.tags=release-keys
ro.vendor.build.type=user
ro.odm.build.tags=release-keys
```
under `[properties]`, and then running:
```
waydroid session stop
sudo waydroid upgrade --offline
sudo systemctl restart waydroid-container
```

See <https://github.com/waydroid/waydroid/issues/1060> for more information.

#### Waydroid Extras Script

```
sudo apt install python3 python3-venv lzip -y
git clone https://github.com/casualsnek/waydroid_script
cd waydroid_script
python3 -m venv venv
venv/bin/pip install -r requirements.txt
sudo venv/bin/python3 main.py
```
Select what you want in the interactive terminal interface.

- microG is a FLOSS implementation of Google Play Services, which you don't need in Gapps build.
- libndk and libhoudini are ARM translation layers. Due to optimizations in the translation layers, it is recommended to use libndk on AMD CPUs and libhoudini on Intel CPUs. When using ARM translation layer, it is still recommended to use x86\_64 app when available in most cases as the translation layer is not quite stable. When using [Obtainium](https://github.com/ImranR98/Obtainium), you can add an app with only ARM apks by turning off "Attempt to filter APKs by CPU
    architecture if possible" and filter the architecture you want to install with "Filter APKs by regular expression" when there are multiple architectures.
- If you install Smart Dock and Trebuchet keeps crashing, run `sudo waydroid shell pm disable com.android.launcher3` to disable it. However, recent apps page will not work after disabling. If you disabled it and then delete Smart Dock, run `sudo waydroid shell pm enable com.android.launcher3` to enable it. It should not crash when not used with Smart Dock.

Afterwards, run
```
waydroid session stop
sudo waydroid upgrade --offline
sudo systemctl restart waydroid-container
```

See <https://github.com/casualsnek/waydroid_script> for more information.

#### Google Play Certificate

This only work with GAPPS installed. For Vanilla build, install Aurora Store: <https://gitlab.com/AuroraOSS/AuroraStore> from F-Droid: <https://f-droid.org/packages/com.aurora.store>.

Run:
```
sudo waydroid shell
```
to enter Waydroid's ABD shell and then run:
```
ANDROID_RUNTIME_ROOT=/apex/com.android.runtime ANDROID_DATA=/data ANDROID_TZDATA_ROOT=/apex/com.android.tzdata ANDROID_I18N_ROOT=/apex/com.android.i18n sqlite3 /data/data/com.google.android.gsf/databases/gservices.db "select * from main where name = \"android_id\";"
```
in it to get the Google Services Framework Android ID. Use the numbers printed to register the device on your Google Account at <https://www.google.com/android/uncertified>.

Run `exit` inside Waydroid's ADB shell to exit it.

Give the Google services some minutes to reflect the change, then restart Waydroid.

#### Restart

If you click Power off in Waydroid GUI and then try to restart, or click Restart in Waydroid, but it doesn't start a new session, run
```
waydroid session stop
```
and then you can start it with desktop entry or running
```
waydroid session start
```
If you run
```
waydroid session stop
```
to stop Waydroid instead of from GUI, and restarting by running
```
waydroid session start
```
doesn't start a new session, start it with desktop entry.

#### Storage

Waydroid's home directory is:
```
~/.local/share/waydroid/data/media/0/
```
This has been exported as `WAYDROID` in `.bashrc` in [`install-tools-first.sh`](install-tools-first.sh).

To mount it in host, run
```
sudo mkdir /mnt/waydroid
sudo bindfs --mirror=$(id -u) ~/.local/share/waydroid/data/media/0 /mnt/waydroid
```
where `bindfs` can be installed with
```
sudo apt install bindfs
```
This is defined as function `bind_waydroid` in [`install-tools-first.sh`](install-tools-first.sh).

This can be made permanent by
```
echo "$HOME/.local/share/waydroid/data/media/0 /mnt/waydroid fuse rw,nosuid,nodev,relatime,user_id=0,group_id=0,default_permissions,allow_other 0 0" | sudo tee -a /etc/fstab >/dev/null
```
Note that you need to remove this line manually after removing Waydroid. Otherwise, you may boot into emergency mode next boot, and you can remove this line there.

Remember to `chmod 770` folders and `chmod 660` files to be accessible in Waydroid.

#### Multi-Window Mode

Run:
```
waydroid session stop
waydroid session start & >/dev/null
waydroid prop set persist.waydroid.multi_windows true
waydroid session stop
sudo systemctl restart waydroid-container
```
Next time Waydroid will start in multi-window mode.

#### Use ADB with Waydroid

Grab waydroid IP address from `Android Settings > About`

And start adb:
```
adb connect <IP>:5555
```
Alternatively, you can run
```
sudo waydroid shell
```
to access Waydroid's ADB shell.

#### Disable On-Screen Keyboard

Waydroid by default shows the Android virtual keyboard when selecting an input field. To disable that, and only use the physical keyboard, turn off the following setting: `Settings > System > Languages & input > Physical keyboard > Use on-screen keyboard`.

#### Input Method

There is no known way to use host's input method in Waydroid. However, you can install input methods that work with physical keyboard, such as Gboard, in Waydroid.

#### Remove

Run:
```
waydroid session stop
sudo waydroid container stop
sudo apt remove waydroid -y
```
reboot, and them run
```
sudo rm -rf /var/lib/waydroid /home/.waydroid ~/waydroid ~/.share/waydroid ~/.local/share/applications/*aydroid* ~/.local/share/waydroid
```

### Solution for Closing Lip Overrides Power Off

#### Symptom

After clicked shut down and then closed the lip, the laptop didn't shut down.

#### Solution

The operation below has been included in [`install-tools-first.sh`](install-tools-first.sh).

Run:
```
sudo vim /etc/systemd/logind.conf
```
add or change the line to:
```
HandleLidSwitch=ignore
HandleLidSwitchDocked=ignore
HandleLidSwitchExternalPower=ignore
```
run:
```
sudo systemctl restart systemd-logind
```

### Bottles

Bottles lets you run Windows software on Linux, such as applications and games. It introduces a workflow that helps you organize by categorizing each software to your liking. Bottles provides several tools and integrations to help you manage and optimize your applications.

See <https://usebottles.com> for more information.

#### Install 

Bottles has been installed in [`install-tools-first.sh`](install-tools-first.sh) and [`install-tools-second.sh`](install-tools-second.sh).

Flatpak is required. Run:
```
echo y | sudo ubuntu-drivers install || true
echo y | sudo ubuntu-drivers install || true
echo y | sudo ubuntu-drivers install || true
echo y | sudo ubuntu-drivers autoinstall || true
echo y | sudo ubuntu-drivers autoinstall || true
echo y | sudo ubuntu-drivers autoinstall || true
flatpak install flathub com.usebottles.bottles
flatpak run com.usebottles.bottles
```
and follow the screen prompts.

#### Run

```
flatpak run com.usebottles.bottles
```

You can add the variable and aliases below in your `.bashrc`, which has been done in [`install-tools-first.sh`](install-tools-first.sh):

```
export BOTTLES="$HOME/.var/app/com.usebottles.bottles/data/bottles"
alias bottles='flatpak run com.usebottles.bottles'
alias bottles-cli='flatpak run --command=bottles-cli com.usebottles.bottles'
```

### My Related Repositories

* [**termux-sh**](https://github.com/Willie169/termux-sh)
* [**switch-firefox-from-snap-to-deb**](https://github.com/Willie169/switch-firefox-from-snap-to-deb)
* [**dual-boot-windows-linux-and-recovery**](https://github.com/Willie169/dual-boot-windows-linux-and-recovery)
* [**LinuxAndTermuxTips**](https://github.com/Willie169/LinuxAndTermuxTips)
* [**Android Non Root**](https://github.com/Willie169/Android-Non-Root) and its [site](https://willie169.github.io/Android-Non-Root)

## License

This repository is licensed under GNU General Public License General Public License, see [LICENSE.md](LICENSE.md) for details.
