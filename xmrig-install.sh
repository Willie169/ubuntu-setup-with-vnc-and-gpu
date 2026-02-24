cd ~
source .bashrc.d/50-functions.sh
gh_latest xmrig/xmrig xmrig-*-linux-static-x64.tar.gz
tar -xzf xmrig-*-linux-static-x64.tar.gz
rm xmrig-*-linux-static-x64.tar.gz
mv xmrig-* xmrig
