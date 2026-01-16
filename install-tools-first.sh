#!/bin/bash
set -eu
cd ~
sudo -v
while true; do sudo -v; sleep 60; done & SUDOPID=$!

export UBUNTU_VERSION_ID=$(
if grep -q '^NAME="Linux Mint"' /etc/os-release; then
    inxi -Sx | awk -F': ' '/base/{print $2}' | awk '{print $2}'
else
    . /etc/os-release
    echo "$VERSION_ID"
fi
)

dl() {
  local has_option=0
  local out=
  local quiet=0
  local verbose=0
  local url=
  local to_stdout=0
  local no_fallback=0
  local use_aria2=1
  local use_curl=1
  local use_wget=1
  local tmp_file
  if [ -z "$TMPDIR" ]; then
    tmp_file=$(mktemp "/tmp/dl.XXXXXXXXXX") || return 1
  else
    tmp_file=$(mktemp "$TMPDIR/dl.XXXXXXXXXX") || return 1
  fi
  local old_exit old_int old_term
  old_exit=$(trap -p EXIT)
  old_int=$(trap -p INT)
  old_term=$(trap -p TERM)

  set -- ${DLFLAGS:-} "$@"

  while [ $# -gt 0 ]; do
    case "$1" in
      -o|--output)
        out="$2"
        shift 2
        ;;
      -O|--stdout)
        to_stdout=1
        shift
        ;;
      -q|--quiet)
        quiet=1
        shift
        ;;
      -v|--verbose)
        verbose=1
        shift
        ;;
      -a|--aria2)
        use_aria2=1; use_curl=0; use_wget=0
        shift
        ;;
      -A|--no-aria2)
        use_aria2=0
        shift
        ;;
      -c|--curl)
        use_curl=1; use_aria2=0; use_wget=0
        shift
        ;;
      -C|--no-curl)
        use_curl=0
        shift
        ;;
      -w|--wget)
        use_wget=1; use_aria2=0; use_curl=0
        shift
        ;;
      -W|--no-wget)
        use_wget=0
        shift
        ;;
      --no-fallback)
        no_fallback=1
        shift
        ;;
      --)
        shift
        break
        ;;
      -*)
        echo "Unknown option: $1" >&2
        echo "Usage: dl [-o|--output FILE] [-q|--quiet] [-v|--verbose] [-a|--aria2] [-A|--no-aria2] [-c|--curl] [-C|--no-curl] [-w|--wget] [-W|--no-wget] [--no-fallback] URL" >&2
        return 2
        ;;
      *)
        url="$1"
        shift
        ;;
    esac
  done

  [ "$quiet" -eq 1 ] && verbose=0

  if [ -z "$url" ]; then
    echo "Usage: dl [-o|--output FILE] [-q|--quiet] [-v|--verbose] [-a|--aria2] [-A|--no-aria2] [-c|--curl] [-C|--no-curl] [-w|--wget] [-W|--no-wget] [--no-fallback] URL" >&2
    return 2
  fi

  if [ -n "$out" ] && [ "$to_stdout" -eq 0 ]; then
    mkdir -p "$(dirname "$out")" || return 1
  fi

  cleanup() {
    [ -n "$tmp_file" ] && rm -f "$tmp_file"
  }

  if [ "$to_stdout" -eq 1 ] && [ "$use_aria2" -eq 1 ]; then
    trap cleanup EXIT INT TERM
  fi

  try_aria2() {
    command -v aria2c >/dev/null 2>&1 || return 127
    local opts=()
    [ "$quiet" -eq 1 ] && opts+=(-q)
    [ "$verbose" -eq 1 ] && opts+=(-v)

    if [ "$to_stdout" -eq 1 ]; then
      aria2c "${opts[@]}" -c -o "$tmp_file" "$url"
    elif [ -n "$out" ]; then
      aria2c "${opts[@]}" -c -o "$out" "$url"
    else
      aria2c "${opts[@]}" -c "$url"
    fi
  }

  try_curl() {
    command -v curl >/dev/null 2>&1 || return 127
    local opts=(-fL)
    [ "$quiet" -eq 1 ] && opts+=(-sS)
    [ "$verbose" -eq 1 ] && opts+=(-v)

    if [ "$to_stdout" -eq 1 ]; then
      curl "${opts[@]}" "$url"
    elif [ -n "$out" ]; then
      curl "${opts[@]}" -o "$out" "$url"
    else
      curl "${opts[@]}" -O "$url"
    fi
  }

  try_wget() {
    command -v wget >/dev/null 2>&1 || return 127
    local opts=()
    [ "$quiet" -eq 1 ] && opts+=(-q)
    [ "$verbose" -eq 1 ] && opts+=(-v)

    if [ "$to_stdout" -eq 1 ]; then
      wget "${opts[@]}" -O - "$url"
    elif [ -n "$out" ]; then
      wget "${opts[@]}" -O "$out" "$url"
    else
      wget "${opts[@]}" "$url"
    fi
  }

  local rc=1

  if [ "$use_aria2" -eq 1 ]; then
    if try_aria2; then
      if [ "$to_stdout" -eq 1 ]; then
        cat "$tmp_file" || return 1
      fi
      [ "$verbose" -eq 1 ] && echo "aria2 used"
      return 0
    fi
    rc=$?
    rm -f "$tmp_file"
    trap - EXIT INT TERM
    [ -n "$old_exit" ] && eval "$old_exit"
    [ -n "$old_int" ]  && eval "$old_int"
    [ -n "$old_term" ] && eval "$old_term"
    [ "$no_fallback" -eq 1 ] && return "$rc"
  fi

  if [ "$use_curl" -eq 1 ]; then
    if try_curl; then
      [ "$verbose" -eq 1 ] && echo "curl used"
      return 0
    fi
    rc=$?
    [ "$no_fallback" -eq 1 ] && return "$rc"
  fi

  if [ "$use_wget" -eq 1 ]; then
    if try_wget; then
      [ "$verbose" -eq 1 ] && echo "wget used"
      return 0
    fi
    rc=$?
    [ "$no_fallback" -eq 1 ] && return "$rc"
  fi

  echo "Error: all enabled downloaders failed" >&2
  return "$rc"
}

