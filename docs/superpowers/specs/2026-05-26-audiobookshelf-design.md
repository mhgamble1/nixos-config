# Audiobookshelf Setup — Design Spec

**Date:** 2026-05-26  
**Status:** Approved

## Overview

Add Audiobookshelf (self-hosted audiobook/podcast server) to the desktop NixOS config as a system service, accessible over LAN and Tailscale.

## Architecture

- **NixOS module:** `services.audiobookshelf` — available natively in nixpkgs (v2.35.0)
- **New file:** `modules/nixos/audiobookshelf.nix` — desktop-only service module
- **Imported from:** `hosts/desktop/default.nix` (not shared with laptop)

## Configuration

| Setting | Value | Notes |
|---|---|---|
| Port | `13378` | ABS default |
| Host | `0.0.0.0` | Reachable over LAN and Tailscale |
| Data dir | `/var/lib/audiobookshelf` | NixOS-managed, default |
| Firewall | TCP 13378 added to `allowedTCPPorts` | Added in `audiobookshelf.nix` |

## Library Paths

Library folders are configured via the ABS web UI after first launch — not baked into the Nix config. This keeps the config decoupled from book organization (some books on NAS, some local, structure TBD).

The NAS is already automounted at `/mnt/nas` via Samba with `x-systemd.automount`.

## Access

- **Local:** `http://localhost:13378`
- **Tailscale:** `http://<tailscale-ip>:13378`
- No reverse proxy or TLS — Tailscale provides encrypted transport for remote access

## No Reverse Proxy

Intentionally omitted. For a single-user personal setup, Tailscale's encrypted tunnel is sufficient. A reverse proxy (nginx + ACME) would add complexity without meaningful benefit at this scope.

## Files Changed

1. `modules/nixos/audiobookshelf.nix` — new file with service + firewall config
2. `hosts/desktop/default.nix` — add import for above module
