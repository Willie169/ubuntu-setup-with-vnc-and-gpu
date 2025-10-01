cd ~
sudo apt update
sudo apt install curl ca-certificates -y
wget -q http://ftp.us.debian.org/debian/pool/main/l/lxc/lxc_6.0.4-4+b3_amd64.deb
sudo dpkg -i lxc_6.0.4-4+b3_amd64.deb
rm lxc_6.0.4-4+b3_amd64.deb
curl -s https://repo.waydro.id | sudo bash
sudo apt update
sudo apt install waydroid -y
sudo ufw allow 53
sudo ufw allow 67
sudo ufw default allow FORWARD
