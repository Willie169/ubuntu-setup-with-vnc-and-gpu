cd ~/xmrig/build
if ! ss -ltnp 2>/dev/null | grep -q ':9054.*tor'; then
rm -r .tor 2>/dev/null || true
mkdir .tor
cat > .tor/torrc <<'EOF'
SocksPort 9054
DataDirectory .tor
EOF
tor -f .tor/torrc &
TORPID=$!
trap 'kill $TORPID; rm -r ~/xmrig/build/.tor' EXIT
fi
./xmrig -a kawpow -o rvn.2miners.com:6060 -u RCo4QqzEnEtEVv749TJfNz293p2xVVhXFx -p x -k -x 127.0.0.1:9054 --opencl --opencl-platform=0
