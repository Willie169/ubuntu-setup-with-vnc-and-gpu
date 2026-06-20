mkdir ~/stirlingpdf
cd ~/stirlingpdf || exit
cat > docker-compose.yml <<'EOF'
services:
  stirling-pdf:
    image: stirlingtools/stirling-pdf:latest
    ports:
      - '8083:8080'
    volumes:
      - ./stirling-data/tessdata:/usr/share/tessdata
      - ./stirling-data/configs:/configs
      - ./stirling-data/logs:/logs
      - ./stirling-data/pipeline:/pipeline
    environment:
      - DOCKER_ENABLE_SECURITY=false
      - INSTALL_BOOK_AND_ADVANCED_HTML_OPS=true
      - LANGS=en_GB
    restart: unless-stopped
EOF
docker compose up -d
cd ~ || exit
