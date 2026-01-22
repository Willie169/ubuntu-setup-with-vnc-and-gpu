# ubuntu-setup-with-vnc-and-gpu

Scripts and instructions for setting up Ubuntu derivatives on AMD64 with tools for development, productivity, graphics, remote control, multimedia, communication, and more.

## Main Installation Scripts

### Prerequisites

* Sufficient storage: (calculated on Kubuntu 24.04.3)
  * Kubuntu 24.04.3 Full Installation: approximately 11.3 GB,
  * Plus [`install-tools-first.sh`](install-tools-first.sh): approximately 50.9 GB.
  * Plus [`install-tools-second.sh`](install-tools-second.sh): approximately 60.8 GB.
* Sufficient power supply.
* Stable internet connection.

### Usage 

1. Run [`install-tools-first.sh`](install-tools-first.sh) and follow the prompts until it reboot automatically.
2. Login and run [`install-tools-second.sh`](install-tools-second.sh) until it exits automatically.
2. You can list installed Snap packages with `snap list`. You may want to cleanup remaining Snap packages that are already installed from other sources, for example, for Kubuntu 24.04.3 Full Installation, `snap remove element-desktop ffmpeg-2204 firmware-updater krita gnome-42-2204 gnome-46-2404 gtk-common-themes kf5-core22 mesa-2404`.
2. Snap Firefox is replaced with `.deb` Firefox ESR. Thus launchers you may want to configure launchers in your Desktop Environment.
2. Run `sudo tailscale up` and to login to Tailscale via the URL shown and click **Connect**. Google, Microsoft, GitHub, Apple, and passkey are available.
2. Run `gh auth login --scopes repo,read:org,admin:org,workflow,gist,notifications,delete_repo,write:packages,read:packages` to login to GitHub.
2. Run `git config --global user.name [your_name] && git config --global user.email [your_email]` to config git.
2. Run `code` or click the **Visual Studio Code** icon to setup Visual Studio Code.
2. Run `codeblocks` or click the **Code::Blocks IDE** icon to setup Code::Blocks.
2. Run `studio` or click the **Android Studio** icon to setup Android Studio. `"system-images;android-33;google_apis_playstore;x86_64" "system-images;android-36.1;google_apis_playstore;x86_64"` installation in [`install-tools-first.sh`](install-tools-first.sh) may fail silently due to network issue, you can download it again via `sdkmanager "system-images;android-33;google_apis_playstore;x86_64" "system-images;android-36.1;google_apis_playstore;x86_64"` or Android Studio GUI.
2. Run `torbrowser-launcher` or click the **Tor Browser** icon to finish installing Tor Browser.
2. Run `steam` to finish installing Steam. Running twice may be required.
2. Run `enteauth` to setup Ente Auth.
2. Go to [Other Scripts](#other-scripts) section for other scripts in this repository.
2. Go to [Instructions](#instructions) section for instructions.

### Content of Main Installation Scripts

Installs recommended drivers and tools for C, C++, COBOL, Python3, Java8, Java11, Java17, Java21, Node.js 24 (via NVM), Rust, Go, Ruby, Perl, Fortran, .NET SDK 10, ASP.NET Core Runtime 10, Aptitude, GitHub CLI, GitLab CLI, GVim, OpenSSL, OpenSSH, JQ, Ghostscript, FFMPEG, Maven, Zsh, Fcitx5, Flatpak, TeX Live (via regular installation instead of APT, for unrestricted `tlmgr` and updates), Pandoc, Tailscale, aria2, Noto CJK fonts, XITS fonts, nvm, pnpm, Yarn, NPM packages `http-server jsdom marked marked-gfm-heading-id node-html-markdown showdown @openai/codex`, Miniforge, pipx, Poetry, uv, RARLAB UnRAR, Icarus Verilog, Verilator, Ngspice, jpegoptim, optipng, libheif, Inkscape, XMLStarlet, GTKWave, SDL2, SDL2 BGI, Fabric, Visual Studio Code, Code::Blocks, qBittorrent, Joplin (can be launched with `joplin-desktop`), Joplin Terminal Application, Ente Auth, Balena Etcher, Arduino CLI, Arduino IDE (inside `~/.local/arduino-ide` and can be launched with `~/.local/bin/arduino-ide`, which has been added in `PATH` in `.bashrc`), ANTLR 4 (JAR in `/usr/local/java`), Tor, Tor Browser, PlantUML (JAR in `/usr/local/java`), clang-uml, PostgreSQL 17, Steam, Brisk, Godot .NET version (inside `~/.local/godot/` and symlinked to `~/.local/bin/godot`, which has been added in `PATH` in `.bashrc`), Android Studio (with desktop entry `/usr/share/applications/android-studio.desktop`), Android Command-line tools, Android SDK `"build-tools;30.0.3" "build-tools;35.0.0" "build-tools;36.1.0" "emulator" "ndk;29.0.14206865" "platform-tools" "platforms;android-33" "platforms;android-36" "sources;android-33" "sources;android-36" "system-images;android-33;google_apis_playstore;x86_64" "system-images;android-36.1;google_apis_playstore;x86_64"`, fdroidserver, [my modified version](https://github.com/Willie169/vimrc) of [vimrc by Amir Salihefendic (amix)](https://github.com/amix/vimrc) for both Vim and Neovim, my LaTeX package [`physics-patch`](https://github.com/Willie169/physics-patch), my LaTeX template [`LaTeX-ToolKit`](https://github.com/Willie169/LaTeX-ToolKit), Chromium, Bottles, Discord, OBS Studio, Spotify, HandBrake, FreeTube, GIMP, Aisleriot Solitaire, Krita, MuseScore, OnlyOffice, Telegram, VLC, and more, removes Snap, prevents it from being installed, installs Deb Firefox ESR and Thunderbird from Mozilla Team PPA, enables unattended upgrade, and fixes possible Fcitx5 not working in Firefox from PPA if on Ubuntu with KDE Plasma that is not Linux Mint, and switches from Snap Firefox and Thunderbird to Deb Firefox ESR and Thunderbird from Mozilla Team PPA, enables unattended upgrade, fixes possible Fcitx5 not working in Firefox from PPA if on Ubuntu without KDE Plasma that is not Linux Mint, and prevents Snap Chromium from being installed if not on Linux Mint, using scripts from my [switch-firefox-from-snap-to-deb](https://github.com/Willie169/switch-firefox-from-snap-to-deb), configures dual-boot friendly configurations, and copies `~/.bashrc.d` and `~/.bashrc` from my [**bashrc**](https://github.com/Willie169/bashrc) repo.

## Other Scripts

### [`virtualgl-turbovnc.sh`](virtualgl-turbovnc.sh)

Installs VirtualGL and TurboVNC on Ubuntu derivatives on AMD 64, compatible with NVIDIA GPU. See [#VNC](#vnc) section for what to do after running this script.

### [`waydroid.sh`](waydroid.sh)

Installs Waydroid on Ubuntu derivatives on AMD 64.

Waydroid only runs on Wayland.

See [Waydroid](#waydroid) section for what to do after running this script.

## Instructions

### Table of Contents

+ [Dual Boot with Windows](#dual-boot-with-windows)
+ [Desktop Environment](#desktop-environment)
+ [Wayland](#wayland)
+ [Linux Mint Ubuntu Version Tweak](#linux-mint-ubuntu-version-tweak)
+ [Desktop App Launchers](#desktop-app-launchers)
+ [Fcitx5](#fcitx5)
+ [Tailscale](#tailscale)
+ [VNC](#vnc)
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

#### Introduction

Run:
```
echo "$XDG_SESSION_TYPE"
```
If it shows `wayland`, you are already on Wayland and can skip this instruction. If it shows `x11` and you want to switch to Wayland, follow this instruction.

First determine your Desktop Environment:

- GNOME 3, which Ubuntu usually uses, supports Wayland.
- KDE Plasma, which Kubuntu uses, supports Wayland.
- Cinnamon, which Linux Mint usually uses, doesn't fully support Wayland currently. This instruction does not cover how to switch to Wayland on Cinnamon. Sorry.

See [Desktop Environment](#desktop-environment) section for more information.

#### Enable Wayland for GNOME3 (GDM)

<ol>
<li>Log out.</li>
<li>In the down right corner of the login page, choose <code>Ubuntu on Wayland</code>.</li>
</ol>

#### Enable Wayland for KDE Plasma (SDDM)

Log out. In the down left corner of the login page, choose `Plasma (Wayland)` if such an option exists. Otherwise, if with an NVIDIA GPU, follow the instructions below:

<ol>
<li>Run:
<pre><code>sudo apt install libnvidia-egl-wayland1 -y
</code></pre>
<li>Run:
<pre><code>sudo vim /etc/default/grub
</code></pre>
change the line to:
<pre><code>GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia_drm.modeset=1"
</code></pre></li>
<li>Run:
<pre><code>sudo update-grub
sudo update-initramfs -u
</code></pre></li>
<li>Shut down the computer.</li>
<li>Boot the computer.</li>
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
cp /usr/share/applications/<application_name>.desktop ~/Desktop/`
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

1. It may automatically detect `Fcitx5`, if not go to `System Settings` > `Input & Output` or `Keyboard` > `Virtual Keyboard`, then select `Fcitx5`.
2. You can configure Fcitx5 input methods in `Fcitx Configuration`, which can be launched by either right-clicking the keyboard icon at the bottom right corner of the `Task Manager` and clicking `Configure` or going to `System Settings` and searching `Input Method`.

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

### VNC

- GNOME 3, which Ubuntu usually uses, uses GDM.
- KDE Plasma, which Kubuntu uses, uses SDDM.
- Cinnamon, which Linux Mint usually uses, uses LightDM.

See [Desktop Environment](#desktop-environment) section for more information.

#### Password

Set your password for VNC client to access the VNC server on the computer:
```
vncpasswd
```

#### For GDM with Nvidia

<ol>
<li>In tty or from SSH client, run:
<pre><code>sudo systemctl stop gdm
sudo modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia || true
sudo systemctl start gdm
</code></pre></li>
<li>Re-login into your computer.</li>
<li>Run:
<pre><code>vglrun glxinfo
</code></pre></li>
</ol>

#### For SDDM with Nvidia

<ol>
<li>In tty or from SSH client, run:
<pre><code>sudo systemctl stop sddm
sudo modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia || true
sudo systemctl start sddm
</code></pre></li>
<li>Re-login into your computer.</li>
<li>Run:
<pre><code>vglrun glxinfo
</code></pre></li>
</ol>

#### For LightDM with Nvidia

<ol>
<li>In tty or from SSH client, run:
<pre><code>sudo systemctl stop lightdm
sudo modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia || true
sudo systemctl start lightdm
</code></pre></li>
<li>Re-login into your computer.</li>
<li>Run:
<pre><code>vglrun glxinfo
</code></pre></li>
</ol>

#### For GDM without GPU

<ol>
<li>In tty or from SSH client, run:
<pre><code>sudo systemctl stop gdm
sudo systemctl start gdm
</code></pre></li>
<li>Re-login into your computer.</li>
<li>Run:
<pre><code>vglrun glxinfo
</code></pre></li>
</ol>

#### For SDDM without GPU

<ol>
<li>In tty or from SSH client, run:
<pre><code>sudo systemctl stop sddm
sudo systemctl start sddm
</code></pre></li>
<li>Re-login into your computer.</li>
<li>Run:
<pre><code>vglrun glxinfo
</code></pre></li>
</ol>

#### For LightDM without GPU

<ol>
<li>In tty or from SSH client, run:
<pre><code>sudo systemctl stop lightdm
sudo systemctl start lightdm
</code></pre></li>
<li>Re-login into your computer.</li>
<li>Run:
<pre><code>vglrun glxinfo
</code></pre></li>
</ol>

#### VNC Server Usage

Add `alias vncserver="/opt/TurboVNC/bin/vncserver"` in `~/.bashrc` before using it, which has been done in [`install-tools-first.sh`](install-tools-first.sh).

* Start VNC server: `vncserver`.
* List VNC servers: `vncserver -list`.
* Kill VNC server: `vncserver -kill :1`. Replace `:1` with your actual display number.

#### Android as SSH and VNC/X Client

See my [**Android-Non-Root**](https://github.com/Willie169/Android-Non-Root) repo for more information.

### Waydroid

Waydroid only runs on Wayland, see [Wayland](#wayland) section for more information.

#### Official Site

Site: <https://waydro.id>.
Doc: <https://docs.waydro.id>.

#### Install and Network

See [`waydroid.sh`](waydroid.sh).

#### Download Android

1. Open Waydroid from application menu. 
2. Choose options you want. In `Android Type`, `Vanilla` refers to a pure AOSP (Android Open-Source Project) build without any Google services, while `Gapps` refers to a build that provides access to Google services.
3. Press `Download`, wait until `Done` button is shown, and press it.

#### Storage

Waydroid's home directory is:
```
~/.local/share/waydroid/data/media/0/
```

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
