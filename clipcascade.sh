#!/usr/bin/env bash

PORT=${1:-8082}
cd ~ || exit
gh_release -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' Sathvik-Rao/ClipCascade ClipCascade-Server-JRE_21.jar
cat >~/.config/systemd/user/clipcascade-server.service <<EOF
[Unit]
Description=ClipCascade Server
After=network.target

[Service]
Type=simple
ExecStart=java -jar $HOME/ClipCascade-Server-JRE_21.jar
Restart=always
RestartSec=5
Environment=CC_PORT=$PORT

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now clipcascade-server
sudo ufw allow "$PORT"/tcp
sudo ufw reload
gh_release -w --wget_option '--tries=100 --retry-connrefused --waitretry=5' Sathvik-Rao/ClipCascade ClipCascade_Linux.tar.xz
tar -xJf ClipCascade_Linux.tar.xz
rm ClipCascade_Linux.tar.xz*
cat >~/.config/systemd/user/clipcascade-client.service <<EOF
[Unit]
Description=ClipCascade Client
Requires=clipcascade-server.service
After=clipcascade-server.service

[Service]
Type=simple
WorkingDirectory=$HOME/ClipCascade
ExecStartPre=/bin/bash -c '(while ! nc -z -w1 localhost $PORT 2>/dev/null; do sleep 2; done); sleep 2'
ExecStart=/usr/bin/python3 $HOME/ClipCascade/main.py
Restart=always
RestartSec=5
Environment=PYTHONUNBUFFERED=1
Environment=CC_PORT=$PORT

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now clipcascade-client
