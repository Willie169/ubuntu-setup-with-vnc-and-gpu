#!/bin/bash
cd ~ || exit
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install debconf-utils mesa-utils wget xfce4 xfce4-goodies -y
wget -q -O- https://packagecloud.io/dcommander/virtualgl/gpgkey | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/VirtualGL.gpg
sudo wget https://raw.githubusercontent.com/VirtualGL/repo/main/VirtualGL.list -O /etc/apt/sources.list.d/VirtualGL.list
wget -q -O- https://packagecloud.io/dcommander/turbovnc/gpgkey | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/TurboVNC.gpg
sudo wget https://raw.githubusercontent.com/TurboVNC/repo/main/TurboVNC.list -O /etc/apt/sources.list.d/TurboVNC.list
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install virtualgl turbovnc -y
sudo vglserver_config +s +f +glx
sudo groupadd vglusers
sudo usermod -aG vglusers root
sudo usermod -aG vglusers "$USER"
sudo mkdir -p /etc/opt/VirtualGL
sudo chgrp vglusers /etc/opt/VirtualGL
sudo chmod 750 /etc/opt/VirtualGL
mkdir -p ~/.vnc
cat > ~/.vnc/xstartup.turbovnc <<EOF
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
startxfce4 &
EOF
sudo reboot
