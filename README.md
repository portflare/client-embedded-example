# Portflare Client Embedded Example

This repository contains a small example image that embeds the Portflare client alongside an application.

It demonstrates the embedded-container pattern separately from the main client repository so the example image can have its own docs, build pipeline, and release flow.

Related repositories:

- [`github.com/portflare/client`](https://github.com/portflare/client) — the reusable client daemon image and source
- [`github.com/portflare/server`](https://github.com/portflare/server) — the Portflare server and control plane
- [`github.com/portflare/protocol`](https://github.com/portflare/protocol) — shared wire-level types and validation helpers

## What is here

- `Dockerfile`: example image that bundles `portflare` with a sample HTTP app
- `bin/embedded-entrypoint.sh`: starts the client daemon and then the app
- `docs/usage.md`: how to build, run, and adapt the example

## Build

By default the image copies `portflare` from `ghcr.io/portflare/client:latest`.

```bash
docker build -t ghcr.io/portflare/client-embedded-example:dev .
```

To pin a different client image:

```bash
docker build \
  --build-arg CLIENT_IMAGE=ghcr.io/portflare/client:v0.1.1 \
  -t ghcr.io/portflare/client-embedded-example:dev .
```

## Run

```bash
docker run --rm -p 3000:3000 \
  -e REVERSE_SERVER_URL=https://r.myw.io \
  -e REVERSE_CLIENT_KEY=pf_your_key_here \
  ghcr.io/portflare/client-embedded-example:dev
```

The sample app listens on port `3000` and the embedded client auto-discovers and registers it as `web`.

## When to use this repo

Use this as a starting point when you want one container image that:

- runs your app
- runs `portflare`
- automatically exposes the app through Portflare

If you only need the client daemon itself, use [`github.com/portflare/client`](https://github.com/portflare/client) instead.
