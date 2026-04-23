# ubuntu-setup-with-vnc-and-gpu

Scripts and instructions for setting up Ubuntu derivatives on AMD64 with tools for development, productivity, graphics, remote control, multimedia, communication, and more.

## Main Installation Scripts

### Prerequisites

* Sufficient storage: (calculated on Kubuntu 24.04.3)
  * Kubuntu 24.04.3 Full Installation: approximately 11.2 GB,
  * Kubuntu 24.04.3 Full Installation plus [`install-tools-first.sh`](install-tools-first.sh): approximately 88.8 GB.
  * [`install-tools-second.sh`](install-tools-second.sh): approximately 13.3 GB.
* Sufficient power supply.
* Stable internet connection.

### Usage 

<ol>
<li>Run
<pre><code>cd ~
sudo apt update
sudo apt install bash git -y
git clone https://github.com/Willie169/ubuntu-setup-with-vnc-and-gpu
cd ubuntu-setup-with-vnc-and-gpu
./install-tools-first.sh
</code></pre>
and follow the prompts until the computer reboots automatically.</li>
<li>Login after the reboot and run
<pre><code>cd ~/ubuntu-setup-with-vnc-and-gpu
./install-tools-second.sh
</code></pre>
until it exits automatically.</li>
<li>You can list installed Snap packages with <code>snap list</code>. You may want to cleanup remaining Snap packages that you don&#39;t need or are already installed from other sources in previous scripts, e.g., 
<pre><code>snap remove element-desktop ffmpeg-2204 firmware-updater krita gnome-42-2204 gnome-46-2404 gtk-common-themes kf5-core22 mesa-2404</code></pre>
</li>
<li>Go to <a href="http://localhost:8082">http://localhost:8082</a>, enter default user name <code>admin</code> and password <code>admin123</code>, change user name and password, and login in the pop-up window of ClipCascade client.</li>
<li>Snap Firefox and Thunderbird are replaced with Deb Firefox and Thunderbird from Mozilla Team PPA, and thus you may want to re-configure launchers in your Desktop Environment.</li>
<li>If any error occurs when opening Firefox, try running:
<pre><code>sudo ln -sf /etc/apparmor.d/firefox /etc/apparmor.d/disable/
sudo apparmor_parser -R /etc/apparmor.d/firefox
</code></pre>
to disable Firefox AppArmor profile.</li>
<li>Run
<pre><code>sudo tailscale up
</code></pre>
to login to Tailscale via the URL shown and click <strong>Connect</strong>. Google, Microsoft, GitHub, Apple, and passkey are available.</li>
<li>Run `element-desktop --password-store="gnome-libsecret"`. It will prompt you to choose password for a new keying called "Default keyring". Set a password for it. It will also be used in other apps with `gnome-keyring` such as Ente Auth. And then you can login to your Matrix account.</li>
<li>Launch Ente Auth by running `enteauth` or with desktop entry. Type password of "Default keyring" of `gnome-keyring` if prompted. And then you can login to your Ente account.</li>
<li>Run
<pre><code>gh auth login --scopes repo,read:org,admin:org,workflow,gist,notifications,delete_repo,write:packages,read:packages
</code></pre>
to login to GitHub.</li>
<li>Run `flatpak run com.mikeasoft.pied` to setup Pied.</li>
<li>You may want to config git with <code>git config --global user.name [your_name] &amp;&amp; git config --global user.email [your_email]</code>, <code>git config --global pull.rebase true</code> etc.</li>
<li>Run <code>code</code> or click the <strong>VSCodium</strong> icon to setup VSCodium.</li>
<li>Run <code>codeblocks</code> or click the <strong>Code::Blocks IDE</strong> icon to setup Code::Blocks.</li>
<li>Run <code>studio</code> or click the <strong>Android Studio</strong> icon to setup Android Studio. <code>&quot;system-images;android-33;google_apis_playstore;x86_64&quot; &quot;system-images;android-36.1;google_apis_playstore;x86_64&quot;</code> installation in <a href="install-tools-first.sh"><code>install-tools-first.sh</code></a> may fail silently due to network issue, you can download it again via <code>sdkmanager &quot;system-images;android-33;google_apis_playstore;x86_64&quot; &quot;system-images;android-36.1;google_apis_playstore;x86_64&quot;</code> or Android Studio GUI.</li>
<li>Run <code>torbrowser-launcher</code> or click the <strong>Tor Browser</strong> icon to finish installing Tor Browser.</li>
<li>Run <code>steam</code> to finish installing Steam. Running twice may be required.</li>
<li>Go to <a href="http://localhost:8080">http://localhost:8080</a> and setup Open WebUI.</li>
<li>Go to <a href="#other-scripts">Other Scripts</a> section for other scripts in this repository.</li>
<li>Go to <a href="#instructions">Instructions</a> section for instructions.</li>
</ol>

