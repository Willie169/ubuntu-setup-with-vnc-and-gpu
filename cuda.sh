#!/bin/bash
cd ~ || exit
cat /etc/default/grub | grep GRUB_CMDLINE_LINUX_DEFAULT | grep -q 'nvidia_drm.modeset=1' && sudo sed -Ei "s/^GRUB_CMDLINE_LINUX_DEFAULT='(.*)'[ \t ]*/GRUB_CMDLINE_LINUX_DEFAULT='\1 nvidia_drm.modeset=1'/" /etc/default/grub
sudo apt install wget -y
sudo apt remove --purge ^.*nvidia.* ^cuda.* -y
sudo apt autoremove -y
echo y | sudo ubuntu-drivers install || true
echo y | sudo ubuntu-drivers install || true
echo y | sudo ubuntu-drivers install || true
echo y | sudo ubuntu-drivers autoinstall || true
echo y | sudo ubuntu-drivers autoinstall || true
echo y | sudo ubuntu-drivers autoinstall || true
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo apt install ./cuda-keyring_1.1-1_all.deb -y
rm cuda-keyring_1.1-1_all.deb*
sudo apt update
sudo apt install cuda-toolkit -y
sudo apt autoremove -y
sudo reboot