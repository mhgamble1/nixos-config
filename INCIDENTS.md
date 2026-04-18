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
