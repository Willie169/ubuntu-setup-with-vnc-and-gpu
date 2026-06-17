# Snapper and grub-btrfs

## Install
Here, grub-btrfs and its dependencies from Kali Linux are allowed to receive future updates, while all other packages from Kali Linux are blocked to prevent breaking system. You can also build from [source](https://github.com/Antynea/grub-btrfs).
```
sudo apt update
sudo apt install gnupg snapper wget -y
wget -qO - https://archive.kali.org/archive-key.asc | sudo gpg --dearmor -o /etc/apt/keyrings/kali.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kali.gpg] http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware' | sudo tee /etc/apt/sources.list.d/kali.list >/dev/null
echo 'Package: grub-btrfs btrfs-progs grub2-common gawk
Pin: origin http.kali.org
Pin-Priority: 500

Package: *
Pin: origin http.kali.org
Pin-Priority: -1' | sudo tee /etc/apt/preferences.d/kali >/dev/null
sudo apt update
sudo apt install grub-btrfs -y
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer
```

sudo cat /etc/snapper/configs/root
snapper -c root list-configs
systemctl status snapper-timeline.timer
systemctl status snapper-cleanup.timer
sudo systemctl status grub-btrfsd