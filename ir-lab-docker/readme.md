# IR Lab

 **A simulated incident response (IR) environment** 

## The stack

| Tool          | Image                            | Role                                                    |
|---------------|----------------------------------|---------------------------------------------------------|
| **TheHive**   | `strangebee/thehive:5.2`         | Case management system: cases, case tasks, observables etc |
| **Cortex**    | `thehiveproject/cortex:3.1.1`    | Observables analysis: runs analysers/responders on IoCs      |
| **MISP**      | `ghcr.io/nukib/misp`             | Threat intelligence: storing/sharing/correlating security events, IoCs   |
| **Mattermost**| `mattermost-team-edition:10.11`  | Team chat: participant communication during the response|

All four tools (and their databases) share one Docker network, so they reach each other by name
(e.g. `http://cortex:9001`) which is what makes the integrations work.


## Prerequisite: install Docker

If Docker and the Compose plugin are not installed yet, run this once on the Ubuntu host:

```bash
sudo apt update && sudo apt upgrade -y && \
sudo apt install -y ca-certificates curl gnupg lsb-release && \
sudo mkdir -p /etc/apt/keyrings && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
sudo chmod a+r /etc/apt/keyrings/docker.gpg && \
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
sudo apt update && \
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
sudo usermod -aG docker $USER && \
echo "Docker installed."
```

Then apply the docker group and verify:

```bash
newgrp docker            # or log out and back in
docker run hello-world   # should print "Hello from Docker!"
```

## Quick start

```bash
git clone https://github.com/haulaah/IR-Lab.git
cd ir-lab-docker
chmod +x setup.sh   
./setup.sh
```

`setup.sh` sets the Elasticsearch kernel parameter (`vm.max_map_count`), creates the Cortex jobs
directory, pulls the images, and runs `docker compose up -d`. First boot takes a few minutes while
databases initialise.


## Configuration

Compose auto-loads `.env`, which holds the only machine-specific value:

```
HOST_IP=localhost
```

- **Local testing:** leave it as `localhost`.
- **Public server:** set `HOST_IP` to the server's IP/hostname so MISP and Mattermost generate
  correct links and redirects. You can also override without editing the file:
  `export HOST_IP=<your-ip>` before `./setup.sh`.

All other settings (tool passwords, ports) live in `docker-compose.yml`.

## Access & credentials

Replace `<HOST>` with `localhost` (local) or your server IP.

| Tool        | URL                   | First login                        |
|-------------|-----------------------|------------------------------------|
| TheHive     | `http://<HOST>:9000`  | `admin@thehive.local` / `secret`   |
| Cortex      | `http://<HOST>:9001`  | `superadmin` / `Changeme123`  |
| MISP        | `http://<HOST>:8080`  | `admin@admin.test` / `admin`       |
| Mattermost  | `http://<HOST>:8065`  | create admin on first visit        |

Other published ports: Cassandra `9042`, TheHive Elasticsearch `9200`, MinIO console `9090`,
MISP ZeroMQ `50000` (localhost), Mattermost calls `8443`.

## Connecting the tools

Use **service names** internally (everything is on one network):

1. **Cortex** : create the super-admin, an org, and a user; enable the analyzers you want;
   generate a **Cortex API key**.
2. **TheHive → Cortex** : add `http://cortex:9001` and the API key in TheHive.
3. **Cortex / TheHive → MISP** : create a MISP **Auth Key**, then add `http://misp` + the key to
   Cortex (MISP analyzer) and/or TheHive (import events as alerts).

## Managing / resetting

```bash
docker compose ps            # status
docker compose logs -f NAME  # logs for one service
docker compose stop          # pause (keeps data)
docker compose start         # resume
docker compose down -v       # FULL RESET — wipes all data for a fresh participant run
```

## Deploying to a public server

The lab runs the same on any Ubuntu VM. Beyond `./setup.sh`, you only need to:

1. Set `HOST_IP` to the server's public IP (see Configuration).
2. Open the firewall for TCP `9000, 9001, 8080, 8065` 


