# exe.dev SSH Connection Design

**Date:** 2026-03-31
**Status:** Approved

## Problem

Current workflow: `ssh exe.dev` (management CLI) → `ssh my-server` (VM). Two hops, two points of failure, connections drop with no session persistence. Connecting directly to VMs worked but looked broken (plain shell, no colors) — a cosmetic issue that was never the real blocker.

## Solution

Direct SSH to exe.dev VMs with:
- A wildcard SSH config block (keepalives + ControlMaster) covering all exe.dev VMs
- A generic `exe` Fish function for ad-hoc VMs
- Named Fish functions for frequently-used VMs (same pattern as existing `hermes`)
- Invisible tmux: status bar hidden, session auto-attaches on connect

The "weird shell" issue disappears because tmux sets `TERM=tmux-256color` immediately on connect.

## Components

### 1. SSH config block (`home/mhg/default.nix`)

Add a wildcard `matchBlock` for exe.dev VMs. The host pattern should match whatever naming convention exe.dev uses (e.g. `exe-*` or direct IPs — confirm at implementation time by running `ssh exe.dev ls`).

Settings:
- `serverAliveInterval = 30` — send keepalive every 30s
- `serverAliveCountMax = 6` — drop after 3 minutes of no response
- `ControlMaster = "auto"` — reuse existing TCP connection for same host
- `ControlPath = "~/.ssh/cm-%r@%h:%p"` — socket path per user/host/port
- `ControlPersist = "10m"` — keep master connection alive 10min after last client exits
- `identityFile = "~/.ssh/id_ed25519"`
- `user` — set to the exe.dev VM default user (confirm at implementation)

### 2. Generic `exe` Fish function (`modules/terminal.nix`)

```fish
exe my-vm-name
# → ssh -t <host> "tmux new-session -A -s <vm-name>"
```

Takes one argument (VM name or IP), connects directly, attaches-or-creates a tmux session named after the VM. Mirrors the `hermes` function pattern already in place.

### 3. Named functions for frequently-used VMs

Per-VM Fish functions following the same pattern as `hermes`. Added to `modules/terminal.nix` as needed.

### 4. tmux status bar (`modules/terminal.nix`)

Add `set -g status off` to `programs.tmux.extraConfig`. Session persistence and reattach work identically — the status bar is just hidden. User can toggle with `tmux set status on` in a session if needed.

## Data Flow

```
exe my-vm
  → ssh (ControlMaster: reuse or create TCP)
  → remote: tmux new-session -A -s my-vm
  → user lands in shell, tmux invisible

[connection drops]
  → tmux session stays alive on remote

exe my-vm (again)
  → ssh reconnects
  → tmux -A reattaches: same shell, same cwd, same running processes
```

## What Is Not Changing

- The exe.dev management CLI (`ssh exe.dev`) remains available for VM management (ls, new, rm, etc.)
- The `hermes` function is unchanged
- tmux keybindings and config are unchanged except status bar visibility
- No Tailscale on VMs (can be added later if VMs become long-lived)

## Out of Scope

- Mosh (adds a dependency, tmux reattach is sufficient)
- Tailscale on exe.dev VMs (viable future upgrade for long-lived VMs)
- Automating VM IP/hostname discovery from exe.dev CLI
