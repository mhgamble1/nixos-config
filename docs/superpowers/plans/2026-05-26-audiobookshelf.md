# Audiobookshelf Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Audiobookshelf as a NixOS system service on the desktop, accessible over LAN and Tailscale on port 13378.

**Architecture:** New module `modules/nixos/audiobookshelf.nix` enables the service and opens the firewall port. Imported only in `hosts/desktop/default.nix`. Data lives at `/var/lib/audiobookshelf` (NixOS-managed). Library paths are added via the ABS web UI post-install.

**Tech Stack:** NixOS `services.audiobookshelf` (nixpkgs), `networking.firewall.allowedTCPPorts`

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Create | `modules/nixos/audiobookshelf.nix` | Service config + firewall rule |
| Modify | `hosts/desktop/default.nix` | Import the new module |

---

### Task 1: Create the Audiobookshelf module

**Files:**
- Create: `modules/nixos/audiobookshelf.nix`

- [ ] **Step 1: Write the module**

Create `/etc/nixos/modules/nixos/audiobookshelf.nix` with this exact content:

```nix
{ ... }:

{
  # ── Audiobookshelf — self-hosted audiobook/podcast server ─────────────
  services.audiobookshelf = {
    enable = true;
    host = "0.0.0.0";
    port = 13378;
    # dataDir defaults to /var/lib/audiobookshelf — NixOS creates and owns it.
    # Add library folders (NAS, local) via the web UI after first launch.
  };

  networking.firewall.allowedTCPPorts = [ 13378 ];
}
```

- [ ] **Step 2: Verify the file exists**

```bash
cat /etc/nixos/modules/nixos/audiobookshelf.nix
```

Expected: the file content above, no errors.

---

### Task 2: Import the module in the desktop host

**Files:**
- Modify: `hosts/desktop/default.nix`

- [ ] **Step 1: Add the import**

In `hosts/desktop/default.nix`, add the new module to the `imports` list. The list currently ends with:

```nix
    ../../modules/nixos/hardware/nvidia.nix
  ];
```

Change it to:

```nix
    ../../modules/nixos/hardware/nvidia.nix
    ../../modules/nixos/audiobookshelf.nix
  ];
```

- [ ] **Step 2: Verify the import was added cleanly**

```bash
grep -n "audiobookshelf" /etc/nixos/hosts/desktop/default.nix
```

Expected output:
```
13:    ../../modules/nixos/audiobookshelf.nix
```
(line number may vary slightly)

---

### Task 3: Evaluate and rebuild

- [ ] **Step 1: Dry-run evaluation (catches Nix syntax errors without building)**

```bash
nix flake check /etc/nixos --no-build 2>&1 | head -30
```

Expected: no errors. If there are errors, fix them before proceeding.

- [ ] **Step 2: Rebuild and switch**

```bash
sudo nixos-rebuild switch --flake /etc/nixos --impure 2>&1 | tail -20
```

Expected: build completes, `audiobookshelf.service` mentioned in activated units. No errors.

- [ ] **Step 3: Verify the service is running**

```bash
systemctl status audiobookshelf.service
```

Expected: `Active: active (running)` with a recent start time.

- [ ] **Step 4: Verify the port is listening**

```bash
ss -tlnp | grep 13378
```

Expected:
```
LISTEN  0  511  0.0.0.0:13378  0.0.0.0:*  users:(("node",pid=...,fd=...))
```

- [ ] **Step 5: Verify firewall rule is active**

```bash
sudo iptables -L nixos-fw -n | grep 13378
```

Expected: a line containing `13378` and `ACCEPT`.

- [ ] **Step 6: Commit**

```bash
git -C /etc/nixos add modules/nixos/audiobookshelf.nix hosts/desktop/default.nix
git -C /etc/nixos commit -m "feat: add Audiobookshelf service on port 13378

Accessible over LAN and Tailscale. Library folders configured via web UI.
Data stored at /var/lib/audiobookshelf.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

---

### Task 4: First-run setup (manual)

These steps are done in the browser — no code changes.

- [ ] **Step 1: Open the web UI**

Navigate to `http://localhost:13378` in Firefox.

- [ ] **Step 2: Create the admin account**

Fill in username, password, and email on the setup screen.

- [ ] **Step 3: Add a library**

Click **Libraries → Add Library**. Add any available library folders (e.g. `/mnt/nas/audiobooks` if the NAS is mounted, or a local path). You can add more libraries later — the NAS uses `x-systemd.automount` so it mounts on first access.

- [ ] **Step 4: Install the Android/iOS app (optional)**

The Audiobookshelf mobile app connects to `http://<tailscale-ip>:13378`. Log in with the admin credentials from Step 2.
