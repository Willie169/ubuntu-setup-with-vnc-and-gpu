cd ~
sudo apt update
sudo apt install curl ca-certificates wget liblxc1 liblxc-common lxc -y
curl -s https://repo.waydro.id | sudo bash
sudo apt update
sudo apt install waydroid -y
sudo ufw allow 53
sudo ufw allow 67
sudo ufw default allow FORWARD
echo "$HOME/.local/share/waydroid/data/media/0 /mnt/waydroid fuse rw,nosuid,nodev,relatime,user_id=0,group_id=0,default_permissions,allow_other 0 0" | sudo tee -a /etc/fstab >/dev/null
