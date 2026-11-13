# MongoDB Compass in the browser (Docker POC)

Runs the **official MongoDB Compass desktop app** inside a container and streams it
to any web browser. No Compass install is needed on the client machine.

| Component      | Version                                   |
|----------------|-------------------------------------------|
| Base image     | Ubuntu 24.04 LTS (Noble)                  |
| MongoDB Compass| 1.53.2 (stable)                           |
| MongoDB server | 8.0 (major / long-term-supported release) |
| Browser access | noVNC + websockify (Ubuntu LTS packages)  |

## How it works

```
Browser ──http/ws :8080──▶ noVNC/websockify :6080 ──▶ TigerVNC (virtual X display :1)
                                                         └─ Openbox ─ MongoDB Compass ──▶ mongo:27017
```

Compass is an Electron desktop app with no web server of its own, so it runs on
a virtual display inside the container. noVNC streams that display to the browser.
`supervisord` runs the four processes and restarts Compass if its window is closed.

## Quick start

```powershell
Copy-Item .env.example .env      # bash: cp .env.example .env  (then change the passwords)
docker compose up -d --build
```

Open **http://localhost:8080** and enter the password from `.env` (`VNC_PASSWORD`, default `compass1`).
Compass opens already connected to the bundled MongoDB, which has a sample `poc_shop` database.
On the first launch, click **Start** on the Welcome dialog. This is remembered.

## Configuration (`.env`, copied from `.env.example`; not committed)

| Variable              | Default    | Purpose                                          |
|-----------------------|------------|--------------------------------------------------|
| `COMPASS_VERSION`     | `1.53.2`   | Compass release baked into the image             |
| `MONGO_VERSION`       | `8.0`      | MongoDB server image tag                         |
| `COMPASS_PORT`        | `8080`     | Host port for the browser UI                     |
| `VNC_PASSWORD`        | `compass1` | Browser login password (first 8 chars used); empty disables it |
| `VNC_RESOLUTION`      | `1600x900` | Initial screen size (the browser tab resizes it) |
| `MONGO_ROOT_USERNAME` / `MONGO_ROOT_PASSWORD` | `admin` / `admin123` | MongoDB root user |

To connect Compass to a different cluster, change `COMPASS_CONNECTION_STRING` in
`docker-compose.yml` or remove it to start on the connection screen. You can also add
connections inside Compass. They are saved in the `compass-config` volume.

## Useful commands

```powershell
docker compose logs -f compass                         # container logs
docker exec poc-compass supervisorctl -c /etc/supervisor/compass.conf status
docker exec poc-compass supervisorctl -c /etc/supervisor/compass.conf restart compass
docker compose down                                    # stop (keeps data volumes)
docker compose down -v                                 # stop and delete data + Compass profile
```

To upgrade Compass, set `COMPASS_VERSION` in `.env` to a newer release from
https://github.com/mongodb-js/compass/releases, then run `docker compose up -d --build`.

## Files

```
docker-compose.yml          mongo + compass services, volumes, port mapping
.env.example                template for .env (versions, ports, passwords)
mongo-init/seed.js          sample data, loaded on the first MongoDB start
compass/Dockerfile          Ubuntu 24.04 + TigerVNC + noVNC + Openbox + Compass
compass/launch.sh           starts xvnc | openbox | compass | novnc
compass/entrypoint.sh       writes the VNC password, starts supervisord
compass/supervisord.conf    process supervision, logs to docker logs
compass/mongodb-compass.conf  Compass global settings (auto-update and telemetry off)
compass/index.html          redirects / to the auto-connecting noVNC page
```

## Notes and limits (POC)

- **Security:** traffic is plain HTTP and VNC auth is weak (8-char password). Before
  sharing beyond your machine, put it behind a reverse proxy with TLS and real auth
  (e.g. Traefik/nginx + OAuth), or bind the port to localhost: `"127.0.0.1:8080:6080"`.
- **One shared session:** everyone who opens the URL sees and controls the same Compass window.
- **Clipboard:** use the clipboard panel in the noVNC sidebar to paste into Compass.
- **amd64 only:** Compass publishes Linux builds for x86_64 only.
- Compass runs with `--no-sandbox` (normal for Electron in containers) as the non-root user `compass`.
