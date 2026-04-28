# Embedded example usage

## Overview

This image demonstrates the embedded-client pattern:

- `portflare daemon` runs in the background
- your application runs as the main process
- the client discovers the app and registers it with Portflare

See also:

- [`github.com/portflare/client`](https://github.com/portflare/client)
- [`github.com/portflare/server`](https://github.com/portflare/server)
- [`github.com/portflare/protocol`](https://github.com/portflare/protocol)

## Default settings

- local app port: `3000`
- discovered app name: `web`
- local client API: `127.0.0.1:9901`
- default upstream client image: `ghcr.io/portflare/client:latest`

## Required environment variables

```bash
export PORTFLARE_SERVER_URL=https://r.myw.io
export PORTFLARE_CLIENT_KEY=pf_your_key_here
```

## Build with a pinned client image

```bash
docker build \
  --build-arg CLIENT_IMAGE=ghcr.io/portflare/client:v0.1.1 \
  -t ghcr.io/portflare/client-embedded-example:dev .
```

## Run locally

```bash
docker run --rm -p 3000:3000 \
  -e PORTFLARE_SERVER_URL=https://r.myw.io \
  -e PORTFLARE_CLIENT_KEY=pf_your_key_here \
  ghcr.io/portflare/client-embedded-example:dev
```

## Swap the sample app out

Replace the final stage app setup in `Dockerfile` and keep `bin/embedded-entrypoint.sh` as the entrypoint pattern.

The important part is that your app listens on the port allowed by:

```bash
PORTFLARE_CLIENT_DISCOVER_ALLOW=3000
PORTFLARE_CLIENT_DISCOVER_NAMES=3000=web
```

If your real app uses a different port or name, update those environment variables to match.

## FAQ

### Why did `docker compose config` fail?

`docker compose config` requires Docker Compose v2, usually installed as the Docker CLI plugin. If Docker itself is installed but the plugin is missing, validation fails before Portflare is involved. Install the Compose plugin or validate on a host that has `docker compose` available.

### Where should I put `PORTFLARE_CLIENT_KEY`?

For Compose deployments, put it in a local `.env` file and do not commit it:

```env
PORTFLARE_CLIENT_KEY=pf_your_key_here
```

If a real key is pasted into chat, logs, or a public issue, treat it as compromised and rotate it from the Portflare user page.

### Does `docker run my-app` also start a Portflare sidecar?

No. `docker run` starts exactly one container. A Compose sidecar only starts when you run the Compose project:

```bash
docker compose up -d --build
```

To use `docker run`, either run an embedded client inside the app container or start a separate Portflare container manually.

### What is the difference between embedded mode and sidecar mode?

Embedded mode runs the app and `portflare daemon` in the same container. This gives the client the same `localhost` and process/network view as the app, so discovery is straightforward.

Sidecar mode runs Portflare in a separate container. If you want localhost-style discovery, start the sidecar with the app container's network namespace:

```bash
docker run -d \
  --name my-app-portflare \
  --network container:my-app \
  -e PORTFLARE_SERVER_URL=https://r.myw.io \
  -e PORTFLARE_CLIENT_KEY \
  -e PORTFLARE_CLIENT_LISTEN_ADDR=127.0.0.1:9901 \
  -e PORTFLARE_CLIENT_DISCOVER=true \
  -e PORTFLARE_CLIENT_DISCOVER_ALLOW=3000,8080,9000-9100 \
  -e PORTFLARE_CLIENT_DISCOVER_NAMES=3000=web,8080=admin \
  -v "$HOME/.config/portflare-client:/state" \
  ghcr.io/portflare/client:latest
```

### Should my app listen on `localhost` or `0.0.0.0`?

If Portflare is embedded in the same container or shares the app container network namespace with `--network container:<app>`, `localhost` / `127.0.0.1` is fine.

If Portflare is a separate container on a Docker bridge network, the app must listen on `0.0.0.0:<port>` so other containers can reach it. This does not publish the port to the host unless you also use Docker `ports:` or `-p`.

### Why did discovery not find my app in another container?

Discovery reads listening ports from the client's own network namespace and registers targets such as `http://127.0.0.1:<port>`. It does not inspect every other Docker container. For automatic discovery, run the client embedded or with `--network container:<app>`.

For a shared Portflare client, use explicit targets on a shared Docker network instead:

```bash
docker network create portflare-shared

docker run -d --network portflare-shared --name app-a my-app-a
docker run -d --network portflare-shared --name portflare \
  -e PORTFLARE_SERVER_URL=https://r.myw.io \
  -e PORTFLARE_CLIENT_KEY \
  -e PORTFLARE_CLIENT_LISTEN_ADDR=0.0.0.0:9901 \
  ghcr.io/portflare/client:latest

portflare expose --app app-a-web --target http://app-a:3000
```

### Can one sidecar serve all my Docker containers?

Not when using `--network container:<app>`. That mode shares exactly one container's network namespace.

Use one sidecar per app container if you want automatic discovery and `localhost` targets. Use one shared Portflare client only when all apps are reachable over a shared Docker network and you register explicit targets like `http://app-name:3000`.

### Will Docker stop the sidecar when the app exits?

Not automatically in plain Docker or Compose. `depends_on` controls startup order, not shutdown coupling. Stop the Compose project with `docker compose down`, run app and client in one embedded container, or add your own supervisor/health-check logic if the sidecar must exit when the app exits.

### What should I set in Compose when the app already embeds Portflare?

If you move Portflare into a Compose sidecar, disable the embedded client in the app container if the image supports it, for example:

```env
PORTFLARE_EMBEDDED_CLIENT=false
```

Keep the sidecar's state persistent, for example:

```yaml
volumes:
  - ./data/portflare-client:/state
environment:
  PORTFLARE_CLIENT_STATE_PATH: /state/state.json
```
