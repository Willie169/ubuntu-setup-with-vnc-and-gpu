cd ~
sudo dpkg --add-architecture i386
source /etc/os-release
code=$UBUNTU_CODENAME
if test -z "$code"; then
code=$VERSION_CODENAME
dist='debian'
else
dist='ubuntu'
fi
sudo mkdir -pm755 /etc/apt/keyrings
wget -O - https://dl.winehq.org/wine-builds/winehq.key | sudo gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/$dist/dists/$code/winehq-$code.sources
sudo apt update
sudo apt install --install-recommends winehq-devel -y
