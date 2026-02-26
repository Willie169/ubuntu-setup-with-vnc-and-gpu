cd ~
sudo apt install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev tor -y
git clone https://github.com/Willie169/xmrig.git
mkdir ~/xmrig/build
cd ~/xmrig/build
cmake ..
make -j$(nproc)
curl -fsSL https://raw.githubusercontent.com/xmrig/xmrig/refs/heads/master/scripts/randomx_boost.sh | sudo sh
