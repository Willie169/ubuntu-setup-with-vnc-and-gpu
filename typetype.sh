#!/usr/bin/env bash

set -euxo pipefail
mkdir ~/typetype-stack
cat >~/typetype-stack/.env <<'EOF'
ALLOWED_ORIGINS=http://localhost:9082,http://127.0.0.1:9082,http://localhost:5173,http://127.0.0.1:5173
HOST_PORT_WEB=9082
HOST_BIND_SERVER=127.0.0.1
HOST_PORT_SERVER=9080
HOST_BIND_TOKEN=127.0.0.1
HOST_PORT_TOKEN=9081
HOST_BIND_GARAGE_S3=127.0.0.1
HOST_PORT_GARAGE_S3=3900
EOF
curl -fsSL https://raw.githubusercontent.com/TypeType-Video/TypeType/main/scripts/install-stack.sh | bash -s -- --yes --download-only
cd ~/typetype-stack || exit
sudo docker compose -f docker-compose.yml pull
cd ~ || exit
mkdir -p ~/.config/systemd/user
cat >~/.config/systemd/user/typetype.service <<EOF
[Unit]
Description=TypeType
After=docker.service

[Service]
WorkingDirectory=${HOME}/typetype-stack
ExecStart=/usr/bin/docker compose -f docker-compose.yml --env-file .env up
ExecStop=/usr/bin/docker compose -f docker-compose.yml stop
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now typetype
