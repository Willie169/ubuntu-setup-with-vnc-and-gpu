sudo apt autoremove --purge *nvidia* cuda* libcublas-* libcublas-dev-* libcufile-* libcuobjclient-* libcurand-* libcurand-dev-* libcusolver-* libcusolver-dev-* libcusparse-* libcusparse-* libcusparse-dev-* libnpp-* libnpp-dev-* libnvfatbin-* libnvjitlink-* libnvvm-* libcufft-* libcufft-dev-* libcufile-dev-* libcuobjclient-dev-* libnvfatbin-dev-* libnvjitlink-dev-* libnvjpeg-* libnvjpeg-dev-* -y
echo y | sudo ubuntu-drivers install || true
echo y | sudo ubuntu-drivers install || true
echo y | sudo ubuntu-drivers install || true
echo y | sudo ubuntu-drivers autoinstall || true
echo y | sudo ubuntu-drivers autoinstall || true
echo y | sudo ubuntu-drivers autoinstall || true
sudo apt install wget -y
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo apt install ./cuda-keyring_1.1-1_all.deb -y
rm cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt install cuda-toolkit libnvidia-egl-wayland1 -y
