#!/usr/bin/env bash
set -euo pipefail

node=$(tailscale exit-node suggest | sed -n 's/^Suggested exit node: \(.*\)\.$/\1/p')
if [ -z "$node" ]; then
  echo "tailscale-exit-node-set: no exit node suggestion available" >&2
  exit 1
fi

echo "tailscale-exit-node-set: routing through $node"
exec tailscale set --exit-node="$node" --exit-node-allow-lan-access=true
