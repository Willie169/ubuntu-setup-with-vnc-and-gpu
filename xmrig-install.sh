cd ~
sudo apt install build-essential cmake git libuv1-dev msr-tools ocl-icd-opencl-dev opencl-headers openssl tor -y
git clone https://github.com/xmrig/xmrig.git
mkdir xmrig/build
cd xmrig/build
cmake ..
make -j$(nproc)
curl -fsSL https://raw.githubusercontent.com/xmrig/xmrig/refs/heads/master/scripts/randomx_boost.sh | sudo bash
