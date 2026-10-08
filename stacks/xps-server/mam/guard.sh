#!/bin/sh
# Egress guard + namespace holder for the MAM stack (container mam-netns).
# This container owns the network namespace; tailscale and every app join it,
# so restarting tailscale never strands the apps in a dead namespace, and these
# rules persist while tailscale is down.
# Allows root + loopback + tailscale0 + replies; drops all other eth0 egress.
# Root must stay allowed because tailscaled itself needs eth0 to reach the exit
# node => every app container MUST run non-root.
set -e
for ipt in iptables-nft ip6tables-nft; do   # host kernel is nftables-only
  $ipt -F OUTPUT
  $ipt -A OUTPUT -o lo -j ACCEPT
  $ipt -A OUTPUT -o tailscale0 -j ACCEPT
  $ipt -A OUTPUT -o eth0 -m owner --uid-owner 0 -j ACCEPT
  $ipt -A OUTPUT -o eth0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
  $ipt -A OUTPUT -o eth0 -j DROP
done
exec sleep infinity
