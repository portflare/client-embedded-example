# Embedded example usage

## Overview

This image demonstrates the embedded-client pattern:

- `reverse-client daemon` runs in the background
- your application runs as the main process
- the client discovers the app and registers it with Portflare

## Default settings

- local app port: `3000`
- discovered app name: `web`
- local client API: `127.0.0.1:9901`

## Required environment variables

```bash
export REVERSE_SERVER_URL=https://r.myw.io
export REVERSE_CLIENT_KEY=pf_your_key_here
```

## Build with a pinned client image

```bash
docker build \
  --build-arg CLIENT_IMAGE=ghcr.io/portflare/client:latest \
  -t ghcr.io/portflare/client-embedded-example:dev .
```

## Swap the sample app out

Replace the final stage app setup in `Dockerfile` and keep `bin/embedded-entrypoint.sh` as the entrypoint pattern.

The important part is that your app listens on the port allowed by:

```bash
REVERSE_CLIENT_DISCOVER_ALLOW=3000
REVERSE_CLIENT_DISCOVER_NAMES=3000=web
```
