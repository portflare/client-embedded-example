# Portflare Client Embedded Example

This repository contains a small example image that embeds the Portflare client alongside an application.

It is meant to demonstrate the embedded-container pattern separately from the main client repository.

## What is here

- `Dockerfile`: example image that bundles `reverse-client` with a sample HTTP app
- `bin/embedded-entrypoint.sh`: starts the client daemon and then the app
- `docs/usage.md`: how to build, run, and adapt the example

## Build

By default the image copies `reverse-client` from `ghcr.io/portflare/client:latest`.

```bash
docker build -t ghcr.io/portflare/client-embedded-example:dev .
```

To pin a different client image:

```bash
docker build \
  --build-arg CLIENT_IMAGE=ghcr.io/portflare/client:sha-abcdef0 \
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
- runs `reverse-client`
- automatically exposes the app through Portflare

If you only need the client daemon itself, use `github.com/portflare/client` instead.
