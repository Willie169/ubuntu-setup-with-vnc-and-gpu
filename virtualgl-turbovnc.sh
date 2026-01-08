cd ~
sudo apt update
sudo apt install wget -y
wget -q https://launchpad.net/ubuntu/+archive/primary/+files/libegl1-mesa_23.0.4-0ubuntu1~22.04.1_amd64.deb
sudo dpkg -i libegl1-mesa_23.0.4-0ubuntu1~22.04.1_amd64.deb
rm libegl1-mesa_23.0.4-0ubuntu1~22.04.1_amd64.deb
wget -q https://sourceforge.net/projects/virtualgl/files/3.1/virtualgl_3.1_amd64.deb
sudo dpkg -i virtualgl_3.1_amd64.deb
rm virtualgl_3.1_amd64.deb
wget -q https://sourceforge.net/projects/turbovnc/files/3.1/turbovnc_3.1_amd64.deb
sudo dpkg -i turbovnc_3.1_amd64.deb
rm turbovnc_3.1_amd64.deb
wget -q https://sourceforge.net/projects/libjpeg-turbo/files/3.0.1/libjpeg-turbo-official_3.0.1_amd64.deb
sudo dpkg -i libjpeg-turbo-official_3.0.1_amd64.deb
rm libjpeg-turbo-official_3.0.1_amd64.deb
sudo apt install dbus-x11 libglu1-mesa mesa-utils -y
sudo vglserver_config +s +f +glx
sudo groupadd vglusers
sudo usermod --groups vglusers root
sudo usermod --groups vglusers $USER
sudo mkdir -p /etc/opt/VirtualGL
sudo chgrp vglusers /etc/opt/VirtualGL
sudo chmod 750 /etc/opt/VirtualGL
cat >> ~/.bashrc <<"EOF"
alias vncserver="/opt/TurboVNC/bin/vncserver"
EOF
source ~/.bashrc
