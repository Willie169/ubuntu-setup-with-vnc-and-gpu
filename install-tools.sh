cd ~
sudo apt update
sudo apt purge fcitx* -y
sudo apt upgrade -y
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt update
sudo ubuntu-drivers autoinstall -y
sudo apt install apt-transport-https automake bash build-essential bzip2 ca-certificates clang cmake codeblocks* command-not-found curl dbus fcitx5 fcitx5-* ffmpeg file flatpak gdb gh ghostscript git glab golang gpg grep libboost-all-dev libbz2-dev libdb-dev libeigen3-dev libffi-dev libgdbm-compat-dev libgdbm-dev libgsl-dev liblzma-dev libncursesw5-dev libnss3-dev libreadline-dev libsqlite3-dev libssl-dev libxcb-cursor0 libxml2-dev libxmlsec1-dev llvm iproute2 jq make maven mc nano neovim openjdk-8-jdk openjdk-11-jdk openjdk-17-jdk openjdk-21-jdk openssh-client openssh-server openssl pandoc perl perl-doc pipx procps python3-pip python3-all-dev python3-venv rust-all software-properties-common tar tk-dev tmux unrar uuid-dev vim wget xz-utils zlib1g-dev zsh -y
im-config -n fcitx5
sudo systemctl enable ssh
yes | sudo ufw enable
sudo ufw allow ssh
ip route
wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xvzf install-tl-unx.tar.gz
sudo rm install-tl-unx.tar.gz
cd install-tl-*
sudo perl install-tl --no-interaction
cd ~
sudo rm -rf install-tl-*
mkdir -p ~/.config/fontconfig/conf.d
cat > ~/.config/fontconfig/conf.d/99-texlive.conf << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <dir>/usr/local/texlive/2025/texmf-dist/fonts</dir>
</fontconfig>
EOF
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install 22
corepack enable yarn
corepack enable pnpm
y | yarn
y | pnpm
npm install -g jsdom marked marked-gfm-heading-id node-html-markdown showdown
go install github.com/danielmiessler/fabric@latest
mkdir -p /usr/local/lib
sudo curl -o /usr/local/lib/antlr-4.13.2-complete.jar https://www.antlr.org/download/antlr-4.13.2-complete.jar
curl https://pyenv.run | bash
pyenv install 2.7.13
pyenv install 3.9.13
pyenv install 3.10.11
pyenv install 3.11.9
pyenv install 3.12.10
pyenv install 3.13.5
pyenv global 3.12.10
pipx install poetry
python3 -m venv .env
source .env/bin/activate
pip3 install jupyter librosa matplotlib meson ninja numpy pandas pydub scipy selenium setuptools sympy
deactivate
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/trusted.gpg.d/docker.asc > /dev/null
source /etc/os-release
sudo add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable" -y
sudo apt update
sudo apt install docker-ce -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt update
sudo apt install tailscale -y
sudo systemctl enable tailscaled
sudo add-apt-repository ppa:hluk/copyq -y
sudo apt update
sudo apt install copyq -y
OS_VERSION_ID=$(
if grep -q '^NAME="Linux Mint"' /etc/os-release; then
    inxi -Sx | awk -F': ' '/base/{print $2}' | awk '{print $2}'
else
    source /etc/os-release
    echo $VERSION_ID
fi
)
wget -q https://packages.microsoft.com/config/ubuntu/$OS_VERSION_ID/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo sh -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install code powershell dotnet-sdk-8.0 dotnet-runtime-8.0 -y
cat > ~/.profile << 'EOF' 
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

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export INPUT_METHOD=fcitx
EOF
cat > ~/.bashrc << 'EOF' 
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

export CLASSPATH="$CLASSPATH:/usr/lib/antlr-4.13.2-complete.jar"
export GOROOT="$GOROOT:/usr/lib/go"
export GOPATH="$GOPATH:$HOME/go"
export PATH="$PATH:/bin:/sbin:/usr/bin:/usr/sbin:$HOME/.local/bin:$GOPATH/bin:$GOROOT/bin:/usr/glibc/bin:$HOME/.cargo/bin:/opt/TurboVNC/bin:/usr/local/texlive/2025/bin/x86_64-linux:/usr/sbin:$HOME/.pyenv/bin"
export WAYDROID="$HOME/.local/share/waydroid/data/media/0"
export KIT="/usr/share/LaTeX-ToolKit"
export PATCH="/root/texmf/tex/latex/physics-patch"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
alias antlr4='java -Xmx500M -cp "/usr/local/lib/antlr-4.13.2-complete.jar:$CLASSPATH" org.antlr.v4.Tool'
alias grun='java -Xmx500M -cp "/usr/local/lib/antlr-4.13.2-complete.jar:$CLASSPATH" org.antlr.v4.gui.TestRig'
alias src='source'
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

gpull() {
    level="${1:-0}"
    if [ "$level" -eq 0 ]; then
        repo_dir=$(git rev-parse --show-toplevel 2>/dev/null)
        if [ -n "$repo_dir" ]; then
            echo "$repo_dir"
            (cd "$repo_dir" && git pull)
        else
            echo "Not in a Git repo."
        fi
    else
        depth=$((level + 1))
        find . -mindepth "$depth" -maxdepth "$depth" -type d -name .git | while read -r gitdir; do
            repo_dir=$(dirname "$gitdir")
            echo "$repo_dir"
            (cd "$repo_dir" && git pull)
        done
    fi
}

gacp() {
    git add .
    git commit -m "$1"
    git push
}

gtr() {
    git tag -a v"$1" -m "Version $1 release"
    git push origin v"$1"
    gh release create v"$1" --title "Version $1 release" --notes ''
}

updatetex() {
    dir=$(pwd)
    cd /usr/share/LaTeX-ToolKit
    sudo git pull
    cd ~/texmf/tex/latex/physics-patch
    git pull
    cd dir
}

EOF
source ~/.bashrc
cat > ~/.vimrc << 'EOF'
set tabstop=4
set shiftwidth=4
set expandtab
set smarttab
set smartindent
filetype plugin indent on
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
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.discordapp.Discord org.telegram.desktop com.spotify.Client org.videolan.VLC com.obsproject.Studio org.libreoffice.LibreOffice org.onlyoffice.desktopeditors net.cozic.joplin_desktop com.calibre_ebook.calibre com.getpostman.Postman org.gimp.GIMP org.kde.krita fr.handbrake.ghb org.musescore.MuseScore flathub org.gnome.Aisleriot -y
wget https://cdn.fastly.steamstatic.com/client/installer/steam.deb
sudo dpkg -i steam*.deb
rm steam*.deb
sudo apt install -f -y
sudo reboot