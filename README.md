# ubuntu-setup-with-vnc-and-gpu

Scripts and instructions for setting up Ubuntu derivatives on AMD64 with tools for development, productivity, graphics, remote control, multimedia, communication, and more.

## Main Installation Scripts

### Prerequisites

* Sufficient storage and power.
* Internet connection.

### Usage 

1. Run [`install-tools-first.sh`](install-tools-first.sh) and follow the prompts until it reboot automatically.
2. Login and run [`install-tools-second.sh`](install-tools-second.sh) until it reboot automatically.
3. See [Fcitx5](#fcitx5) section to configure Fcitx5.
4. See [Desktop Environment](#desktop-environment) section and [Wayland](#wayland) section if you want to use Wayland.
5. See [Tailscale](#tailscale) section to configure Tailscale.
6. Done.

### Content

Installs recommended drivers and tools for C/C++, Python3, Java8, Java11, Java17, Java21, Node.js, Rust, Go, Ruby, Perl, .NET 9, Aptitude, GitHub CLI, GitLab CLI, OpenSSL, OpenSSH, JQ, Ghostscript, FFMPEG, Maven, Zsh, Fcitx5, Flatpak, TeX Live, Pandoc, Tailscale, Noto CJK fonts, XITS fonts, Node.js packages, Python3 packages, pipx, Poetry, RARLAB UnRAR, Icarus Verilog, Verilator, Fabric, Visual Studio Code, Code::Blocks, PowerShell, ANTLR 4, Discord, Telegram, Spotify, VLC, OBS Studio, LibreOffice, OnlyOffice, Joplin, Postman, GIMP, Krita, HandBrake, MuseScore, Aisleriot Solitaire, Tor, Tor Browser, CopyQ except on KDE Plasma, my [switch-firefox-from-snap-to-deb](https://github.com/Willie169/switch-firefox-from-snap-to-deb) except on Linux Mint, [vimrc by Amir Salihefendic (amix)](https://github.com/amix/vimrc) with `set mouse=a` customization, my LaTeX package [`physics-patch`](https://github.com/Willie169/physics-patch), my LaTeX template [`LaTeX-ToolKit`](https://github.com/Willie169/LaTeX-ToolKit), and more, adds custom `~/.profile` and `~/.bashrc`, and addes Debian Trixie APT sources with `Pin-Priority: 1`.

## Other Scripts

### [`virtualgl-turbovnc.sh`](virtualgl-turbovnc.sh)

Installs VirtualGL and TurboVNC on Ubuntu derivatives on AMD 64, compatible with NVIDIA GPU. See [#VNC](#vnc) section for what to do after running this script.

### [`waydroid.sh`](waydroid.sh)

Installs Waydroid on Ubuntu derivatives on AMD 64.

Waydroid only runs on Wayland.

See [Waydroid](#waydroid) section for what to do after running this script.

See [Desktop Environment](#desktop-environment), [Wayland](#wayland), and [Waydroid](#waydroid) sections for more information.

### [`wine.sh`](wine.sh)

Installs Wine on Debian derivatives on AMD 64.

This script is not acitvely maintained. Please see [https://www.winehq.org](https://www.winehq.org) for latest installation methods.

## Instructions

+ [Desktop Environment](#desktop-environment)
+ [GRUB](#grub)
+ [Wayland](#wayland)
+ [Time Mismatches When Dual Booting with Windows](#time-mismatches-when-dual-booting-with-windows)
+ [Linux Mint Ubuntu Version Tweak](#linux-mint-ubuntu-version-tweak)
+ [Desktop App Launchers](#desktop-app-launchers)
+ [Fcitx5](#fcitx5)
+ [Tailscale](#tailscale)
+ [VNC](#vnc)
+ [Waydroid](#waydroid)
+ [Solution for Closing Lip Overrides Power Off](#solution-for-closing-lip-overrides-power-off)

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

### GRUB
#### When Dual Booting with Windows

When dual booting with Windows, you need to:
- Disabe fast boot (in some context also secure boot) in BIOS.
- In some context, `sudo vim /etc/grub.d/30_os_prober` and add or edit line `quick_boot="0"`.
- `sudo vim /etc/default/grub` and add or change the line to `GRUB_DISABLE_OS_PROBER=false`.
- `sudo vim /etc/default/grub` and add or change to a non-zero `GRUB_TIMEOUT`, when `GRUB_TIMEOUT_STYLE=menu`, or `GRUB_HIDDEN_TIMEOUT`, when otherwise.

#### GRUB Menu

- When `GRUB_TIMEOUT_STYLE=menu`, after `GRUB_TIMEOUT`, highlighted option will be booted.
- When `GRUB_TIMEOUT_STYLE=hidden` or `GRUB_TIMEOUT_STYLE=countdown`, during `GRUB_HIDDEN_TIMEOUT`, press `ESC` to enter GRUB menu.
- In menu, default highlighted option is the default option. 

#### GRUB Configuration

```
sudo vim /etc/default/grub
``` 

to edit configuration, 

```
sudo update-grub
sudo reboot
```

to apply.

Variables:

- `GRUB_DEFAULT=<number>`: Default boot option to boot. Options and their numbers are showed in GRUB menu.
- `GRUB_TIMEOUT_STYLE=<string>`: GRUB timeout style when booting.
  - `menu`: Show menu, wait until `GRUB_TIMEOUT` ends, and boot default option.
  - `hidden`: Hide menu with black screen, wait until `GRUB_HIDDEN_TIMEOUT` ends, and boot highlighted option. Show menu when `ESC` is pressed during `GRUB_HIDDEN_TIMEOUT`.
  - `countdown`: Hide menu with countdown shown on screen, wait until `GRUB_HIDDEN_TIMEOUT` ends, and boot default option. Show menu when `ESC` is pressed during `GRUB_HIDDEN_TIMEOUT`.
- `GRUB_TIMEOUT=<number>`: When `GRUB_TIMEOUT_STYLE=menu`, the timeout before booting into highlighted option, `-1` for forever. Some versions may need `0.0` for `0`.
- `GRUB_HIDDEN_TIMEOUT=<number>`: When `GRUB_TIMEOUT_STYLE=hidden` or `GRUB_TIMEOUT_STYLE=countdown`, the timeout before booting into the default option. Some versions may need `0.0` for `0`.
- `GRUB_HIDDEN_TIMEOUT_QUIET=<boolean>`: DEPRECATED. `GRUB_TIMEOUT_STYLE=hidden` and `GRUB_HIDDEN_TIMEOUT_QUIET=false` is equivalent to `GRUB_TIMEOUT_STYLE=countdown`; `GRUB_TIMEOUT_STYLE=hidden` and `GRUB_HIDDEN_TIMEOUT_QUIET=true` is equivalent to `GRUB_TIMEOUT_STYLE=hidden`. There's a known bug that make this not work as expected in some versions after this is deprecated.
- `GRUB_DISABLE_OS_PROBER=<boolean>`: Whether to disable OS prober. Set it to `false` when dual booting.

### Wayland

- GNOME 3, which Ubuntu usually uses, and KDE Plasma, which Kubuntu uses, support Wayland.
- Cinnamon, which Linux Mint usually uses, doesn't fully support Wayland currently.

#### Enable Wayland for GNOME3 (GDM)

<ol>
<li>Log out.</li>
<li>In the down right corner of the login page, choose `Ubuntu on Wayland`.</li>
<li>Login.</li>
</ol>

### Enable Wayland for KDE Plasma (SDDM) without NVIDIA

<ol>
<li>Log out.</li>
<li>In the down left corner of the login page, choose `Plasma (Wayland)`.</li>
<li>Login.</li>
</ol>

### Enable Wayland for KDE Plasma (SDDM) with NVIDIA

<ol>
<li>Run:
<pre><code>sudo apt install libnvidia-egl-wayland1 -y
</code></pre>
<li>Run:
<pre><code>sudo nano /etc/default/grub
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
<li>In the down left corner of the login page, choose `Plasma (Wayland)`.</li>
<li>Login.</li>
</ol>

### Time Mismatches When Dual Booting with Windows

If time mismatches real local time when dual booting with Windows, do the following steps:

<ol>
<li>In Linux, run:
<pre><code>sudo timedatectl set-local-rtc 1
</code></pre></li>
<li>Boot into Windows and sync time by clicking <code>Settings</code> > <code>Time & language</code> > <code>Date & time</code> > <code>Sync now</code>.</li>
</ol>

### Linux Mint Ubuntu Version Tweak

To make a script for Ubuntu work for both Ubuntu and Linux Mint, do the following tweaks:

<ol>
<li><code>$(lsb_release -cs)</code>: Add <code>source /etc/os-release</code> before it and replace it with <code>$UBUNTU_CODENAME</code>.</li>
<li><code>$VERSION_ID</code> (from <code>/etc/os-release</code>): Add
<pre><code>export UBUNTU_VERSION_ID=$(
if grep -q '^NAME="Linux Mint"' /etc/os-release; then
    inxi -Sx | awk -F': ' '/base/{print $2}' | awk '{print $2}'
else
    . /etc/os-release
    echo "$VERSION_ID"
fi
)
</code></pre>
before it and replace it with <code>$UBUNTU_VERSION_ID</code>. This has been added to <code>~/.bashrc</code> in <a href="install-tools-first.sh"><code>install-tools-first.sh</code></a>.</li>
</ol>

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

1. Go to `System Settings` > `Input Devices` > `Virtual Keyboard`, select `Fcitx5`, and apply.
2. You can configure Fcitx5 input methods in `System Settings` > `Input Method`.

### Tailscale
#### Install

Below script has been included in [`install-tools-first.sh`](install-tools-first.sh).
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

Log in via <https://login.tailscale.com/login>. Google, Microsoft, GitHub, Apple, and passkey are available.

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

Add `alias vncserver="/opt/TurboVNC/bin/vncserver"` in `~/.bashrc` before using it, which has been done in [`virtualgl-turbovnc.sh`](virtualgl-turbovnc.sh).

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

## License

This repository is licensed under GNU General Public License General Public License, see [LICENSE.md](LICENSE.md) for details.

## TODO

Count storage required for [Main Installation Scripts](#main-installation-scripts).
