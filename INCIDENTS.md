# Incident Log

Brief record of boot/config failures — root causes and fixes for future reference.

---

## 2026-04-16 — Mullvad services fail on boot after nixpkgs bump

**Symptom:** `mullvad-autoconnect-disable.service` and `mullvad-lan-allow.service` report `[FAILED]` at boot. `journalctl` shows:
```
Error: Management RPC server or client error
Caused by: No such file or directory (os error 2)
```

**Root cause:** The custom services used `${pkgs.mullvad-vpn}/bin/mullvad` (GUI package, `mullvad-vpn-2025.14`) to talk to a daemon that `services.mullvad-vpn.enable` runs from `pkgs.mullvad` (`mullvad-2026.1`). A nixpkgs bump diverged the two versions, and the older CLI uses a different RPC socket path than the newer daemon.

**Fix:** Change `ExecStart`/`ExecStartPre` in both custom services to use `${pkgs.mullvad}/bin/mullvad` (the same package as the daemon). Add an `ExecStartPre` polling loop to wait for the daemon socket to be ready before running the command.

**Prevention:** Always reference `pkgs.mullvad` (not `pkgs.mullvad-vpn`) when scripting against the Mullvad daemon. The NixOS module (`services.mullvad-vpn`) uses `pkgs.mullvad`; the GUI app (`pkgs.mullvad-vpn`) is a separate package and may be at a different version.

---

## 2026-04-18 — Hang at graphical target after login (UWSM session selected by SDDM)

**Symptom:** After logging in via SDDM, screen goes black and the session dies silently. Appears as a hang at `graphical-interface.target`. System recovers after reboot and manually selecting the correct session.

**Root cause:** A nixpkgs bump added `hyprland-uwsm.desktop` to SDDM's session list alongside the existing `hyprland.desktop`. SDDM defaulted to it (sorts first alphabetically, no prior preference saved). The UWSM session calls `uwsm start`, which tries to start `wayland-session-bindpid@.service` in the user systemd instance — but that unit is only installed when `programs.hyprland.withUWSM = true`, which was not set. Exit code 5 (unit not found), session dies immediately.

**Fix:** Add `services.displayManager.defaultSession = "hyprland"` to `modules/nixos/desktop.nix` to pin SDDM to the plain `hyprland.desktop` session regardless of what the session list contains.

**Prevention:** Any nixpkgs bump can add new session `.desktop` files to SDDM. Without a pinned default, SDDM may auto-select an unsupported session. Set `defaultSession` explicitly and only change it when the target session has been validated end-to-end.

---

## 2026-08-08 — No internet on laptop whenever Tailscale is up (dead Mullvad exit node)

**Symptom:** With Tailscale running, the laptop has no internet and no LAN. Bringing Tailscale down restores both. `tailscale status` reports the tailnet as healthy and the selected exit node as `Online: true`, giving no indication of a fault.

**Root cause:** The laptop's exit node was pinned to the Mullvad relay `us-nyc-wg-301` (`100.82.221.88` / `143.244.47.65`), which had stopped completing WireGuard handshakes. `tailscale status --json` showed the tell:

```
TxBytes:       4680                      # handshake initiations going out
RxBytes:       0                         # nothing ever coming back
LastHandshake: 0001-01-01T00:00:00Z      # zero value — tunnel never established
Online:        true                      # control plane still advertised it
```

The relay answered ICMP normally (20ms, 0% loss), so the host was up and routable — it simply was not serving WireGuard. Because an exit node's `AllowedIPs` are `0.0.0.0/0` and `::/0`, every packet was routed into a tunnel that never came up. `ExitNodeAllowLANAccess` was also `false` on this host (the desktop sets it `true`), so the LAN went dark alongside the internet.

**Fix:** `sudo tailscale set --exit-node=` to clear the pin, then `sudo tailscale up`. The laptop now runs with no exit node by default — the machine does no torrenting (that lives on the VPS), and routing it through Mullvad slows `cache.nixos.org` substituter fetches on an already-slow NIC. Enable an exit node situationally for untrusted wifi. The desktop keeps its declarative pin in `hosts/desktop/default.nix`.

**Prevention:** `Online: true` is the coordination server saying a node is *registered*, not that the data path works — it does not verify the tunnel. To confirm an exit node is actually carrying traffic, check `LastHandshake` (must be a real recent timestamp, not the `0001-01-01` zero value) and `RxBytes` (must be non-zero) via `tailscale status --json`. Mullvad relays are decommissioned and rotated without notice, so any hard-pinned relay hostname is a latent outage. When pinning one, pair it with `--exit-node-allow-lan-access=true` so a dead relay does not also cost you LAN and SSH access to local hosts.
