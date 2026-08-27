#!/usr/bin/env bash
# Pick a currently-healthy Mullvad exit node via Tailscale's own suggestion
# picker and set it, instead of a hardcoded relay hostname. Mullvad relays
# are decommissioned/rotated without notice, so a pinned hostname is a
# latent outage. Run as root (or via sudo).
set -euo pipefail

node=$(tailscale exit-node suggest | sed -n 's/^Suggested exit node: \(.*\)\.$/\1/p')
if [ -z "$node" ]; then
  echo "tailscale-exit-node-set: no exit node suggestion available" >&2
  exit 1
fi

echo "tailscale-exit-node-set: routing through $node"
exec tailscale set --exit-node="$node" --exit-node-allow-lan-access=true
