#!/bin/sh
# Proof for MK-153: run on xps from ~/docker/mam. Exits non-zero on any failure.
# Probes run in throwaway alpine containers sharing the mam-netns namespace as
# uid 1000 -- the same position as the real (non-root) app processes.
cd "$(dirname "$0")" || exit 2
fail=0
ok()  { echo "PASS  $*"; }
bad() { echo "FAIL  $*"; fail=1; }
probe() { docker run --rm --network container:mam-netns --user 1000:100 alpine:3 \
  sh -c "wget -q -T 6 -O- $1 2>&1" 2>&1 | tail -1; }
wait_healthy() { for i in $(seq 1 30); do [ "$(docker inspect -f '{{.State.Health.Status}}' mam-ts)" = healthy ] && return 0; sleep 3; done; return 1; }

# 0. No app main process may run as root (root bypasses the eth0 guard).
for c in mam-qbittorrent mam-prowlarr mam-shelfmark mam-mousehole; do
  n=$(docker top "$c" -eo user,pid,args | awk '$1=="root" && $0 !~ /s6-|dumb-init|svscan|supervise/' | tail -n +2 | wc -l)
  [ "$n" = 0 ] && ok "$c: no root app process" || bad "$c has $n root process(es)"
done

# 1. Normal state: egress is Mullvad.
out=$(probe https://am.i.mullvad.net/connected)
echo "$out" | grep -q 'You are connected to Mullvad' && ok "egress via Mullvad: $out" || bad "not on Mullvad: $out"

# 2. Exit node unset: non-root traffic must die, not fall back to the real IP.
docker exec mam-ts tailscale set --exit-node= >/dev/null
sleep 4
out=$(probe https://am.i.mullvad.net/connected)
echo "$out" | grep -q 'IP address' && bad "LEAKED with exit node unset: $out" || ok "blocked with exit node unset"

# 3. Tailscale process stopped entirely (crash): guard must still hold.
docker stop mam-ts >/dev/null
sleep 3
out=$(probe https://am.i.mullvad.net/connected)
echo "$out" | grep -q 'IP address' && bad "LEAKED with ts container stopped: $out" || ok "blocked with ts container stopped"

# 4. Self-heal: ts comes back (fresh start) and the existing apps recover
#    WITHOUT being restarted (shared namespace survives).
docker start mam-ts >/dev/null
wait_healthy && ok "ts healthy again after restart" || bad "ts did not recover"
out=$(docker exec mam-qbittorrent curl -s -m 8 https://am.i.mullvad.net/connected 2>&1 | tail -1)
echo "$out" | grep -q 'You are connected to Mullvad' && ok "qbittorrent recovered via Mullvad without restart" || bad "qbittorrent not recovered: $out"

exit $fail