gh-latest() {
  local dl_args=()
  local quiet=0
  local verbose=0
  local repo=""
  local file=""
  local name=""
  local tag=""
  local index=""

  while [ $# -gt 0 ]; do
    case "$1" in
      -q|--quiet)
        quiet=1
        dl_args+=("$1")
        shift
        ;;
      -v|--verbose)
        verbose=1
        dl_args+=("$1")
        shift
        ;;
      -n|--name)
        name="$2"
        shift 2
        ;;
      -t|--tag)
        tag="$2"
        shift 2
        ;;
      -i|--index)
        index="$2"
        shift 2
        ;;
      -o|--output|--stdout|-a|--aria2|-A|--no-aria2|-c|--curl|-C|--no-curl|-w|--wget|-W|--no-wget|--no-fallback)
        dl_args+=("$1")
        if [[ "$1" == -o || "$1" == --output ]]; then
          dl_args+=("$2")
          shift
        fi
        shift
        ;;
      -*)
        echo "Unknown option: $1" >&2
        echo "Usage: gh-latest [-n|--name NAME] [-t|--tag TAG_NAME] [-i|--index N] [-o|--output FILE] [-q|--quiet] [-v|--verbose] [-a|--aria2] [-A|--no-aria2] [-c|--curl] [-C|--no-curl] [-w|--wget] [-W|--no-wget] [--no-fallback] <repo> [file-pattern]" >&2
        echo "Example: gh-latest cli/cli *.deb" >&2
        echo "Example: gh-latest https://github.com/cli/cli/ gh_*_linux_amd64.deb" >&2
        echo "Example: gh-latest github.com/cli/cli -n '*CLI 2.85.0*' gh_*_linux_amd64.deb" >&2
        echo "Example: gh-latest cli/cli -i 0" >&2
        return 1
        ;;
      *)
        if [ -z "$repo" ]; then
          repo="$1"
        else
          file="$1"
        fi
        shift
        ;;
    esac
  done

  [ "$quiet" -eq 1 ] && verbose=0

  repo="${repo#https://}"
  repo="${repo#http://}"
  repo="${repo#github.com/}"
  repo="${repo%.git}"
  repo="${repo%/}"

  if ! echo "$repo" | grep -Eq '^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$'; then
    echo "Error: invalid repo format. Expected 'user/repo' or URL" >&2
    echo "Usage: gh-latest [-n|--name NAME] [-t|--tag TAG_NAME] [-i|--index N] [-q|--quiet] [-v|--verbose] [dl-options] <repo> [file-pattern]" >&2
    echo "Example: gh-latest cli/cli *.deb" >&2
    echo "Example: gh-latest https://github.com/cli/cli/ gh_*_linux_amd64.deb" >&2
    echo "Example: gh-latest github.com/cli/cli -n '*CLI 2.85.0*' gh_*_linux_amd64.deb" >&2
    echo "Example: gh-latest cli/cli -i 0" >&2
    return 1
  fi

  if [ -z "$repo" ]; then
    echo "Error: invalid repo format. Expected 'user/repo' or URL" >&2
    echo "Usage: gh-latest [-n|--name NAME] [-t|--tag TAG_NAME] [-i|--index N] [-q|--quiet] [-v|--verbose] [dl-options] <repo> [file-pattern]" >&2
    echo "Example: gh-latest cli/cli *.deb" >&2
    echo "Example: gh-latest https://github.com/cli/cli/ gh_*_linux_amd64.deb" >&2
    echo "Example: gh-latest github.com/cli/cli -n '*CLI 2.85.0*' gh_*_linux_amd64.deb" >&2
    echo "Example: gh-latest cli/cli -i 0" >&2
    return 1
  fi

  [ "$quiet" -eq 0 ] && echo "Fetching latest release for $repo..." >&2

  local file_regex=""
  if [ -n "$file" ]; then
    file_regex=$(printf '%s' "$file" | sed '
      s/\\/\\\\\\\\/g
      s/\[/\\\\[/g
      s/\]/\\\\]/g
      s/\./[.]/g
      s/\*/.*/g
      s/\?/./g
      s/(/\\\\(/g
      s/)/\\\\)/g
      s/|/\\\\|/g
      s/+/\\\\+/g
      s/\$/\\\\$/g
      s/\^/\\\\^/g
    ')
    file_regex="^${file_regex}\$"
  fi

  local release_json
  if [ -n "$name" ] || [ -n "$tag" ]; then
    release_json=$(curl -fsSL "https://api.github.com/repos/$repo/releases" 2>/dev/null)
    if [ -z "$release_json" ]; then
      echo "Error: failed to fetch releases or repo not found" >&2
      return 1
    fi
  else
    release_json=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null)
    if [ -z "$release_json" ] || [ "$release_json" = "null" ]; then
      echo "Error: no releases found or repo not found" >&2
      return 1
    fi
  fi

  if [ -n "$name" ]; then
    local name_regex
    name_regex=$(printf '%s' "$name" | sed '
      s/\\/\\\\\\\\/g
      s/\[/\\\\[/g
      s/\]/\\\\]/g
      s/\./[.]/g
      s/\*/.*/g
      s/\?/./g
      s/(/\\\\(/g
      s/)/\\\\)/g
      s/|/\\\\|/g
      s/+/\\\\+/g
      s/\$/\\\\$/g
      s/\^/\\\\^/g
    ')
    name_regex="^${name_regex}\$"

    release_json=$(echo "$release_json" | jq -r --arg NAME "$name_regex" '
      map(select(
        .name != null and
        (.name | test($NAME))
      ))
      | max_by(.published_at)
    ')

    if [ "$release_json" = "null" ] || [ -z "$release_json" ]; then
      echo "Error: no release found with name matching: $name" >&2
      return 1
    fi
  fi

  if [ -n "$tag" ]; then
    local tag_regex
    tag_regex=$(printf '%s' "$tag" | sed '
      s/\\/\\\\\\\\/g
      s/\[/\\\\[/g
      s/\]/\\\\]/g
      s/\./[.]/g
      s/\*/.*/g
      s/\?/./g
      s/(/\\\\(/g
      s/)/\\\\)/g
      s/|/\\\\|/g
      s/+/\\\\+/g
      s/\$/\\\\$/g
      s/\^/\\\\^/g
    ')
    tag_regex="^${tag_regex}\$"

    release_json=$(echo "$release_json" | jq -r --arg TAG "$tag_regex" '
      map(select(
        .tag_name != null and
        (.tag_name | test($TAG))
      ))
      | max_by(.published_at)
    ')

    if [ "$release_json" = "null" ] || [ -z "$release_json" ]; then
      echo "Error: no release found with tag name matching: $tag" >&2
      return 1
    fi
  fi

  local urls
  urls=$(echo "$release_json" | jq -r --arg FILE "$file_regex" --arg INDEX "$index" '
    if .assets then
      .assets
      | map(select(
          .name != null and
          ($FILE == "" or (.name | test($FILE)))
        ))
      | if $INDEX != "" then
          [.[($INDEX|tonumber)]?]
        else
          .
        end
      | .[]
      | .browser_download_url
    else
      empty
    end
  ')

  if [ -z "$urls" ]; then
    echo "Error: no matching assets found" >&2
    return 1
  fi

  local count
  count=$(echo "$urls" | grep -cve '^\s*$')

  if [ "$quiet" -eq 0 ]; then
    local release_name=$(echo "$release_json" | jq -r '.name // .tag_name')
    echo "Release: $release_name" >&2

    if [ "$count" -gt 1 ]; then
      echo "Found $count matching assets. Downloading all" >&2
      if [ "$verbose" -eq 1 ]; then
        echo "$urls" | nl -w2 -s': ' | sed 's/^/  /' >&2
      fi
    elif [ "$verbose" -eq 1 ]; then
      echo "Found 1 matching asset:" >&2
      echo "$urls" | sed 's/^/  /' >&2
    fi
  fi

  local success=true
  local downloaded=0
  while IFS= read -r url; do
    [ -z "$url" ] && continue

    downloaded=$((downloaded + 1))
    [ "$quiet" -eq 0 ] && echo "[$downloaded/$count] Downloading: $(basename "$url")" >&2

    if ! dl "${dl_args[@]}" "$url"; then
      echo "Error: failed to download $url" >&2
      success=false
    fi
  done <<< "$urls"

  if [ "$success" = false ]; then
    return 1
  elif [ "$quiet" -eq 0 ]; then
    echo "Download completed successfully" >&2
  fi
}

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
if [ "${UBUNTU_VERSION_ID:-}" = "25.10" ]; then
sudo tee /etc/apt/preferences.d/99-plucky-fallback, >/dev/null <<'EOF'
Package: *
Pin: release n=plucky, o=LP-PPA-*
Pin-Priority: 100
EOF
fi
sudo timedatectl set-local-rtc 1
sudo timedatectl set-ntp true
sudo apt update
sudo add-apt-repository universe -y
sudo add-apt-repository multiverse -y
sudo add-apt-repository restricted -y
sudo add-apt-repository ppa:graphics-drivers/ppa -y
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
bash <<'EOF'
set -e
f=/etc/apt/sources.list.d/ubuntu.sources
if [ -f "$f" ] && grep -q "^Types:.*deb" "$f"; then
    sudo sed -i 's/^Types: *deb.*/Types: deb deb-src/' "$f"
fi
EOF
sudo apt update
sudo apt purge fcitx* -y
sudo apt full-upgrade -y
echo y | sudo ubuntu-drivers install
echo y | sudo ubuntu-drivers install
sudo apt install alsa-utils apksigner apt-transport-https aptitude aria2 autoconf automake bash bc bear bison build-essential bzip2 ca-certificates clang clang-format cmake command-not-found curl dbus default-jdk dnsutils dvipng dvisvgm fastfetch ffmpeg file flex g++ gcc gdb gfortran gh ghostscript git glab gnucobol gnupg golang gperf gpg grep gtkwave gzip info inkscape iproute2 iverilog iverilog jpegoptim jq libboost-all-dev libbz2-dev libconfig-dev libeigen3-dev libffi-dev libfuse2 libgdbm-compat-dev libgdbm-dev libgsl-dev libheif-examples libllvm19 liblzma-dev libncursesw5-dev libosmesa6 libreadline-dev libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-net-dev libsdl2-ttf-dev libsqlite3-dev libssl-dev libxml2-dev libxmlsec1-dev libzstd-dev llvm make maven mc nano ncompress neovim ngspice openjdk-21-jdk openssh-client openssh-server openssl optipng pandoc perl perl-doc pipx plantuml procps pv python3-all-dev python3-pip python3-venv rust-all sudo tar tk-dev tmux tree unzip uuid-dev uuid-runtime valgrind verilator vim wget x11-utils x11-xserver-utils xmlstarlet xz-utils zip zlib1g zlib1g-dev zsh -y
sudo apt install codeblocks* fcitx5 fcitx5-* flatpak libreoffice openjdk-8-jdk openjdk-11-jdk openjdk-17-jdk qbittorrent qtwayland5 software-properties-common testdisk torbrowser-launcher update-manager-core unrar vim-gtk3 -y
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
if ! grep -q '^NAME="Linux Mint"' /etc/os-release; then
sudo add-apt-repository ppa:mozillateam/ppa -y
echo 'Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: firefox*
Pin: release o=Ubuntu
Pin-Priority: -1

Package: thunderbird*
Pin: release o=Ubuntu
Pin-Priority: -1' | sudo tee /etc/apt/preferences.d/mozilla
sudo rm -f /etc/apparmor.d/usr.bin.firefox
sudo rm -f /etc/apparmor.d/local/usr.bin.firefox
sudo systemctl stop var-snap-firefox-common-*.mount 2>/dev/null || true
sudo systemctl disable var-snap-firefox-common-*.mount 2>/dev/null || true
sudo snap remove --purge firefox || true
sudo apt remove firerox --purge -y || true
sudo apt install firefox-esr --allow-downgrades -y
sudo rm -f /etc/apparmor.d/usr.bin.thunderbird
sudo rm -f /etc/apparmor.d/local/usr.bin.thunderbird
sudo systemctl stop var-snap-thunderbird-common-*.mount 2>/dev/null || true
sudo systemctl disable var-snap-thunderbird-common-*.mount 2>/dev/null || true
sudo snap remove --purge thunderbird || true
sudo apt install thunderbird --allow-downgrades -y
echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:$(lsb_release -cs)";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-mozilla
sudo ln -sf /etc/apparmor.d/firefox /etc/apparmor.d/disable/
sudo apparmor_parser -R /etc/apparmor.d/firefox
fi
wget -O sdl2_bgi_3.0.4-1_amd64.deb https://sourceforge.net/projects/sdl-bgi/files/sdl2_bgi_3.0.4-1_amd64.deb/download
sudo apt install ./sdl2_bgi_3.0.4-1_amd64.deb -y
rm sdl2_bgi_3.0.4-1_amd64.deb
curl -fsSL https://ftp-master.debian.org/keys/archive-key-11.asc | sudo gpg --dearmor -o /usr/share/keyrings/debian-archive-keyring.gpg
sudo mkdir -p /root/.gnupg
sudo chmod 700 /root/.gnupg
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/debian-archive-keyring.gpg --keyserver keyserver.ubuntu.com --recv-keys 0E98404D386FA1D9 6ED0E7B82643E131 F8D2585B8783D481 54404762BBB6E853 BDE6D2B9216EC7A8 BDE6D2B9216EC7A8 8E9F831205B4BA95
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl enable ssh
yes | sudo ufw enable
sudo ufw allow ssh
dl https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xzf install-tl-unx.tar.gz
rm install-tl-unx.tar.gz
cd install-tl-*
sudo perl install-tl --no-interaction
cd ~
rm -rf install-tl-*
mkdir -p ~/.config/fontconfig/conf.d
cat > ~/.config/fontconfig/conf.d/99-texlive.conf <<'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <dir>/usr/local/texlive/2025/texmf-dist/fonts</dir>
</fontconfig>
EOF
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install 22
corepack enable yarn
corepack enable pnpm
npm install -g http-server jsdom marked marked-gfm-heading-id node-html-markdown showdown @openai/codex
sudo mkdir /usr/local/go
export GOPROXY='direct'
export GOROOT="/usr/local/go"
export GOPATH="$GOPATH:$HOME/go"
sudo go install github.com/danielmiessler/fabric@latest
pipx install poetry uv
cat > ~/.profile <<'EOF'
# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
EOF
cat > ~/.bashrc <<'EOF'
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export TMPDIR="/tmp"
export CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:/usr/include:/usr/include/SDL2"
export CXXFLAGS='-std=gnu++20 -O2'
export CFLAGS='-std=c17 -O2'
export GOPROXY='direct'
export GOROOT="/usr/local/go"
export GOPATH="$HOME/go:$GOPATH"
export NVM_DIR="$HOME/.nvm"
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64/bin/java"
export CLASSPATH="$CLASSPATH:/usr/lib/antlr-4.13.2-complete.jar"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export ANDROID_NDK_HOME="$HOME/Android/Sdk/ndk/29.0.14206865"
export PATH="$PATH:/bin:/sbin:/usr/bin:/usr/sbin:$HOME/.local/bin:$GOPATH/bin:$GOROOT/bin:/usr/glibc/bin:$HOME/.cargo/bin:/opt/TurboVNC/bin:/usr/local/texlive/2025/bin/x86_64-linux:/opt/android-studio/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$ANDROID_NDK_HOME:$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$HOME/intelFPGA/20.1/modelsim_ase/bin"
export WAYDROID="$HOME/.local/share/waydroid/data/media/0"
export KIT="/usr/share/LaTeX-ToolKit"
export PATCH="$HOME/texmf/tex/latex/physics-patch"
export PLANTUML_JAR="$HOME/plantuml.jar"
export BOTTLES="$HOME/.var/app/com.usebottles.bottles/data/bottles"
alias antlr4='java -Xmx500M -cp "/usr/local/lib/antlr-4.13.2-complete.jar:$CLASSPATH" org.antlr.v4.Tool'
alias grun='java -Xmx500M -cp "/usr/local/lib/antlr-4.13.2-complete.jar:$CLASSPATH" org.antlr.v4.gui.TestRig'
alias src='source'
alias g++20='g++ -std=gnu++20'
alias c++20='clang++ -std=gnu++20'
alias g++201='g++ -std=gnu++20 -O1'
alias c++201='clang++ -std=gnu++20 -O1'
alias g++202='g++ -std=gnu++20 -O2'
alias c++202='clang++ -std=gnu++20 -O2'
alias g++203='g++ -std=gnu++20 -O3'
alias c++203='clang++ -std=gnu++20 -O3'
alias cfm='clang-format'
alias cfmi='clang-format -i'
alias vnc='vncserver'
alias vnck='vncserver -kill'
alias vncl='vncserver -list'
alias httpp='http-server -p'
alias discord='flatpak run com.discordapp.Discord'
alias obs-studio='flatpak run com.obsproject.Studio'
alias spotify='flatpak run com.spotify.Client'
alias bottles='flatpak run com.usebottles.bottles'
alias bottles-cli='flatpak run --command=bottles-cli com.usebottles.bottles'
alias handbrake='flatpak run fr.handbrake.ghb'
alias freetube='flatpak run io.freetubeapp.FreeTube'
alias brisk='flatpak run io.github.BrisklyDev.Brisk'
alias joplin='flatpak run net.cozic.joplin_desktop'
alias chromium='flatpak run org.chromium.Chromium'
alias gimp='flatpak run org.gimp.GIMP'
alias aisleriot='flatpak run org.gnome.Aisleriot'
alias krita='flatpak run org.kde.krita'
alias musescore='flatpak run org.musescore.MuseScore'
alias onlyoffice='flatpak run org.onlyoffice.desktopeditors'
alias telegram='flatpak run org.telegram.desktop'
alias vlc='flatpak run org.videolan.VLC'
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export UBUNTU_VERSION_ID=$(
if grep -q '^NAME="Linux Mint"' /etc/os-release; then
    inxi -Sx | awk -F': ' '/base/{print $2}' | awk '{print $2}'
else
    . /etc/os-release
    echo "$VERSION_ID"
fi
)

__git_repo_reminder() {
    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$repo_root" ]; then
        if [ "$__LAST_REPO_ROOT" != "$repo_root" ]; then
            if [ -n "$__LAST_REPO_ROOT" ]; then
                echo "Leaving Git repository: consider running 'git push'"
            fi
            echo "Entered Git repository: consider running 'git pull'"
            __LAST_REPO_ROOT="$repo_root"
        fi
    else
        if [ -n "$__LAST_REPO_ROOT" ]; then
            echo "Leaving Git repository: consider running 'git push'"
            unset __LAST_REPO_ROOT
        fi
    fi
}
PROMPT_COMMAND="__git_repo_reminder${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

gccSDL2() {
    gcc "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lm -lstdc++
}

gccSDL2bgi() {
    gcc "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi -lm -lstdc++
}

g++SDL2() {
    g++ "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

g++SDL2bgi() {
    g++ "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

g++20SDL2() {
    g++ -std=gnu++20 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

g++20SDL2bgi() {
    g++ -std=gnu++20 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

g++201SDL2() {
    g++ -std=gnu++20 -O1 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

g++201SDL2bgi() {
    g++ -std=gnu++20 -O1 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

g++202SDL2() {
    g++ -std=gnu++20 -O2 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

g++202SDL2bgi() {
    g++ -std=gnu++20 -O2 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

g++203SDL2() {
    g++ -std=gnu++20 -O3 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net
}

g++203SDL2bgi() {
    g++ -std=gnu++20 -O3 "$@" -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf -lSDL2_net -lSDL2_bgi
}

xdgset() {
    export XDG_RUNTIME_DIR=/tmp/runtime-root
    mkdir -p $XDG_RUNTIME_DIR
    export DISPLAY="$1"
}

vncclean() {
  if [ $# -ne 1 ] || ! [[ $1 =~ ^[0-9]+$ ]]; then
    echo "Usage: vncclean <display_number>" >&2
    return 1
  fi

  rm -f "/tmp/.X${1}-lock"
  rm -f "/tmp/.X11-unix/.X${1}"
}

dl() {
  local has_option=0
  local out=
  local quiet=0
  local verbose=0
  local url=
  local to_stdout=0
  local no_fallback=0
  local use_aria2=1
  local use_curl=1
  local use_wget=1
  local tmp_file
  if [ -z "$TMPDIR" ]; then
    tmp_file=$(mktemp "/tmp/dl.XXXXXXXXXX") || return 1
  else
    tmp_file=$(mktemp "$TMPDIR/dl.XXXXXXXXXX") || return 1
  fi
  local old_exit old_int old_term
  old_exit=$(trap -p EXIT)
  old_int=$(trap -p INT)
  old_term=$(trap -p TERM)

  set -- ${DLFLAGS:-} "$@"

  while [ $# -gt 0 ]; do
    case "$1" in
      -o|--output)
        out="$2"
        shift 2
        ;;
      -O|--stdout)
        to_stdout=1
        shift
        ;;
      -q|--quiet)
        quiet=1
        shift
        ;;
      -v|--verbose)
        verbose=1
        shift
        ;;
      -a|--aria2)
        use_aria2=1; use_curl=0; use_wget=0
        shift
        ;;
      -A|--no-aria2)
        use_aria2=0
        shift
        ;;
      -c|--curl)
        use_curl=1; use_aria2=0; use_wget=0
        shift
        ;;
      -C|--no-curl)
        use_curl=0
        shift
        ;;
      -w|--wget)
        use_wget=1; use_aria2=0; use_curl=0
        shift
        ;;
      -W|--no-wget)
        use_wget=0
        shift
        ;;
      --no-fallback)
        no_fallback=1
        shift
        ;;
      --)
        shift
        break
        ;;
      -*)
        echo "Unknown option: $1" >&2
        echo "Usage: dl [-o|--output FILE] [-q|--quiet] [-v|--verbose] [-a|--aria2] [-A|--no-aria2] [-c|--curl] [-C|--no-curl] [-w|--wget] [-W|--no-wget] [--no-fallback] URL" >&2
        return 2
        ;;
      *)
        url="$1"
        shift
        ;;
    esac
  done

  [ "$quiet" -eq 1 ] && verbose=0

  if [ -z "$url" ]; then
    echo "Usage: dl [-o|--output FILE] [-q|--quiet] [-v|--verbose] [-a|--aria2] [-A|--no-aria2] [-c|--curl] [-C|--no-curl] [-w|--wget] [-W|--no-wget] [--no-fallback] URL" >&2
    return 2
  fi

  if [ -n "$out" ] && [ "$to_stdout" -eq 0 ]; then
    mkdir -p "$(dirname "$out")" || return 1
  fi

  cleanup() {
    [ -n "$tmp_file" ] && rm -f "$tmp_file"
  }

  if [ "$to_stdout" -eq 1 ] && [ "$use_aria2" -eq 1 ]; then
    trap cleanup EXIT INT TERM
  fi

  try_aria2() {
    command -v aria2c >/dev/null 2>&1 || return 127
    local opts=()
    [ "$quiet" -eq 1 ] && opts+=(-q)
    [ "$verbose" -eq 1 ] && opts+=(-v)

    if [ "$to_stdout" -eq 1 ]; then
      aria2c "${opts[@]}" -c -o "$tmp_file" "$url"
    elif [ -n "$out" ]; then
      aria2c "${opts[@]}" -c -o "$out" "$url"
    else
      aria2c "${opts[@]}" -c "$url"
    fi
  }

  try_curl() {
    command -v curl >/dev/null 2>&1 || return 127
    local opts=(-fL)
    [ "$quiet" -eq 1 ] && opts+=(-sS)
    [ "$verbose" -eq 1 ] && opts+=(-v)

    if [ "$to_stdout" -eq 1 ]; then
      curl "${opts[@]}" "$url"
    elif [ -n "$out" ]; then
      curl "${opts[@]}" -o "$out" "$url"
    else
      curl "${opts[@]}" -O "$url"
    fi
  }

  try_wget() {
    command -v wget >/dev/null 2>&1 || return 127
    local opts=()
    [ "$quiet" -eq 1 ] && opts+=(-q)
    [ "$verbose" -eq 1 ] && opts+=(-v)

    if [ "$to_stdout" -eq 1 ]; then
      wget "${opts[@]}" -O - "$url"
    elif [ -n "$out" ]; then
      wget "${opts[@]}" -O "$out" "$url"
    else
      wget "${opts[@]}" "$url"
    fi
  }

  local rc=1

  if [ "$use_aria2" -eq 1 ]; then
    if try_aria2; then
      if [ "$to_stdout" -eq 1 ]; then
        cat "$tmp_file" || return 1
      fi
      [ "$verbose" -eq 1 ] && echo "aria2 used"
      return 0
    fi
    rc=$?
    rm -f "$tmp_file"
    trap - EXIT INT TERM
    [ -n "$old_exit" ] && eval "$old_exit"
    [ -n "$old_int" ]  && eval "$old_int"
    [ -n "$old_term" ] && eval "$old_term"
    [ "$no_fallback" -eq 1 ] && return "$rc"
  fi

  if [ "$use_curl" -eq 1 ]; then
    if try_curl; then
      [ "$verbose" -eq 1 ] && echo "curl used"
      return 0
    fi
    rc=$?
    [ "$no_fallback" -eq 1 ] && return "$rc"
  fi

  if [ "$use_wget" -eq 1 ]; then
    if try_wget; then
      [ "$verbose" -eq 1 ] && echo "wget used"
      return 0
    fi
    rc=$?
    [ "$no_fallback" -eq 1 ] && return "$rc"
  fi

  echo "Error: all enabled downloaders failed" >&2
  return "$rc"
}

