cd ~
sudo apt install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev tor -y
git clone https://github.com/xmrig/xmrig.git
sed -i -e 's/keccak_f800_round(uint32_t st\[25\], const int r)/keccak_f800_round(__private uint32_t *st, const int r)/' -e 's/keccak_f800(uint32_t\* st)/keccak_f800(__private uint32_t *st)/' ~/xmrig/src/backend/opencl/cl/kawpow/kawpow.cl
mkdir xmrig/build
cd xmrig/build
cmake ..
make -j$(nproc)
curl -fsSL https://raw.githubusercontent.com/xmrig/xmrig/refs/heads/master/scripts/randomx_boost.sh | sudo sh
