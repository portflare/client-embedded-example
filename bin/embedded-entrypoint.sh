#!/usr/bin/env sh
set -eu

portflare daemon &
client_pid=$!

cleanup() {
  kill "$client_pid" 2>/dev/null || true
}
trap cleanup INT TERM EXIT

exec "$@"
