# ubuntu-setup-with-vnc-and-gpu

Scripts and instructions for setting up Ubuntu or Linux Mint with tools for development, productivity, graphics, remote control, gaming, multimedia, communication, and more.

* [`install-tools.sh`](install-tools.sh): Scripts for setting up Ubuntu or Linux Mint with recommended drivers and tools for C/C++, Python3, Java8, Java11, Java17, Java21, Node.js, Rust, Go, Ruby, Perl, .NET, GitHub CLI, GitLab CLI, OpenSSL, OpenSSH, JQ, Ghostscript, FFMPEG, Maven, Zsh, Fcitx5, Flatpak, TeX Live, Pandoc, CopyQ, Tailscale, Noto CJK fonts, XITS fonts, Node.js packages, Python3 packages, pipx, Poetry, RARLAB UnRAR, Fabric, Visual Studio Code, Code::Blocks, PowerShell, ANTLR 4, Steam, Discord, Telegram, Spotify, VLC, OBS Studio, LibreOffice, OnlyOffice, Joplin, Calibre, Postman, GIMP, Krita, HandBrake, MuseScore, Aisleriot Solitaire, custom `~/.profile`, custom `~/.bashrc`, custom `~/.vimrc`, and more.
* [`tigervnc.sh`](tigervnc.sh): Scripts for setting up TigerVNC on Ubuntu or Linux Mint.
* [`virtualgl-turbovnc.sh`](virtualgl-turbovnc.sh): Scripts for setting up VirtualGL and TurboVNC on Ubuntu or Linux Mint, compatible with NVIDIA GPU.
* [`waydroid.sh`](waydroid.sh): Scripts for setting up Waydroid on Ubuntu or Linux Mint.
* [`wine.sh`](wine.sh): Scripts for setting up Wine on Ubuntu or Linux Mint.

## Instructions

### Android Client

See my [**Android-Non-Root**](https://github.com/Willie169/Android-Non-Root).

### Drivers on Linux Mint

You can install drivers (including NVIDIA driver) with `Driver Manager`, a GUI tool, on Linux Mint.

### NVIDIA

<ul>
<li>You can check NVIDIA driver with <code>nvidia-smi</code>.</li>
<li>You can install CUDA Toolkit with:
<pre><code>sudo apt install nvidia-cuda-toolkit -y
</code></pre>
and check it with <code>nvcc --version</code>.
</ul>

### Setup Steam

1. Run `steam` to update and open it.
2. Follow the instructions.
3. Restart Steam.
4. Follow the instructions.
5. Click `Steam` on the menu bar (upper left corner) and click `Settings`.
6. Click `compatibility`.
7. Toggle on `Enable Steam Play for all other titles` if such option exists.
8. Select the Proton engine you want.
9. Restart Steam. 

### Fcitx5

Configure Fcitx5 in `Fcitx Configuration`, a GUI tool.

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
2. `$VERSION_ID` (from `source /etc/os-release`): Add
```
OS_VERSION_ID=$(
if grep -q '^NAME="Linux Mint"' /etc/os-release; then
    inxi -Sx | awk -F': ' '/base/{print $2}' | awk '{print $2}'
else
    source /etc/os-release
    echo $VERSION_ID
fi
)
```
before it and replace it with `$OS_VERSION_ID`.
