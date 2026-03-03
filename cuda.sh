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
rm cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt install cuda-toolkit libnvidia-egl-wayland1 -y
sudo apt autoremove -y
