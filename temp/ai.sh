uv tool install --force --python python3.11 open-webui@latest
cat > ~/.config/systemd/user/open-webui.service <<EOF
[Unit]
Description=Open WebUI

[Service]
ExecStart=$HOME/.local/bin/open-webui serve
Environment=DATA_DIR=$HOME/.open-webui
Environment=OLLAMA_BASE_URL=http://127.0.0.1:11434
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now open-webui



mkdir ~/.open-notebook
cat > ~/.open-notebook/docker-compose.yml<<EOF
services:
  surrealdb:
    image: surrealdb/surrealdb:v2
    command: start --log info --user root --pass root rocksdb:/mydata/mydatabase.db
    user: root
    network_mode: host
    volumes:
      - ./surreal_data:/mydata
    restart: always

  open_notebook:
    image: lfnovo/open_notebook:v1-latest
    network_mode: host
    environment:
      - OPEN_NOTEBOOK_ENCRYPTION_KEY=change-me-to-a-secret-string
      - SURREAL_URL=ws://localhost:8000/rpc
      - SURREAL_USER=root
      - SURREAL_PASSWORD=root
      - SURREAL_NAMESPACE=open_notebook
      - SURREAL_DATABASE=open_notebook
      - OLLAMA_API_BASE=http://localhost:11434
    volumes:
      - ./notebook_data:/app/data
    depends_on:
      - surrealdb
    restart: always
EOF
cd ~/.open-notebook || exit
docker compose up -d
cd ~ || exit




mkdir -p ~/dev/llm
cd ~/dev/llm || exit
git clone --depth=1 https://github.com/KhronosGroup/OpenCL-Headers && cd OpenCL-Headers || exit
mkdir build && cd build || exit
cmake .. -G Ninja \
  -DBUILD_TESTING=OFF \
  -DOPENCL_HEADERS_BUILD_TESTING=OFF \
  -DOPENCL_HEADERS_BUILD_CXX_TESTS=OFF \
  -DCMAKE_INSTALL_PREFIX="$HOME/dev/llm/opencl"
cmake --build . --target install
cd ~/dev/llm || exit
git clone --depth=1 https://github.com/KhronosGroup/OpenCL-ICD-Loader && cd OpenCL-ICD-Loader || exit
mkdir build && cd build || exit
cmake .. -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="$HOME/dev/llm/opencl" \
  -DCMAKE_INSTALL_PREFIX="$HOME/dev/llm/opencl"
cmake --build . --target install
cd ~/dev/llm || exit
git clone --depth=1 https://github.com/ggml-org/llama.cpp && cd llama.cpp || exit
mkdir build && cd build || exit
cmake .. -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="$HOME/dev/llm/opencl" \
  -DBUILD_SHARED_LIBS=OFF \
  -DGGML_OPENCL=ON
ninja
cd ~ || exit


mkdir ~/.litellm
cd ~/.litellm || exit
cat ~/API_KEY.sh | grep LITELLM_MASTER_KEY >> .env || true
cat ~/API_KEY.sh | grep LITELLM_SALT_KEY >> .env || true
cat ~/API_KEY.sh | grep OPENAI_API_KEY >> .env || true
cat ~/API_KEY.sh | grep ANTHROPIC_API_KEY >> .env || true
cat ~/API_KEY.sh | grep GEMINI_API_KEY >> .env || true
cat ~/API_KEY.sh | grep DEEPSEEK_API_KEY >> .env || true
cat ~/API_KEY.sh | grep OPENROUTER_API_KEY >> .env || true
cat ~/API_KEY.sh | grep MISTRAL_API_KEY >> .env || true
source .env
curl --retry 100 --retry-connrefused --retry-delay 5 -fsSLO https://raw.githubusercontent.com/BerriAI/litellm/refs/heads/main/prometheus.yml
cat > docker-compose.yml <<'EOF'
services:
  litellm:
    build:
      context: .
      args:
        target: runtime
    image: docker.litellm.ai/berriai/litellm:main-stable
    volumes:
      - ./config.yaml:/app/config.yaml
    command:
      - "--config=/app/config.yaml"
    extra_hosts:
      - "host.docker.internal:host-gateway"
    ports:
      - "4000:4000" # Map the container port to the host, change the host port if necessary
    environment:
      DATABASE_URL: "postgresql://llmproxy:dbpassword9090@db:5432/litellm"
      STORE_MODEL_IN_DB: "True" # allows adding models to proxy via UI
    env_file:
      - .env # Load local .env file
    depends_on:
      - db  # Indicates that this service depends on the 'db' service, ensuring 'db' starts first
    healthcheck:  # Defines the health check configuration for the container
      test:
        - CMD-SHELL
        - python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:4000/health/liveliness')"  # Command to execute for health check
      interval: 30s  # Perform health check every 30 seconds
      timeout: 10s   # Health check command times out after 10 seconds
      retries: 3     # Retry up to 3 times if health check fails
      start_period: 40s  # Wait 40 seconds after container start before beginning health checks

  db:
    image: postgres:16
    restart: always
    container_name: litellm_db
    environment:
      POSTGRES_DB: litellm
      POSTGRES_USER: llmproxy
      POSTGRES_PASSWORD: dbpassword9090
    volumes:
      - postgres_data:/var/lib/postgresql/data # Persists Postgres data across container restarts
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -d litellm -U llmproxy"]
      interval: 1s
      timeout: 5s
      retries: 10

  prometheus:
    image: prom/prometheus
    volumes:
      - prometheus_data:/prometheus
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
      - "--storage.tsdb.path=/prometheus"
      - "--storage.tsdb.retention.time=15d"
    restart: always

volumes:
  prometheus_data:
    driver: local
  postgres_data:
    name: litellm_postgres_data # Named volume for Postgres data persistence
EOF
cat > ~/.litellm/config.yaml <<'EOF'
environment_variables:
    LITELLM_SALT_KEY: os.environ/LITELLM_SALT_KEY

model_list:
    - model_name: openai/*
      litellm_params:
        model: openai/*
        api_key: os.environ/OPENAI_API_KEY
    - model_name: anthropic/*
      litellm_params:
        model: anthropic/*
        api_key: os.environ/ANTHROPIC_API_KEY
    - model_name: gemini/*
      litellm_params:
        model: gemini/*
        api_key: os.environ/GEMINI_API_KEY
    - model_name: deepseek/*
      litellm_params:
        model: deepseek/*
        api_key: os.environ/DEEPSEEK_API_KEY
    - model_name: openrouter/*
      litellm_params:
        model: openrouter/*
        api_key: os.environ/OPENROUTER_API_KEY
    - model_name: mistral/*
      litellm_params:
        model: mistral/*
        api_key: os.environ/MISTRAL_API_KEY

litellm_settings:
    check_provider_endpoint: true

general_settings:
    master_key: os.environ/LITELLM_MASTER_KEY
EOF
docker compose up -d
cd ~ || exit
cat > ~/.config/systemd/user/litellm.service <<EOF
[Unit]
Description=LiteLLM
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
WorkingDirectory=$HOME/.litellm
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
RemainAfterExit=yes

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable --now litellm
