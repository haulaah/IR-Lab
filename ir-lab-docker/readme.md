# IR Lab

A **simulated incident response (IR) environment** 

## The stack

| Tool          | Image                            | Role                                                    |
|---------------|----------------------------------|---------------------------------------------------------|
| **TheHive**   | `strangebee/thehive:5.2`         | Case management system: cases, case tasks, oobservables etc |
| **Cortex**    | `thehiveproject/cortex:3.1.1`    | Observables analysis: runs analysers/responders on IoCs      |
| **MISP**      | `ghcr.io/nukib/misp`             | Threat intelligence: storing/sharing/correlating security eventnts, IoCs   |
| **Mattermost**| `mattermost-team-edition:10.11`  | Team chat: participant communication during the response|

All four tools (and their databases) share one Docker network, so they reach each other by name
(e.g. `http://cortex:9001`) which is what makes the integrations work.

## Quick start

```bash
cd ir-lab-docker
chmod +x setup.sh   # make the script executable (needed after a fresh clone/upload)
./setup.sh
```

`setup.sh` sets the Elasticsearch kernel parameter (`vm.max_map_count`), creates the Cortex jobs
directory, pulls the images, and runs `docker compose up -d`. First boot takes a few minutes while
databases initialize and TheHive migrates its schema.

Manual alternative:
```bash
sudo sysctl -w vm.max_map_count=262144
sudo mkdir -p /home/lab/cortex/jobs && sudo chmod -R 777 /home/lab/cortex/jobs
docker compose up -d
```

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
| Cortex      | `http://<HOST>:9001`  | create super-admin on first visit  |
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
4. **Mattermost** — create the channels participants will use.

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
2. Open the firewall for TCP `9000, 9001, 8080, 8065` (and `8443` if using Mattermost calls),
   ideally restricted to the source networks your participants use.


