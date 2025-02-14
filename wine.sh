cd ~
sudo dpkg --add-architecture i386
code=$(cat /etc/os-release | grep "UBUNTU_CODENAME")
if test -z "$code"; then
code=$(cat /etc/os-release | grep "VERSION_CODENAME")
dist='debian'
else
dist='ubuntu'
fi
code=$(echo $code | sed 's/^[^=]*=//')
sudo mkdir -pm755 /etc/apt/keyrings
wget -O - https://dl.winehq.org/wine-builds/winehq.key | sudo gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/$dist/dists/$code/winehq-$code.sources
sudo apt update
sudo apt install --install-recommends winehq-devel -y