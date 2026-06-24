#!/bin/bash

cd ~
sudo apt update
sudo apt install dbus-x11 libglu1-mesa mesa-utils wget -y
wget --tries=100 --retry-connrefused --waitretry=5 https://raw.githubusercontent.com/Willie169/bashrc/main/ubuntu-amd/bashrc.d/50-functions.sh
source 50-functions.sh
rm 50-functions.sh*
gh_latest VirtualGL/virtualgl 'virtualgl_*_amd64.deb'
sudo apt install virtualgl_*_amd64.deb
rm virtualgl_*_amd64.deb*
gh_latest TurboVNC/turbovnc 'turbovnc_*_amd64.deb'
sudo apt install turbovnc_*_amd64.deb
rm turbovnc_*_amd64.deb*
sudo vglserver_config +s +f +glx
sudo groupadd vglusers
sudo usermod -aG vglusers root
sudo usermod -aG vglusers $USER
sudo mkdir -p /etc/opt/VirtualGL
sudo chgrp vglusers /etc/opt/VirtualGL
sudo chmod 750 /etc/opt/VirtualGL