### Content of Main Installation Scripts

Configures dual-boot friendly configurations, enables automatic login if on GDM, SDDM, or LightDM, enables Wayland if on GDM or SDDM, disables KDE Wallet if installed, installs recommended drivers and tools for C, C++, Python3, Java8, Java17, Java21, Node.js LTS (via NVM), Rust, Go, Ruby, Perl, Fortran, Qt5, .NET SDK 10, ASP.NET Core Runtime 10, Aptitude, GitHub CLI, GitLab CLI, Kate, GVim, OpenSSL, OpenSSH, Tailscale, GNOME Keyring, JQ, DMG2IMG, libguestfs, GHC Filesystem, FFMPEG, Fcitx5, OpenCL, Snap, Flatpak (all Flatpak apps are defined with CLI aliases to be able to be run like native apps), QEMU, Quickemu, TeX Live (via regular installation instead of APT, for unrestricted `tlmgr` and updates), Pandoc, NTFS-3G, Microsoft True Type Core Fonts, Noto CJK fonts, CNS11643中文標準交換碼全字庫正楷體與正宋體, Maven, Zsh, iproute2, net-tools, Nmap, Alien, aria2, nvm, pnpm, Yarn, NPM packages `jsdom markdown-toc marked marked-gfm-heading-id node-html-markdown showdown` locally in `~`, http-server, Bun, Homebrew, Filelight, Glow, Tennis, Miniforge, pipx, uv, Poetry, MarkItDown, LibreTranslate, gh2md, Jupyter Notebook, JupyterLab, Jupytext, Meson, Tree-sitter CLI, pylatexenc, lazy.nvim and Neovim plugins from my [**bashrc**](https://github.com/Willie169/bashrc) repo (can be updated by running `update_nvim`), LSP servers, WinRAR, Icarus Verilog, Verilator, Ngspice, Caneda, jpegoptim, optipng, libheif, LibWebP, ImageMagick, Inkscape, Poppler, qpdf, PDFtk, Ghostscript, Bookletimposer, Tesseract, Audacity, abcde, GitComet, XMLStarlet, GTKWave, SDL2, SDL2 BGI, Docker, Podman, Ollama, Llama.cpp (in `~/dev/llm/llama.cpp/build/bin` and added to `$PATH`), Open WebUI (enabled with `systemctl --user enable --now open-webui` on `http://localhost:8080`), llmfit, Open NoteBook (using Docker compose in `~/.open-notebook` on `http://localhost:8502`, can be started by running `open-notebook-up`, stopped by running `open-notebook-stop`, and downed by running `open-notebook-down`), LiteLLM (using Docker compose in `~/.litellm` enabled with `systemctl --user enable --now litellm` on `http://localhost:4000`, keys can be added to `~/.litellm/.env`, where those in `~/API_KEY.sh` are imported automatically, can be started by running `litellm-up`, stopped by running `litellm-stop`, and downed by running `litellm-down`), CyberChef (server enabled with `systemctl --user enable --now cyberchef` on `http://localhost:8081`), Caddy, Tuwunel (setup with a server with name `matrix.lan` at port `8008` with reverse proxy Caddy), Element Desktop (start it with `element-desktop --password-store="gnome-libsecret"` at the first time, and then you can use `element-desktop` or desktop entry to launch it), Tokodon, Newsflash, Document Scanner, Octave, VSCodium, Code::Blocks, qBittorrent, Remmina, Balena Etcher, Arduino CLI, Arduino IDE (inside `~/.local/arduino-ide` and can be launched with `~/.local/bin/arduino-ide`, which has been added in `PATH` in `.bashrc`), ANTLR 4 (JAR in `/usr/local/java`), Tor, Tor Browser, PlantUML (JAR in `/usr/local/java`), clang-uml, SQLite 3, PostgreSQL 17, Steam, Brisk, LocalSend, RustDesk (check Enable direct IP access under Security to use it with Tailscale), RustDesk server (in client, in ID/Relay server, paste the IP of the machine in ID server and Relay server and the public key in `/var/lib/rustdesk-server/id_ed25519.pub` in Key), Godot .NET version (inside `~/.local/godot/` and symlinked to `~/.local/bin/godot`, which has been added in `PATH` in `.bashrc`, and can be launched with desktop entry `~/.local/share/applications/godot.desktop`), Android Studio (can be launched with desktop entry `/usr/share/applications/android-studio.desktop`), Android Command-line tools, Android SDK `"build-tools;30.0.3" "build-tools;36.1.0" "emulator" "ndk;29.0.14206865" "platform-tools" "platforms;android-33" "platforms;android-36" "sources;android-33" "sources;android-36.1" "system-images;android-33;google_apis_playstore;x86_64" "system-images;android-36.1;google_apis_playstore;x86_64"`, fdroidserver, Brave Browser, Proton Mail, Proton Mail Bridge, Bottles, Ente Auth, Discord, OBS Studio, HandBrake, FreeTube, GIMP, Luanti, Telegram, Pied (run `flatpak run com.mikeasoft.pied` to setup it), Aisleriot Solitaire, Kdenlive, KiCad (can be launched with desktop entry `~/.local/share/applications/kicad.desktop`), ClipCascade (server enabled with `systemctl --user enable --now clipcascade-server` on `http://localhost:8082`, client enabled with `systemctl --user enable --now clipcascade-client`), Krita, MuseScore, OnlyOffice, VLC, Striling PDF (using Docker compose in `~/stirlingpdf` on `http://localhost:8083`, can be started by running `stirlingpdf-up`, stopped by running `stirlingpdf-stop`, and downed by running `stirlingpdf-down`), KataGo (`~/KataGo/cpp/katago` and can be run with `katago`) and KataGo network `kata1-b6c96-s175395328-d26788732` (in `~/katago-networks`, other networks can be downloaded from <https://katagotraining.org/networks>), LizzieYzy (can be launched by running `lizzieyzy` or with desktop entry `~/.local/share/applications/lizzieyzy.desktop`, runtime directory `~/.lizzieyzy`, KataGo network `kata1-b6c96-s175395328-d26788732` configured as default engine and estimate engine in `~/.lizzieyzy/config.txt`, which can be updated by running `update_lizzieyzy_config`), Fairy-Stockfish (`~/Fairy-Stockfish/src/stockfish` and can be run with `stockfish`), Cute Chess (GUI at `~/cutechess/build/cutechess` and can be launched by running `cutechess` or with desktop entry `~/.local/share/applications/cutechess.desktop`, CLI at `~/cutechess/build/cutechess-cli` and can be run with `cutechess-cli`, Fairy-Stockfish configured as engine in `~/.config/cutechess/engines.json`, which can be updated by running `update_cutechess_config`), Sylvan (GUI at `~/Sylvan/projects/gui/sylvan` and can be launched by running `sylvan` or with desktop entry `~/.local/share/applications/sylvan.desktop`, CLI at `~/Sylvan/projects/cli/sylvan-cli` and can be run with `sylvan-cli`, Fairy-Stockfish configured as engine in `~/.config/EterCyber/engines.json`, which can be updated by running `update_sylvan_config`), [my modified version](https://github.com/Willie169/vimrc) of [vimrc by Amir Salihefendic (amix)](https://github.com/amix/vimrc) for both Vim and Neovim (can be updated by running `update_vimrc`), my LaTeX package [`physics-patch`](https://github.com/Willie169/physics-patch) and checks out `dev` branch and my LaTeX template [`LaTeX-ToolKit`](https://github.com/Willie169/LaTeX-ToolKit) (can be updated with `update_latex`), switches from Snap Firefox and Thunderbird to Deb Firefox and Thunderbird from Mozilla Team PPA and enables unattended upgrade and prevents Snap Chromium from being installed if on Ubuntu and not on Linux Mint and install Google Chrome, using scripts from my [switch-firefox-from-snap-to-deb](https://github.com/Willie169/switch-firefox-from-snap-to-deb), and copies `~/.bashrc.d` and `~/.bashrc` from my [**bashrc**](https://github.com/Willie169/bashrc) repo (can be updated by running `update_bashrc`), and more.

## Other Scripts

### [`virtualgl-turbovnc.sh`](virtualgl-turbovnc.sh)

Installs VirtualGL and TurboVNC on Debian derivatives on AMD 64, compatible with most GPU. Requires about 0.1 GB storage. See [VirtualGL and TurboVNC](#virtualgl-and-turbovnc) section for the necessary steps to do after running this script and more information.

You may want to use TigerVNC instead if your computer does not have a GPU. See [VirtualGL and TurboVNC](#virtualgl-and-turbovnc) section for more information.

### [`waydroid.sh`](waydroid.sh)

Installs Waydroid on Debian derivatives on AMD 64. See [Waydroid](#waydroid) section for it does and what to do after running this script and more information.

### [`cuda.sh`](cuda.sh)

Installs NVIDIA drivers, NVIDIA Wayland, and CUDA Toolkit on Ubuntu 24.04 with Nvidia GPU. Requires about 8 GB storage.

Restart your computer after running the script and then test with:
```
nvidia-smi
nvcc --version
```

### [`xmrig-install.sh`](xmrig-install.sh) and [`xmrig.sh`](xmrig.sh)

- [`xmrig-install.sh`](xmrig-install.sh): Builds my modified version of [XMRig](https://github.com/Willie169/xmrig), an open source, cross-platform RandomX, KawPow, CryptoNight and GhostRider CPU/GPU miner, RandomX benchmark, and stratum proxy.
- [`xmrig-xmr.sh`](xmrig-xmr.sh): Mines XMR to [the repository owner](https://github.com/Willie169)'s wallet, `48j6iQDeCSDeH46gw4dPJnMsa6TQzPa6WJaYbBS9JJucKqg9Mkt5EDe9nSkES3b8u7V6XJfL8neAPAtbEpmV2f4XC7bdbkv`, using my modified version of [XMRig](https://github.com/Willie169/xmrig) and through Tor. Change the wallet address and other configurations if you want.
- [`xmrig-rvn.sh`](xmrig-rvn.sh): Mines RVN to [the repository owner](https://github.com/Willie169)'s wallet, `RCo4QqzEnEtEVv749TJfNz293p2xVVhXFx`, using my modified version of [XMRig](https://github.com/Willie169/xmrig) and through Tor. Change the wallet address and other configurations if you want.

## Instructions

### Table of Contents

+ [Dual Boot with Windows](#dual-boot-with-windows)
+ [Desktop Environment](#desktop-environment)
+ [Wayland](#wayland)
+ [Linux Mint Ubuntu Version Tweak](#linux-mint-ubuntu-version-tweak)
+ [Desktop App Launchers](#desktop-app-launchers)
+ [Fcitx5](#fcitx5)
+ [OpenSSH](#openssh)
+ [Tailscale](#tailscale)
+ [VirtualGL and TurboVNC](#virtualgl-and-turbovnc)
+ [Waydroid](#waydroid)
+ [Solution for Closing Lip Overrides Power Off](#solution-for-closing-lip-overrides-power-off)
+ [Bottles](#bottles)
+ [My Related Repositories](#my-related-repositories)

### Dual Boot with Windows

See my [**dual-boot-windows-linux-and-recovery**](https://github.com/Willie169/dual-boot-windows-linux-and-recovery) repo.

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

<ol>
<li>Determine your Desktop Environment and follow the corresponding section below:
<ul>
<li>GNOME 3, which Ubuntu usually uses, supports Wayland.</li>
<li>KDE Plasma, which Kubuntu uses, supports Wayland.</li>
<li>Cinnamon, which Linux Mint usually uses, doesn't fully support Wayland currently. This instruction does not cover how to switch to Wayland on Cinnamon. Sorry.</li>
</ul>
See <a href="#desktop-environment">Desktop Environment</a> section for more information.</li>
</ol>

#### Enable Wayland for GNOME3 without NVIDIA GPU

<ol>
<li>Log out.</li>
<li>In the down right corner of the login page, choose <code>Ubuntu on Wayland</code>.</li>
</ol>

#### Enable Wayland for KDE Plasma without NVIDIA GPU

<ol>
<li>Run:
<pre><code>sudo apt install plasma-workspace-wayland -y
</code></pre></li>
<li>Log out.</li>
<li>In the down left corner of the login page, choose <code>Plasma (Wayland)</code>.</li>
</ol>

#### Enable Wayland for GNOME3 with NVIDIA GPU

<ol>
<li>Run:
<pre><code>sudo apt install libnvidia-egl-wayland1 -y
</code></pre></li>
<li>Run:
<pre><code>sudo sed -i 's|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia_drm.modeset=1"|' /etc/default/grub
</code></pre></li>
<li>Run:
<pre><code>sudo update-grub
sudo update-initramfs -u
</code></pre></li>
<li>Reboot the computer.</li>
<li>In the down right corner of the login page, choose <code>Ubuntu on Wayland</code>.</li>
</ol>

#### Enable Wayland for KDE Plasma with NVIDIA GPU

<ol>
<li>Run:
<pre><code>sudo apt install libnvidia-egl-wayland1 plasma-workspace-wayland -y
</code></pre></li>
<li>Run:
<pre><code>sudo sed -i 's|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia_drm.modeset=1"|' /etc/default/grub
</code></pre></li>
<li>Run:
<pre><code>sudo update-grub
sudo update-initramfs -u
</code></pre></li>
<li>Reboot the computer.</li>
<li>In the down left corner of the login page, choose <code>Plasma (Wayland)</code>.</li>
</ol>

### Linux Mint Ubuntu Version Tweak

To make a script for Ubuntu work for both Ubuntu and Linux Mint, do the following tweaks:

<ol>
<li><code>$(lsb_release -cs)</code>: Add <code>source /etc/os-release</code> before it and replace it with <code>$UBUNTU_CODENAME</code>.</li>
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

### OpenSSH Server

#### Introduction

* SSH provides a secure way for accessing remote hosts and replaces tools such as telnet, rlogin, rsh, ftp.
* OpenSSH, also known as OpenBSD Secure Shell, is a suite of secure networking utilities based on the Secure Shell (SSH) protocol, which provides a secure channel over an unsecured network in a client–server architecture.
* Default SSH port is `22`.

#### Install

This has been done in [`install-tools-first.sh`](install-tools-first.sh).

```
sudo apt install openssh-server
```

#### Systemd Start and Enable

This has been done in [`install-tools-first.sh`](install-tools-first.sh).
```
sudo systemctl start ssh
sudo systemctl enable ssh
```

#### Systemd Stop and Disable

```
sudo systemctl stop ssh
sudo systemctl disable ssh
```

#### Ubuntu Firewall

This has been done in [`install-tools-first.sh`](install-tools-first.sh).
```
sudo ufw enable
sudo ufw allow ssh
```

#### Edit Configuration

```
sudo nano /etc/ssh/sshd_config
```
and change lines in it.

##### SSH Port

```
#Port 22
```

##### Ports Listening to

```
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::
```

#### PasswordAuthentication

This has been done in [`install-tools-first.sh`](install-tools-first.sh).

Change the `PasswordAuthentication` line to

```
PasswordAuthentication yes
```

to permit password authentication. Password can be set by running `passwd`.

#### Android as SSH Client

SSH on [**Termux**](https://f-droid.org/packages/com.termux) is suggested if you do not have a client of your choice. See my [**Android-Non-Root**](https://github.com/Willie169/Android-Non-Root) repo for more information.

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

#### Prerequisites

<ol>
<li>Run <a href="virtualgl-turbovnc.sh"><code>virtualgl-turbovnc.sh</code></a> first if you have not. This requires about 0.1 GB storage.</li>
<li>Add <code>export PATH="/opt/TurboVNC/bin:$PATH</code> in <code>~/.bashrc</code>. This has been done in <a href="install-tools-first.sh"><code>install-tools-first.sh</code></a>.</li>
<li>Determine your Desktop Manager and GPU and follow the corresponding section below:
<ul>
<li>GNOME 3, which Ubuntu usually uses, uses GDM.</li>
<li>KDE Plasma, which Kubuntu uses, uses SDDM.</li>
<li>Cinnamon, which Linux Mint usually uses, uses LightDM.</li>
</ul>
See <a href="#desktop-environment">Desktop Environment</a> section for more information.</li>
<li>You may need a SSH server on your computer and client otherwhere. See [OpenSSH](#openssh) and [Tailscale](#tailscale) for more information.
</ol>

#### For GDM without NVIDIA GPU

<ol>
<li>In tty or from SSH client, run:
<pre><code>sudo systemctl stop gdm
sudo systemctl start gdm
</code></pre></li>
<li>Login into your computer.</li>
</ol>

#### For SDDM without NVIDIA GPU

<ol>
<li>In tty or from SSH client, run:
<pre><code>sudo systemctl stop sddm
sudo systemctl start sddm
</code></pre></li>
<li>Login into your computer.</li>
</ol>

#### For LightDM without NVIDIA GPU

<ol>
<li>In tty or from SSH client, run:
<pre><code>sudo systemctl stop lightdm
sudo systemctl start lightdm
</code></pre></li>
<li>Login into your computer.</li>
</ol>

#### For GDM with NVIDIA GPU

<ol>
<li>In tty or from SSH client, run:
<pre><code>sudo systemctl stop gdm
sudo modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia || true
sudo systemctl start gdm
</code></pre></li>
<li>Login into your computer.</li>
</ol>

#### For SDDM with NVIDIA GPU

<ol>
<li>In tty or from SSH client, run:
<pre><code>sudo systemctl stop sddm
sudo modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia || true
sudo systemctl start sddm
</code></pre></li>
<li>Login into your computer.</li>
</ol>

#### For LightDM with NVIDIA GPU

<ol>
<li>In tty or from SSH client, run:
<pre><code>sudo systemctl stop lightdm
sudo modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia || true
sudo systemctl start lightdm
</code></pre></li>
<li>Login into your computer.</li>
</ol>

#### TigerVNC

You may want to use TigerVNC instead if your computer does not have a GPU. It can be installed via:
```
sudo apt install tigervnc-standalone-server -y
```
Its usage is the same as TurboVNC, refer to [VNC Server Usage](#vnc-server-usage) section for it.

#### VNC Server Usage

* Set password for VNC client to access the VNC server on the computer: `vncpasswd`.
* Start VNC server: `vncserver`.
* List VNC servers: `vncserver -list`.
* Kill VNC server: `vncserver -kill :1`. Replace `:1` with your actual display number.

#### Android as SSH and VNC/X Client

[**AVNC**](https://f-droid.org/packages/com.gaurav.avnc) from F-Droid is suggested if you do not have a client of your choice. See my [**Android-Non-Root**](https://github.com/Willie169/Android-Non-Root) repo for more information.

### Waydroid

See offficial site: <https://waydro.id>, documentation: <https://docs.waydro.id>, and repo: <https://github.com/waydroid/waydroid> for more information.

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

#### GPU

Currently Waydroid needs to run on the same GPU the host compositor is running on. NVIDIA GPU doesn't support Waydroid. If you have other GPU alongside it, use
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

If you have no working GPU, edit `/var/lib/waydroid/waydroid.cfg` and add
```
ro.hardware.gralloc=default
ro.hardware.egl=swiftshader
```
under `[properties]`, and then run:
```
waydroid session stop
sudo waydroid upgrade --offline
sudo systemctl restart waydroid-container
```
to use software rendering.

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

#### Spoof device to bypass root detection:

```
sudo truncate -s -1 /var/lib/waydroid/waydroid.cfg
sudo tee -a /var/lib/waydroid/waydroid.cfg <<'EOF'
ro.product.brand=google
ro.product.manufacturer=Google
ro.system.build.product=redfin
ro.product.name=redfin
ro.product.device=redfin
ro.product.model=Pixel 5
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
EOF
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
Select what you want in the interactive terminal interface. microG is a FLOSS implementation of Google Play Services, which you don't need in Gapps build. libndk and libhoudini are ARM translation layers. Due to optimizations in the translation layers, It is recommended to use libndk on AMD CPUs and libhoudini on Intel CPUs.

Afterwards, run
```
waydroid session stop
sudo waydroid upgrade --offline
sudo systemctl restart waydroid-container
```

See <https://github.com/casualsnek/waydroid_script> for more information.

#### Google Play Certificate

Run:
```
sudo waydroid shell
```
and then run:
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

Remember to `chmod 770` when copying things to it to be accessible in Waydroid.

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

#### Disable On-Screen Keyboard

Waydroid by default shows the Android virtual keyboard when selecting an input field. To disable that, and only use the physical keyboard, turn off the following setting: `Settings > System > Languages & input > Physical keyboard > Use on-screen keyboard`.

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
