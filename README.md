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

### Enable Proton Engine on Steam

* Open Steam and click `Steam` on the menu bar (upper left corner) and click `Settings`.
* Click `compatibility`.
* Toggle on `Enable Steam Play for all other titles`.
* In `Run other titles with:`, select the option you want. The default is `Proton Hotfix`.
* Reboot.

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
