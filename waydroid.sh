cd ~
sudo apt update
sudo apt install curl ca-certificates wget -y
wget http://ftp.us.debian.org/debian/pool/main/l/lxc/liblxc1t64_6.0.5-1_amd64.deb
sudo apt install ./liblxc1t64_6.0.5-1_amd64.deb -y
rm liblxc1t64_6.0.5-1_amd64.deb
wget http://ftp.us.debian.org/debian/pool/main/l/lxc/liblxc-common_6.0.5-1_amd64.deb
sudo apt install ./liblxc-common_6.0.5-1_amd64.deb -y
rm liblxc-common_6.0.5-1_amd64.deb
wget http://ftp.us.debian.org/debian/pool/main/l/lxc/lxc_6.0.5-1_amd64.deb
sudo apt install ./lxc_6.0.5-1_amd64.deb -y
rm lxc_6.0.5-1_amd64.deb
curl -s https://repo.waydro.id | sudo bash
sudo apt update
sudo apt install waydroid -y
sudo ufw allow 53
sudo ufw allow 67
sudo ufw default allow FORWARD
