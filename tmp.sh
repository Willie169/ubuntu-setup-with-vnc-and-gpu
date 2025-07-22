cat << 'EOF' > ~/.installtmp.sh
#!/bin/bash
sudo systemctl --user disable installtmp.service
rm ~/.config/systemd/user/installtmp.service
rm -- "$0"
echo 'test'
EOF
chmod +x ~/.installtmp.sh
mkdir -p ~/.config/systemd/user
cat << EOF > ~/.config/systemd/user/installtmp.service
[Unit]
Description=Installation Temporary
After=network.target

[Service]
ExecStart="$PREFIX"/.installtmp.sh
Type=oneshot
RemainAfterExit=no

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable installtmp.service
sudo reboot