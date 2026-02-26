cd ~
sudo apt install build-essential cmake git libuv1-dev msr-tools ocl-icd-opencl-dev opencl-headers openssl tor -y
git clone https://github.com/xmrig/xmrig.git
# sed -i 's/keccak_f800_round(uint32_t st\[25\], const int r)/keccak_f800_round(__generic uint32_t st\[25\], const int r)/' xmrig/src/backend/opencl/cl/kawpow/kawpow.cl
mkdir xmrig/build
cd xmrig/build
cmake ..
make -j$(nproc)
curl -fsSL https://raw.githubusercontent.com/xmrig/xmrig/refs/heads/master/scripts/randomx_boost.sh | sudo sh
