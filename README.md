# ubuntu-setup-with-vnc-and-gpu

Scripts and instructions for setting up Ubuntu derivatives on AMD64 with tools for development, productivity, graphics, remote control, gaming, multimedia, communication, and more.

## [`install-tools-first.sh`](install-tools-first.sh) and [`install-tools-second.sh`](install-tools-second.sh)

### Usage 

1. Run [`install-tools-first.sh`](install-tools-first.sh) and follow the prompts until it reboot automatically.
2. Login and run [`install-tools-second.sh`](install-tools-second.sh) until it reboot automatically.
3. See [Tailscale](#tailscale) to configure Tailscale.
4. Done.

### Purpose

Setting up Ubuntu derivatives with installation of recommended drivers and tools for C/C++, Python3, Java8, Java11, Java17, Java21, Node.js, Rust, Go, Ruby, Perl, .NET 9, GitHub CLI, GitLab CLI, OpenSSL, OpenSSH, JQ, Ghostscript, FFMPEG, Maven, Zsh, Fcitx5, Flatpak, TeX Live, Pandoc, Tailscale, Noto CJK fonts, XITS fonts, Node.js packages, Python3 packages, pipx, Poetry, RARLAB UnRAR, Fabric, Visual Studio Code, Code::Blocks, PowerShell, ANTLR 4, 
Discord, Telegram, Spotify, VLC, OBS Studio, LibreOffice, OnlyOffice, Joplin, Postman, GIMP, Krita, HandBrake, MuseScore, Aisleriot Solitaire, Tor, Tor Browser, custom `~/.profile`, custom `~/.bashrc`, custom `~/.vimrc`, CopyQ except on KDE Plasma, switching Firefox and Thunderbird from Snap to PPA except on Linux Mint, and my LaTeX package [`physics-patch`](https://github.com/Willie169/physics-patch) and my LaTeX template [`LaTeX-ToolKit`](https://github.com/Willie169/LaTeX-ToolKit).

## Other Scripts

### [`virtualgl-turbovnc.sh`](virtualgl-turbovnc.sh)

Installs VirtualGL and TurboVNC on Ubuntu derivatives, compatible with NVIDIA GPU. See [#VNC](#vnc) for what to do after running this script.

### [`waydroid.sh`](waydroid.sh)

Installs Waydroid. See [Waydroid](#waydroid) for what to do after running this script.

Waydroid only runs on Wayland, so installing it with a desktop environment that doesn't support Wayland is useless.

- GNOME 3, which Ubuntu usually uses, and KDE Plasma, which Kubuntu uses, support Wayland.
- Cinnamon, which Linux Mint usually uses, doesn't support Wayland currently.

### [`wine.sh`](wine.sh)

Installs Wine.

Can also be run on Debian derivatives.

## Instructions

+ [GRUB](#grub)
+ [Driver Manager in Linux Mint](#driver-manager-in-linux-mint)
+ [NVIDIA](#nvidia)
+ [Time Mismatches When Dual Booting with Windows](#time-mismatches-when-dual-booting-with-windows)
+ [Linux Mint Ubuntu Version Tweak](#linux-mint-ubuntu-version-tweak)
+ [Desktop App Launchers](#desktop-app-launchers)
+ [Fcitx5](#fcitx5)
+ [Tailscale](#tailscale)
+ [VNC](#vnc)
+ [Waydroid](#waydroid)
+ [Solution for Closing Lip Overrides Power Off](#solution-for-closing-lip-overrides-power-off)
+ [Switching Firefox and Thunderbird from Snap to PPA](#switching-firefox-and-thunderbird-from-snap-to-ppa)

### GRUB

#### When Dual Booting with Windows

When dual booting with Windows, you need to:
- Disabe fast boot (in some context also secure boot) in BIOS.
- In some context, `sudo vim /etc/grub.d/30_os_prober` and add or edit line `quick_boot="0"`.
- `sudo vim /etc/default/grub` and add or edit line `GRUB_DISABLE_OS_PROBER=false`.
- `sudo vim /etc/default/grub` and add or edit non-zero `GRUB_TIMEOUT`, when `GRUB_TIMEOUT_STYLE=menu`, or `GRUB_HIDDEN_TIMEOUT`, when otherwise.

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

### Driver Manager in Linux Mint

You can install drivers (including NVIDIA driver) with `Driver Manager`, a GUI tool, on Linux Mint.

### NVIDIA

<ul>
<li>You can check NVIDIA driver with <code>nvidia-smi</code>.</li>
<li>You can install CUDA Toolkit with:
<pre><code>sudo apt install nvidia-cuda-toolkit -y
</code></pre>
and check it with <code>nvcc --version</code>.
</ul>

### Time Mismatches When Dual Booting with Windows

If time mismatches real local time when dual booting with Windows, do the following steps:

<ol>
<li>In Linux, run:
<pre><code>sudo timedatectl set-local-rtc 0
sudo timedatectl set-ntp true
</code></pre></li>
<li>Boot into Windows and sync time in it if time still mismatches after step 1.</li>
</ol>

### Linux Mint Ubuntu Version Tweak

To make a script for Ubuntu work for both Ubuntu and Linux Mint, do the following tweaks:

1. `$(lsb_release -cs)`: Add `source /etc/os-release` before it and replace it with `$UBUNTU_CODENAME`.
2. `$VERSION_ID` (from `/etc/os-release`): Add
```
export UBUNTU_VERSION_ID=$(
if grep -q '^NAME="Linux Mint"' /etc/os-release; then
    inxi -Sx | awk -F': ' '/base/{print $2}' | awk '{print $2}'
else
    . /etc/os-release
    echo "$VERSION_ID"
fi
)
```
before it and replace it with `$UBUNTU_VERSION_ID`. This has been added to `~/.bashrc` in [`install-tools.sh`](install-tools.sh).

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

### Fcitx5

- You can configure Fcitx5 in `Fcitx Configuration`, a GUI tool, on GNOME 3, which Ubuntu usually uses, and Cinnamon, which Linux Mint usually uses.
- You can configure Fcitx5 in `System Settings` > `Input Method`, a GUI tool, on KDE Plasma, which Kubuntu uses.

### Tailscale
#### Log in

```
sudo tailscale up
```

Log in via <https://login.tailscale.com/login>. Google, Microsoft, GitHub, Apple, and passkey are available.

#### Systemd

For Linux distribution with `systemd`, you can:
```
sudo systemctl enable tailscaled
sudo systemctl start tailscaled
```

#### Manually Start Userspace Networking

```
sudo tailscaled --tun=userspace-networking &
```

#### Tailscale IP

Your tailscale ip will be

```
tailscale ip
```

You can connect to it from another device logged in with the same account.

#### Subnet Routing

If you want to access devices on your local network through Tailscale, enable subnet routing

```
sudo tailscale up --advertise-routes=192.168.1.0/24
```

#### Tailscale in Android

Tailscale (`com.tailscale.ipn`) can be installed from [F-Droid](https://f-droid.org/packages/com.tailscale.ipn) or [Google Play](https://play.google.com/store/apps/details?id=com.tailscale.ipn).

You can view the devices logged in and their Tailscale IPs in the app.

See my [**Android-Non-Root**](https://github.com/Willie169/Android-Non-Root) for more information.

### VNC

**Note**:

- GNOME 3, which Ubuntu usually uses, use GDM.
- KDE Plasma, which Kubuntu uses, uses SDDM.
- Cinnamon, which  Linux Mint usually uses, uses LightDM.

#### For All at First

For whatever setup, set your password for VNC client to access the VNC server on this computer first:
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

See my [**Android-Non-Root**](https://github.com/Willie169/Android-Non-Root) for more information.

### Waydroid

Waydroid only runs on Wayland, so installing it with a desktop environment that doesn't support Wayland is useless.

- GNOME 3, which Ubuntu usually uses, and KDE Plasma, which Kubuntu uses, support Wayland.
- Cinnamon, which Linux Mint usually uses, doesn't support Wayland currently.

#### Official Site

Site: <https://waydro.id>.
Doc: <https://docs.waydro.id>.

#### Install

This has been done in [`waydroid-ubuntu.sh`](waydroid-ubuntu.sh).

```
sudo apt install curl ca-certificates -y
curl -s https://repo.waydro.id | sudo bash
sudo apt install waydroid -y
```

#### Enable Wayland for GNOME3 (GDM)

<ol>
<li>Method 1:

Run:
<pre><code>sudo vim /etc/gdm3/custom.conf
</code></pre>
Add or change:
<pre><code>WaylandEnable=true
</code></pre>
And then run:
<pre><code>sudo systemctl restart gdm3
</code></pre></li>
<li>Method 2:
<ol>
<li>Log out.</li>
<li>In the down right corner of the login page, choose `Ubuntu on Wayland`.</li>
<li>Login.</li>
</ol>
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
<pre><code>sudo apt install libnvidia-egl-wayland1 plasma-workspace-wayland -y
echo options nvidia_drm modeset=1 | sudo tee /etc/modprobe.d/nvidia_drm.conf
sudo update-initramfs -u
</code></pre>
<li>Log out.</li>
<li>In the down left corner of the login page, choose `Plasma (Wayland)`.</li>
<li>Login.</li>
</ol>

#### Download Android

1. Open Waydroid from application menu. 
2. Choose options you want. In `Android Type`, `Vanilla` refers to a pure AOSP (Android Open-Source Project) build without any Google services, while `Gapps` refers to a build that provides access to Google services.
3. Press `Download`, wait until `Done` button is shown, and press it.

#### Network

This has been done in [`waydroid-ubuntu.sh`](waydroid-ubuntu.sh).

To allow network access in Waydroid, run:
```
sudo ufw allow 53
sudo ufw allow 67
sudo ufw default allow FORWARD
```

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
Add or change:
```
HandleLidSwitch=ignore
HandleLidSwitchDocked=ignore
HandleLidSwitchExternalPower=ignore
```
And then run:
```
sudo systemctl restart systemd-logind
```
Test it.

### Switching Firefox and Thunderbird from Snap to PPA

Ignore this if you are on Linux Mint, which does not use Snap.

This has been done in [`install-tools.sh`](install-tools.sh).

#### Script for Firefox

```
if ! grep -q '^NAME="Linux Mint"' /etc/os-release; then
    sudo add-apt-repository ppa:mozillateam/ppa -y
    echo 'Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: *
Pin: release o=Ubuntu
Pin-Priority: -1' | sudo tee /etc/apt/preferences.d/mozilla-firefox
    sudo rm -f /etc/apparmor.d/usr.bin.firefox
    sudo rm -f /etc/apparmor.d/local/usr.bin.firefox
    sudo systemctl stop var-snap-firefox-common-*.mount 2>/dev/null || true
    sudo systemctl disable var-snap-firefox-common-*.mount 2>/dev/null || true
    sudo snap remove --purge firefox || true
    sudo apt install firefox -y
    echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:$(lsb_release -cs)";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox
fi
```

#### Script for Thunderbird

```
if ! grep -q '^NAME="Linux Mint"' /etc/os-release; then
    sudo add-apt-repository ppa:mozillateam/ppa -y
    echo 'Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: *
Pin: release o=Ubuntu
Pin-Priority: -1' | sudo tee /etc/apt/preferences.d/mozilla-firefox
    sudo rm -f /etc/apparmor.d/usr.bin.thunderbird
    sudo rm -f /etc/apparmor.d/local/usr.bin.thunderbird
    sudo systemctl stop var-snap-thunderbird-common-*.mount 2>/dev/null || true
    sudo systemctl disable var-snap-thunderbird-common-*.mount 2>/dev/null || true
    sudo snap remove --purge thunderbird || true
    sudo apt install thunderbird -y
    echo "Unattended-Upgrade::Allowed-Origins:: \"LP-PPA-mozillateam:$(lsb_release -cs)\";" | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-thunderbird
fi
```

#### Sources

- Archisman Panigrahi, igi, Organic Marble, eddygeek, Yogev Neumann, & OMG Ubuntu (2024). How to install Firefox as a traditional deb package (without snap) in Ubuntu 22.04 or later versions? [https://askubuntu.com/questions/1399383/how-to-install-firefox-as-a-traditional-deb-package-without-snap-in-ubuntu-22](https://askubuntu.com/questions/1399383/how-to-install-firefox-as-a-traditional-deb-package-without-snap-in-ubuntu-22).
- Archisman Panigrahi & BeastOfCaerbannog (2024). How to install Thunderbird as a traditional deb package without snap in Ubuntu 24.04 and later versions? [https://askubuntu.com/questions/1513445/how-to-install-thunderbird-as-a-traditional-deb-package-without-snap-in-ubuntu-2](https://askubuntu.com/questions/1513445/how-to-install-thunderbird-as-a-traditional-deb-package-without-snap-in-ubuntu-2).
