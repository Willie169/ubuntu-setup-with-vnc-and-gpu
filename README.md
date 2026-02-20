# ubuntu-setup-with-vnc-and-gpu

Scripts and instructions for setting up Ubuntu derivatives on AMD64 with tools for development, productivity, graphics, remote control, multimedia, communication, and more.

## Main Installation Scripts

### Prerequisites

* Sufficient storage: (calculated on Kubuntu 24.04.3)
  * Kubuntu 24.04.3 Full Installation: approximately 11.3 GB,
  * Plus [`install-tools-first.sh`](install-tools-first.sh): approximately 71.9 GB.
  * Plus [`install-tools-second.sh`](install-tools-second.sh): approximately 72.4 GB.
* Sufficient power supply.
* Stable internet connection.

### Usage 

1. Run [`install-tools-first.sh`](install-tools-first.sh) and follow the prompts until it reboot automatically.
2. Login and run [`install-tools-second.sh`](install-tools-second.sh) until it exits automatically.
2. You can list installed Snap packages with `snap list`. You may want to cleanup remaining Snap packages that you don't need or are already installed from other sources in previous scripts, for example, for Kubuntu 24.04.3 Full Installation, `snap remove element-desktop ffmpeg-2204 firmware-updater krita gnome-42-2204 gnome-46-2404 gtk-common-themes kf5-core22 mesa-2404`.
2. Snap Firefox and Thunderbird are replaced with Deb Firefox and Thunderbird from Mozilla Team PPA, and thus you may want to configure launchers in your Desktop Environment.
2. Run `sudo tailscale up` and to login to Tailscale via the URL shown and click **Connect**. Google, Microsoft, GitHub, Apple, and passkey are available.
2. Run `gh auth login --scopes repo,read:org,admin:org,workflow,gist,notifications,delete_repo,write:packages,read:packages` to login to GitHub.
2. Run `git config --global user.name [your_name] && git config --global user.email [your_email]` to config git.
2. Run `code` or click the **Visual Studio Code** icon to setup Visual Studio Code.
2. Run `codeblocks` or click the **Code::Blocks IDE** icon to setup Code::Blocks.
2. Run `studio` or click the **Android Studio** icon to setup Android Studio. `"system-images;android-33;google_apis_playstore;x86_64" "system-images;android-36.1;google_apis_playstore;x86_64"` installation in [`install-tools-first.sh`](install-tools-first.sh) may fail silently due to network issue, you can download it again via `sdkmanager "system-images;android-33;google_apis_playstore;x86_64" "system-images;android-36.1;google_apis_playstore;x86_64"` or Android Studio GUI.
2. Run `torbrowser-launcher` or click the **Tor Browser** icon to finish installing Tor Browser.
2. Run `steam` to finish installing Steam. Running twice may be required.
2. Run `enteauth` to setup Ente Auth.
2. You can add LizzieYzy to desktop by running `cp ~/.local/share/applications/lizzieyzy.desktop ~/Desktop/lizzieyzy.desktop && chmod +x ~/Desktop/lizzieyzy.desktop`.
2. You can add Cute Chess to desktop by running `cp ~/.local/share/applications/cutechess.desktop ~/Desktop/cutechess.desktop && chmod +x ~/Desktop/cutechess.desktop`.
2. You can add Sylvan to desktop by running `cp ~/.local/share/applications/sylvan.desktop ~/Desktop/sylvan.desktop && chmod +x ~/Desktop/sylvan.desktop`.
2. You may want to pull some Ollama models, e.g., `ollama pull deepseek-coder-v2:16b` (8.9 GB), `ollama pull llama3.2:3b` (2.0 GB), `ollama pull qwen3:4b` (2.5 GB), `ollama pull nomic-embed-text:latest` (274 MB).
2. Go to [Other Scripts](#other-scripts) section for other scripts in this repository.
2. Go to [Instructions](#instructions) section for instructions.

### Content of Main Installation Scripts

Configures dual-boot friendly configurations, installs recommended drivers and tools for C, C++, Python3, Java8, Java17, Java21, Node.js 24 (via NVM), Rust, Go, Ruby, Perl, Fortran, Qt5, .NET SDK 10, ASP.NET Core Runtime 10, Aptitude, GitHub CLI, GitLab CLI, GVim, OpenSSL, OpenSSH, JQ, Ghostscript, GHC Filesystem, FFMPEG, Maven, Zsh, Fcitx5, OpenCL, Flatpak, TeX Live (via regular installation instead of APT, for unrestricted `tlmgr` and updates), Pandoc, Tailscale, aria2, Noto CJK fonts, XITS fonts, nvm, pnpm, Yarn, NPM packages `jsdom markdown-toc marked marked-gfm-heading-id node-html-markdown showdown` locally in `~` and `http-server @openai/codex` globally, Bun, Miniforge, pipx, Poetry, uv, RARLAB UnRAR, Icarus Verilog, Verilator, Ngspice, jpegoptim, optipng, libheif, LibWebP, ImageMagick, Inkscape, XMLStarlet, GTKWave, SDL2, SDL2 BGI, Docker, Aider, Ollama, Open NoteBook (data in `~/.open-notebook`, can be launched by running `open-notebook` and stopped by running `open-notebook-stop`), Open Code, llmfit, Visual Studio Code, Code::Blocks, qBittorrent, Joplin (can be launched by running `joplin-desktop` and updated by running `update_joplin`), Ente Auth, Balena Etcher, Arduino CLI, Arduino IDE (inside `~/.local/arduino-ide` and can be launched with `~/.local/bin/arduino-ide`, which has been added in `PATH` in `.bashrc`), ANTLR 4 (JAR in `/usr/local/java`), Tor, Tor Browser, PlantUML (JAR in `/usr/local/java`), clang-uml, SQLite 3, PostgreSQL 17, Steam, Brisk, Godot .NET version (inside `~/.local/godot/` and symlinked to `~/.local/bin/godot`, which has been added in `PATH` in `.bashrc`), Android Studio (can be launched with desktop entry `/usr/share/applications/android-studio.desktop`), Android Command-line tools, Android SDK `"build-tools;30.0.3" "build-tools;35.0.0" "build-tools;36.1.0" "emulator" "ndk;29.0.14206865" "platform-tools" "platforms;android-33" "platforms;android-36" "sources;android-33" "sources;android-36" "system-images;android-33;google_apis_playstore;x86_64" "system-images;android-36.1;google_apis_playstore;x86_64"`, fdroidserver, Brave Browser, Chromium, Proton Mail, Proton Mail Bridge, Claude Code, Bottles, Discord, OBS Studio, HandBrake, FreeTube, GIMP, Aisleriot Solitaire, Krita, MuseScore, OnlyOffice, VLC, and more, removes Snap, prevents it from being installed, and switches from Snap Firefox and Thunderbird to Deb Firefox and Thunderbird from Mozilla Team PPA, enables unattended upgrade, fixes possible Fcitx5 not working in Firefox from PPA if on Ubuntu without KDE Plasma that is not Linux Mint, and prevents Snap Chromium from being installed if not on Linux Mint, using scripts from my [switch-firefox-from-snap-to-deb](https://github.com/Willie169/switch-firefox-from-snap-to-deb), KataGo (`~/KataGo/cpp/katago` and can be run with `katago`) and KataGo network `kata1-b6c96-s175395328-d26788732` (in `~/katago-networks`, other networks can be downloaded from <https://katagotraining.org/networks>), LizzieYzy (can be launched by running `lizzieyzy` or with desktop entry `~/.local/share/applications/lizzieyzy.desktop`, runtime directory `~/.lizzieyzy`, KataGo network `kata1-b6c96-s175395328-d26788732` configured as default engine and estimate engine in `~/.lizzieyzy/config.txt`, which can be updated by running `update_lizzieyzy_config`), Fairy-Stockfish (`~/Fairy-Stockfish/src/stockfish` and can be run with `stockfish`), Cute Chess (GUI at `~/cutechess/build/cutechess` and can be launched by running `cutechess` or with desktop entry `~/.local/share/applications/cutechess.desktop`, CLI at `~/cutechess/build/cutechess-cli` and can be run with `cutechess-cli`, Fairy-Stockfish configured as engine in `~/.config/cutechess/engines.json`, which can be updated by running `update_cutechess_config`), Sylvan (GUI at `~/Sylvan/projects/gui/sylvan` and can be launched by running `sylvan` or with desktop entry `~/.local/share/applications/sylvan.desktop`, CLI at `~/Sylvan/projects/cli/sylvan-cli` and can be run with `sylvan-cli`, Fairy-Stockfish configured as engine in `~/.config/EterCyber/engines.json`, which can be updated by running `update_sylvan_config`), [my modified version](https://github.com/Willie169/vimrc) of [vimrc by Amir Salihefendic (amix)](https://github.com/amix/vimrc) for both Vim and Neovim (can be updated by running `update_vimrc`), my LaTeX package [`physics-patch`](https://github.com/Willie169/physics-patch) and my LaTeX template [`LaTeX-ToolKit`](https://github.com/Willie169/LaTeX-ToolKit) (can be updated with `update_latex`), and more, and copies `~/.bashrc.d` and `~/.bashrc` from my [**bashrc**](https://github.com/Willie169/bashrc) repo (can be updated by running `update_bashrc`).

## Other Scripts

### [`virtualgl-turbovnc.sh`](virtualgl-turbovnc.sh)

Installs VirtualGL and TurboVNC on Ubuntu derivatives on AMD 64, compatible with NVIDIA GPU.

You may want to use TigerVNC instead if your computer does not have a discrete GPU. See [VirtualGL and TurboVNC](#virtualgl-and-turbovnc) section for what to do after running this script and more information.

### [`waydroid.sh`](waydroid.sh)

Installs Waydroid on Ubuntu derivatives on AMD 64.

See [Waydroid](#waydroid) section for what to do after running this script and more information.

## Instructions

### Table of Contents

+ [Dual Boot with Windows](#dual-boot-with-windows)
+ [Desktop Environment](#desktop-environment)
+ [Wayland](#wayland)
+ [Linux Mint Ubuntu Version Tweak](#linux-mint-ubuntu-version-tweak)
+ [Desktop App Launchers](#desktop-app-launchers)
+ [Fcitx5](#fcitx5)
+ [Tailscale](#tailscale)
+ [OpenSSH](#openssh)
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
<li>Run:
<pre><code>echo "$XDG_SESSION_TYPE"
</code></pre>
If it shows <code>wayland</code>, you are already on Wayland and can skip this instruction. If it shows <code>x11</code> and you want to switch to Wayland, follow this instruction.</li>
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

### VirtualGL and TurboVNC

#### TigerVNC

You may want to use TigerVNC instead if your computer does not have a discrete GPU. It can be installed via:
```
sudo apt install tigervnc-standalone-server -y
```
Its usage is the same as TurboVNC, refer to [VNC Server Usage](#vnc-server-usage) section for it.

#### Prerequisites

<ol>
<li>Run <a href="virtualgl-turbovnc.sh"><code>virtualgl-turbovnc.sh</code></a> first if you have not.</li>
<li>Add <code>export PATH="/opt/TurboVNC/bin:$PATH</code> in <code>~/.bashrc</code>. This has been done in <a href="install-tools-first.sh"><code>install-tools-first.sh</code></a>.</li>
<li>Determine your Desktop Manager and GPU and follow the corresponding section below:
<ul>
<li>GNOME 3, which Ubuntu usually uses, uses GDM.</li>
<li>KDE Plasma, which Kubuntu uses, uses SDDM.</li>
<li>Cinnamon, which Linux Mint usually uses, uses LightDM.</li>
</ul>
See <a href="#desktop-environment">Desktop Environment</a> section for more information.</li>
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

#### VNC Server Usage

* Set password for VNC client to access the VNC server on the computer: `vncpasswd`.
* Start VNC server: `vncserver`.
* List VNC servers: `vncserver -list`.
* Kill VNC server: `vncserver -kill :1`. Replace `:1` with your actual display number.

#### Android as SSH and VNC/X Client

[**AVNC**](https://f-droid.org/packages/com.gaurav.avnc) from F-Droid is suggested if you do not have a client of your choice. See my [**Android-Non-Root**](https://github.com/Willie169/Android-Non-Root) repo for more information.

### Waydroid

Waydroid only runs on Wayland, see [Wayland](#wayland) section for how to switch to Wayland.

#### Install and Network

Done in [`waydroid.sh`](waydroid.sh).

#### Download Android

1. Open Waydroid by running `waydroid` or clicking the **Waydroid** icon.
2. Choose options you want. In `Android Type`, `Vanilla` or `Minimal Android` refers to a pure AOSP (Android Open-Source Project) build without any Google services, while `Gapps` or `Android with Google Apps` refers to a build that provides access to Google services. If you don't know which to select, the `Gapps` or `Android with Google Apps` is recommended, which occupies approximately 1.4 GB.
3. Press `Download`, wait until `Done` button is shown, and press it.

#### Storage

Waydroid's home directory is:
```
~/.local/share/waydroid/data/media/0/
```
This has been exported as `WAYDROID` in `.bashrc` in [`install-tools-first.sh`](install-tools-first.sh).

#### Google Play Certificate

Run:
```
sudo waydroid shell
```
inside Waydroid’s shell, run:
```
ANDROID_RUNTIME_ROOT=/apex/com.android.runtime ANDROID_DATA=/data ANDROID_TZDATA_ROOT=/apex/com.android.tzdata ANDROID_I18N_ROOT=/apex/com.android.i18n sqlite3 /data/data/com.google.android.gsf/databases/gservices.db "select * from main where name = \"android_id\";"
```
Use the string of numbers printed by the command to register the device on your Google Account at <https://www.google.com/android/uncertified>.

Run `exit` inside Waydroid’s shell to exit it.

#### Remove

Run:
```
waydroid session stop
sudo waydroid container stop
sudo apt remove waydroid
sudo reboot
```
after rebooted, run:
```
sudo rm -rf /var/lib/waydroid /home/.waydroid ~/waydroid ~/.share/waydroid ~/.local/share/applications/*aydroid* ~/.local/share/waydroid
```

#### Official Site

Site: <https://waydro.id>
Doc: <https://docs.waydro.id>

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
