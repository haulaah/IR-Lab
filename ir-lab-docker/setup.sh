#!/usr/bin/env bash
# =============================================================================
# IR Lab — one-shot setup script
# Preps the host, then brings up all four tools with a single docker compose up.
# Run from the folder containing docker-compose.yml:  ./setup.sh
# =============================================================================
set -euo pipefail

# Cortex launches analyzers as containers via the Docker socket, so its jobs
# directory must exist and use an identical host:container path (see compose).
CORTEX_JOBS_DIR="/home/lab/cortex/jobs"

echo "[*] IR Lab setup starting..."

# --- .env bootstrap ----------------------------------------------------------
# GitHub's web UI drops leading dots, so the repo ships "env.example" (no dot).
# Create the real .env from it on first run if it's missing.
if [ ! -f .env ]; then
  if [ -f env.example ]; then
    cp env.example .env
    echo "[*] Created .env from env.example."
  elif [ -f env ]; then          # in case it uploaded as "env"
    cp env .env
    echo "[*] Created .env from env."
  else
    echo "HOST_IP=localhost"                     >  .env
    echo "MISP_IMAGE=ghcr.io/nukib/misp:latest"  >> .env
    echo "[*] Created a default .env (HOST_IP=localhost)."
  fi
fi

# --- 0. sanity checks --------------------------------------------------------
if ! command -v docker >/dev/null 2>&1; then
  echo "[!] Docker is not installed or not on PATH. Install Docker first." >&2
  exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  echo "[!] 'docker compose' (v2) is required. Install the Compose plugin." >&2
  exit 1
fi

# --- 1. Elasticsearch kernel requirement -------------------------------------
# Both the TheHive and Cortex Elasticsearch containers need this or they crash.
CURRENT=$(sysctl -n vm.max_map_count 2>/dev/null || echo 0)
if [ "${CURRENT:-0}" -lt 262144 ]; then
  echo "[*] Raising vm.max_map_count to 262144 (needs sudo)..."
  sudo sysctl -w vm.max_map_count=262144
  if ! grep -q "vm.max_map_count" /etc/sysctl.conf 2>/dev/null; then
    echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf >/dev/null
    echo "    (persisted to /etc/sysctl.conf)"
  fi
else
  echo "[*] vm.max_map_count already OK ($CURRENT)."
fi

# --- 2. Cortex jobs directory ------------------------------------------------
if [ ! -d "$CORTEX_JOBS_DIR" ]; then
  echo "[*] Creating Cortex jobs directory at $CORTEX_JOBS_DIR (needs sudo)..."
  sudo mkdir -p "$CORTEX_JOBS_DIR"
  sudo chmod -R 777 "$CORTEX_JOBS_DIR"
else
  echo "[*] Cortex jobs directory already exists."
fi

# --- 3. pull + start ---------------------------------------------------------
echo "[*] Pulling images (first run can take a while)..."
docker compose pull

echo "[*] Starting all services..."
docker compose up -d

# --- 4. summary --------------------------------------------------------------
cat <<'EOF'

[+] IR Lab is starting. First boot can take several minutes while databases
    initialize and TheHive migrates its schema.

  TheHive     -> http://localhost:9000    (admin@thehive.local / secret)
  Cortex      -> http://localhost:9001    (create super-admin on first visit)
  MISP        -> http://localhost:8080    (admin@admin.test / admin)
  Mattermost  -> http://localhost:8065    (create admin on first visit)

  Status :  docker compose ps
  Logs   :  docker compose logs -f <service>
  Stop   :  docker compose stop
  Reset  :  docker compose down -v        (deletes all data)

  Integration (now that everything is on one network, use service names):
    TheHive  -> Cortex : http://cortex:9001
    TheHive  -> MISP   : http://misp
    Cortex   -> MISP   : http://misp

EOF