gh-latest() {
  local dl_args=()
  local quiet=0
  local verbose=0
  local repo=""
  local file=""
  local name=""
  local tag=""
  local index=""

  while [ $# -gt 0 ]; do
    case "$1" in
      -q|--quiet)
        quiet=1
        dl_args+=("$1")
        shift
        ;;
      -v|--verbose)
        verbose=1
        dl_args+=("$1")
        shift
        ;;
      -n|--name)
        name="$2"
        shift 2
        ;;
      -t|--tag)
        tag="$2"
        shift 2
        ;;
      -i|--index)
        index="$2"
        shift 2
        ;;
      -o|--output|--stdout|-a|--aria2|-A|--no-aria2|-c|--curl|-C|--no-curl|-w|--wget|-W|--no-wget|--no-fallback)
        dl_args+=("$1")
        if [[ "$1" == -o || "$1" == --output ]]; then
          dl_args+=("$2")
          shift
        fi
        shift
        ;;
      -*)
        echo "Unknown option: $1" >&2
        echo "Usage: gh-latest [-n|--name NAME] [-t|--tag TAG_NAME] [-i|--index N] [-o|--output FILE] [-q|--quiet] [-v|--verbose] [-a|--aria2] [-A|--no-aria2] [-c|--curl] [-C|--no-curl] [-w|--wget] [-W|--no-wget] [--no-fallback] <repo> [file-pattern]" >&2
        echo "Example: gh-latest cli/cli *.deb" >&2
        echo "Example: gh-latest https://github.com/cli/cli/ gh_*_linux_amd64.deb" >&2
        echo "Example: gh-latest github.com/cli/cli -n '*CLI 2.85.0*' gh_*_linux_amd64.deb" >&2
        echo "Example: gh-latest cli/cli -i 0" >&2
        return 1
        ;;
      *)
        if [ -z "$repo" ]; then
          repo="$1"
        else
          file="$1"
        fi
        shift
        ;;
    esac
  done

  [ "$quiet" -eq 1 ] && verbose=0

  repo="${repo#https://}"
  repo="${repo#http://}"
  repo="${repo#github.com/}"
  repo="${repo%.git}"
  repo="${repo%/}"

  if ! echo "$repo" | grep -Eq '^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$'; then
    echo "Error: invalid repo format. Expected 'user/repo' or URL" >&2
    echo "Usage: gh-latest [-n|--name NAME] [-t|--tag TAG_NAME] [-i|--index N] [-q|--quiet] [-v|--verbose] [dl-options] <repo> [file-pattern]" >&2
    echo "Example: gh-latest cli/cli *.deb" >&2
    echo "Example: gh-latest https://github.com/cli/cli/ gh_*_linux_amd64.deb" >&2
    echo "Example: gh-latest github.com/cli/cli -n '*CLI 2.85.0*' gh_*_linux_amd64.deb" >&2
    echo "Example: gh-latest cli/cli -i 0" >&2
    return 1
  fi

  if [ -z "$repo" ]; then
    echo "Error: invalid repo format. Expected 'user/repo' or URL" >&2
    echo "Usage: gh-latest [-n|--name NAME] [-t|--tag TAG_NAME] [-i|--index N] [-q|--quiet] [-v|--verbose] [dl-options] <repo> [file-pattern]" >&2
    echo "Example: gh-latest cli/cli *.deb" >&2
    echo "Example: gh-latest https://github.com/cli/cli/ gh_*_linux_amd64.deb" >&2
    echo "Example: gh-latest github.com/cli/cli -n '*CLI 2.85.0*' gh_*_linux_amd64.deb" >&2
    echo "Example: gh-latest cli/cli -i 0" >&2
    return 1
  fi

  [ "$quiet" -eq 0 ] && echo "Fetching latest release for $repo..." >&2

  local file_regex=""
  if [ -n "$file" ]; then
    file_regex=$(printf '%s' "$file" | sed '
      s/\\/\\\\\\\\/g
      s/\[/\\\\[/g
      s/\]/\\\\]/g
      s/\./[.]/g
      s/\*/.*/g
      s/\?/./g
      s/(/\\\\(/g
      s/)/\\\\)/g
      s/|/\\\\|/g
      s/+/\\\\+/g
      s/\$/\\\\$/g
      s/\^/\\\\^/g
    ')
    file_regex="^${file_regex}\$"
  fi

  local release_json
  if [ -n "$name" ] || [ -n "$tag" ]; then
    release_json=$(curl -fsSL "https://api.github.com/repos/$repo/releases" 2>/dev/null)
    if [ -z "$release_json" ]; then
      echo "Error: failed to fetch releases or repo not found" >&2
      return 1
    fi
  else
    release_json=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null)
    if [ -z "$release_json" ] || [ "$release_json" = "null" ]; then
      echo "Error: no releases found or repo not found" >&2
      return 1
    fi
  fi

  if [ -n "$name" ]; then
    local name_regex
    name_regex=$(printf '%s' "^$name\$" | sed '
      s/\\/\\\\\\\\/g
      s/\[/\\\\[/g
      s/\]/\\\\]/g
      s/\./[.]/g
      s/\*/.*/g
      s/\?/./g
      s/(/\\\\(/g
      s/)/\\\\)/g
      s/|/\\\\|/g
      s/+/\\\\+/g
      s/\$/\\\\$/g
      s/\^/\\\\^/g
    ')
    name_regex="^${name_regex}\$"

    release_json=$(echo "$release_json" | jq -r --arg NAME "$name_regex" '
      map(select(
        .name != null and
        (.name | test($NAME))
      ))
      | max_by(.published_at)
    ')

    if [ "$release_json" = "null" ] || [ -z "$release_json" ]; then
      echo "Error: no release found with name matching: $name" >&2
      return 1
    fi
  fi

  if [ -n "$tag" ]; then
    local tag_regex
    tag_regex=$(printf '%s' "^$tag\$" | sed '
      s/\\/\\\\\\\\/g
      s/\[/\\\\[/g
      s/\]/\\\\]/g
      s/\./[.]/g
      s/\*/.*/g
      s/\?/./g
      s/(/\\\\(/g
      s/)/\\\\)/g
      s/|/\\\\|/g
      s/+/\\\\+/g
      s/\$/\\\\$/g
      s/\^/\\\\^/g
    ')
    tag_regex="^${tag_regex}\$"

    release_json=$(echo "$release_json" | jq -r --arg TAG "$tag_regex" '
      map(select(
        .tag_name != null and
        (.tag_name | test($TAG))
      ))
      | max_by(.published_at)
    ')

    if [ "$release_json" = "null" ] || [ -z "$release_json" ]; then
      echo "Error: no release found with tag name matching: $tag" >&2
      return 1
    fi
  fi

  local urls
  urls=$(echo "$release_json" | jq -r --arg FILE "$file_regex" --arg INDEX "$index" '
    if .assets then
      .assets
      | map(select(
          .name != null and
          ($FILE == "" or (.name | test($FILE)))
        ))
      | if $INDEX != "" then
          [.[($INDEX|tonumber)]?]
        else
          .
        end
      | .[]
      | .browser_download_url
    else
      empty
    end
  ')

  if [ -z "$urls" ]; then
    echo "Error: no matching assets found" >&2
    return 1
  fi

  local count
  count=$(echo "$urls" | grep -cve '^\s*$')

  if [ "$quiet" -eq 0 ]; then
    local release_name=$(echo "$release_json" | jq -r '.name // .tag_name')
    echo "Release: $release_name" >&2

    if [ "$count" -gt 1 ]; then
      echo "Found $count matching assets. Downloading all" >&2
      if [ "$verbose" -eq 1 ]; then
        echo "$urls" | nl -w2 -s': ' | sed 's/^/  /' >&2
      fi
    elif [ "$verbose" -eq 1 ]; then
      echo "Found 1 matching asset:" >&2
      echo "$urls" | sed 's/^/  /' >&2
    fi
  fi

  local success=true
  local downloaded=0
  while IFS= read -r url; do
    [ -z "$url" ] && continue

    downloaded=$((downloaded + 1))
    [ "$quiet" -eq 0 ] && echo "[$downloaded/$count] Downloading: $(basename "$url")" >&2

    if ! dl "${dl_args[@]}" "$url"; then
      echo "Error: failed to download $url" >&2
      success=false
    fi
  done <<< "$urls"

  if [ "$success" = false ]; then
    return 1
  elif [ "$quiet" -eq 0 ]; then
    echo "Download completed successfully" >&2
  fi
}

gpull() {
    level="${1:-0}"
    if [ "$level" -eq 0 ]; then
        repo_dir=$(git rev-parse --show-toplevel 2>/dev/null)
        if [ -n "$repo_dir" ]; then
            echo "$repo_dir"
            (cd "$repo_dir" && git pull origin)
        else
            echo "Not in a Git repo."
        fi
    else
        depth=$((level + 1))
        find . -mindepth "$depth" -maxdepth "$depth" -type d -name .git | while read -r gitdir; do
            repo_dir=$(dirname "$gitdir")
            echo "$repo_dir"
            (cd "$repo_dir" && git pull origin)
        done
    fi
}

gacp() {
    git add .
    git commit -m "$1"
    git push
}

gtr() {
    if [ $# -lt 1 ]; then
        echo "Usage: gtr <version> [-n|--notes 'notes'] [files...]"
        return 1
    fi
    local version="$1"
    shift
    local notes=""
    local files=()

    while [ $# -gt 0 ]; do
        case "$1" in
            -n|--notes)
                shift
                if [ $# -eq 0 ]; then
                    echo "Error: Missing notes after -n|--notes"
                    return 1
                fi
                notes="$1"
                ;;
            *)
                files+=("$1")
                ;;
        esac
        shift
    done

    git tag -a "v$version" -m "Version $version release"
    git push origin "v$version"

    if [ -n "$notes" ]; then
        gh release create "v$version" --title "Version $version release" --notes "$notes" "${files[@]}"
    else
        gh release create "v$version" --title "Version $version release" --notes "" "${files[@]}"
    fi
}

git-upstream-pr() {
  if [ -z "$1" ]; then
    echo "Usage: git-upstream-pr <PR_NUMBER>"
    return 1
  fi
  git fetch upstream pull/$1/head:pr-$1 || { echo "Fetch failed"; return 1; }
  git merge pr-$1 || { echo "Merge conflict! Resolve manually."; return 1; }
  git push || { echo "Push failed"; return 1; }
  git branch -D pr-$1
}

updatetex() {
    cd /usr/share/LaTeX-ToolKit
    sudo git pull
    cd ~/texmf/tex/latex/physics-patch
    git pull
    cd
}

updatevimrc() {
    cd /opt/vim_runtime
    git reset --hard
    git clean -d --force
    git pull --rebase
    python3 update_plugins.py
    cd
}

rand() {
    od -An -N4 -tu4 < /dev/urandom | tr -d ' ' | awk -v min=$1 -v max=$2 '{print int($1 % (max - min)) + min}';
}

bzip-single() {
  tar -cf - "$1" \
  | pv \
  | bzip2 -9 \
  | pv \
  > "$2.tar.bz2"
}

bzip-split() {
  tar -cf - "$1" \
  | pv \
  | bzip2 -9 \
  | pv \
  | split -b 4000M -d -a 3 - "$2.tar.bz2.part."
}
EOF
source ~/.bashrc
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh -b -p ${HOME}/miniforge3
source "${HOME}/miniforge3/etc/profile.d/conda.sh"
source "${HOME}/miniforge3/etc/profile.d/mamba.sh"
conda init
exec bash
rm Miniforge3-Linux-x86_64.sh
mkdir -p /usr/local/lib
sudo wget -O /usr/local/lib/antlr-4.13.2-complete.jar https://www.antlr.org/download/antlr-4.13.2-complete.jar
sudo git clone --depth=1 https://github.com/Willie169/vimrc.git /opt/vim_runtime && sh /opt/vim_runtime/install_awesome_parameterized.sh /opt/vim_runtime --all
mkdir -p ~/.config/nvim
echo 'set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
' | sudo tee ~/.config/nvim/init.vim > /dev/null
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/trusted.gpg.d/docker.asc > /dev/null
source /etc/os-release
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce -y
sudo systemctl enable docker
sudo usermod -aG docker $USER
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt update
sudo apt install tailscale -y
sudo systemctl enable tailscaled
sudo add-apt-repository ppa:fdroid/fdroidserver -y
sudo apt update
sudo apt install fdroidserver -y
wget -O- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
rm packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install code -y
wget https://packages.microsoft.com/config/ubuntu/$UBUNTU_VERSION_ID/packages-microsoft-prod.deb
sudo apt install ./packages-microsoft-prod.deb -y
rm packages-microsoft-prod.deb
sudo add-apt-repository ppa:dotnet/backports -y
sudo apt update
sudo apt install dotnet-sdk-10.0 aspnetcore-runtime-10.0 -y
sudo gpg --homedir /tmp --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/mono-official-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
sudo chmod +r /usr/share/keyrings/mono-official-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
sudo apt update
sudo apt install mono-complete -y
wget 'https://downloads.godotengine.org/?version=4.5.1&flavor=stable&slug=mono_linux_x86_64.zip&platform=linux.64'
unzip Godot_v4.5.1-stable_mono_linux_x86_64.zip
rm Godot_v4.5.1-stable_mono_linux_x86_64.zip
sudo ln -s ~/Godot_v4.5.1-stable_mono_linux_x86_64/Godot_v4.5.1-stable_mono_linux.x86_64 /usr/local/bin/godot
source /etc/os-release
wget -O- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | sudo tee /usr/share/keyrings/deb.torproject.org-keyring.gpg >/dev/null
sudo tee /etc/apt/sources.list.d/tor.list > /dev/null <<EOF
deb [arch=amd64 signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org ${UBUNTU_CODENAME} main
deb-src [arch=amd64 signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org ${UBUNTU_CODENAME} main
EOF
sudo apt update
sudo apt install tor deb.torproject.org-keyring -y
wget -O plantuml.jar https://sourceforge.net/projects/plantuml/files/plantuml.jar/download
sudo add-apt-repository ppa:bkryza/clang-uml -y
if [ "${UBUNTU_VERSION_ID:-}" = "25.10" ]; then
sudo sed -i -e '/^Suites:/ { /plucky/! s/$/ plucky/ }' /etc/apt/sources.list.d/bkryza-ubuntu-clang-uml-questing.sources
## reverse with:
# sudo sed -i -e '/^Suites:/ s/\([[:space:]]\)plucky\b//g' /etc/apt/sources.list.d/bkryza-ubuntu-clang-uml-questing.sources
fi
sudo apt update
sudo apt install clang-uml -y
sudo apt install postgresql-common -y
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y
sudo apt install postgresql-17 -y
wget https://cdn.fastly.steamstatic.com/client/installer/steam.deb
sudo apt install ./steam.deb -y
wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2025.2.2.8/android-studio-2025.2.2.8-linux.tar.gz
sudo tar -xzf android-studio-2025.2.2.8-linux.tar.gz -C /opt/
rm android-studio-2025.2.2.8-linux.tar.gz
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
echo y | ./sdkmanager "build-tools;30.0.3" "build-tools;35.0.0" "build-tools;36.1.0" "emulator" "ndk;29.0.14206865" "platform-tools" "platforms;android-33" "platforms;android-36" "system-images;android-33;google_apis_playstore;x86_64" "system-images;android-36.1;google_apis_playstore;x86_64"
cd ~
gh-latest ente-io/ente -t auth* ente-auth-v*-x86_64.deb
sudo apt install ./ente-auth-v*-x86_64.deb -y
rm ente-auth-v*-x86_64.deb
gh-latest balena-io/etcher balena-etcher_*_amd64.deb
sudo apt install ./balena-etcher_*_amd64.deb -y
rm balena-etcher_*_amd64.deb
gh-latest arduino/arduino-cli arduino-cli_*_amd64.deb
sudo apt install ./arduino-cli_*_amd64.deb -y
rm arduino-cli_*_amd64.deb
gh-latest arduino/arduino-ide arduino-ide_*_Linux_64bit.AppImage
chmod +x ~/arduino-ide_2.3.6_Linux_64bit.AppImage
echo 'SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", GROUP="plugdev", MODE="0666"' | sudo tee /etc/udev/rules.d/99-arduino.rules >/dev/null
gh-latest Stellarium/stellarium Stellarium-*-qt5-x86_64.AppImage
chmod +x Stellarium-*-qt5-x86_64.AppImage
sudo mkdir -p /usr/share/fonts/opentype/xits
cd /usr/share/fonts/opentype/xits
sudo dl https://github.com/aliftype/xits/releases/download/v1.302/XITS-1.302.zip
sudo unzip XITS-1.302.zip
cd XITS-1.302
sudo mv *.otf ..
cd ..
sudo rm -rf XITS-1.302*
sudo mkdir -p /usr/share/fonts/noto-cjk
cd /usr/share/fonts/noto-cjk
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/TC/NotoSansTC-Thin.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/TC/NotoSansTC-Regular.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/TC/NotoSansTC-Medium.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/TC/NotoSansTC-Light.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/TC/NotoSansTC-DemiLight.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/TC/NotoSansTC-Bold.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/TC/NotoSansTC-Black.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/SC/NotoSansSC-Thin.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/SC/NotoSansSC-Regular.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/SC/NotoSansSC-Medium.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/SC/NotoSansSC-Light.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/SC/NotoSansSC-DemiLight.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/SC/NotoSansSC-Bold.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/SC/NotoSansSC-Black.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/HK/NotoSansHK-Thin.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/HK/NotoSansHK-Regular.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/HK/NotoSansHK-Medium.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/HK/NotoSansHK-Light.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/HK/NotoSansHK-DemiLight.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/HK/NotoSansHK-Bold.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/HK/NotoSansHK-Black.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/JP/NotoSansJP-Thin.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/JP/NotoSansJP-Regular.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/JP/NotoSansJP-Medium.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/JP/NotoSansJP-Light.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/JP/NotoSansJP-DemiLight.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/JP/NotoSansJP-Bold.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/JP/NotoSansJP-Black.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/KR/NotoSansKR-Thin.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/KR/NotoSansKR-Regular.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/KR/NotoSansKR-Medium.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/KR/NotoSansKR-Light.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/KR/NotoSansKR-DemiLight.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/KR/NotoSansKR-Bold.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/SubsetOTF/KR/NotoSansKR-Black.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/TC/NotoSerifTC-ExtraLight.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/TC/NotoSerifTC-Regular.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/TC/NotoSerifTC-Medium.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/TC/NotoSerifTC-Light.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/TC/NotoSerifTC-SemiBold.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/TC/NotoSerifTC-Bold.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/TC/NotoSerifTC-Black.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/SC/NotoSerifSC-ExtraLight.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/SC/NotoSerifSC-Regular.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/SC/NotoSerifSC-Medium.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/SC/NotoSerifSC-Light.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/SC/NotoSerifSC-SemiBold.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/SC/NotoSerifSC-Bold.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/SC/NotoSerifSC-Black.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/HK/NotoSerifHK-ExtraLight.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/HK/NotoSerifHK-Regular.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/HK/NotoSerifHK-Medium.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/HK/NotoSerifHK-Light.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/HK/NotoSerifHK-SemiBold.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/HK/NotoSerifHK-Bold.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/HK/NotoSerifHK-Black.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/JP/NotoSerifJP-ExtraLight.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/JP/NotoSerifJP-Regular.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/JP/NotoSerifJP-Medium.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/JP/NotoSerifJP-Light.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/JP/NotoSerifJP-SemiBold.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/JP/NotoSerifJP-Bold.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/JP/NotoSerifJP-Black.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/KR/NotoSerifKR-ExtraLight.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/KR/NotoSerifKR-Regular.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/KR/NotoSerifKR-Medium.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/KR/NotoSerifKR-Light.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/KR/NotoSerifKR-SemiBold.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/KR/NotoSerifKR-Bold.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Serif/SubsetOTF/KR/NotoSerifKR-Black.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Mono/NotoSansMonoCJKtc-Regular.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Mono/NotoSansMonoCJKtc-Bold.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Mono/NotoSansMonoCJKsc-Regular.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Mono/NotoSansMonoCJKsc-Bold.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Mono/NotoSansMonoCJKhk-Regular.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Mono/NotoSansMonoCJKhk-Bold.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Mono/NotoSansMonoCJKjp-Regular.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Mono/NotoSansMonoCJKjp-Bold.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Mono/NotoSansMonoCJKkr-Regular.otf
sudo dl https://raw.githubusercontent.com/notofonts/noto-cjk/main/Sans/Mono/NotoSansMonoCJKkr-Bold.otf
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
sudo apt full-upgrade -y
sudo apt autoremove --purge -y
sudo apt clean
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
kill "$SUDOPID"
sudo reboot
