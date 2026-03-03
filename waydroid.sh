cd ~
sudo apt update
sudo apt install curl ca-certificates wget liblxc1 liblxc-common lxc -y
curl -s https://repo.waydro.id | sudo bash
sudo apt update
sudo apt install waydroid -y
sudo ufw allow 53
sudo ufw allow 67
sudo ufw default allow FORWARD
