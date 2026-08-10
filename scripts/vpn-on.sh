#!/usr/bin/env bash
# Enable the Mullvad exit node on demand (e.g. on untrusted wifi).
set -euo pipefail
exec sudo tailscale-exit-node-set
