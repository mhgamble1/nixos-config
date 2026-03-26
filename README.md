# nixos-config

NixOS system configuration for a Wayland/Hyprland workstation. Flake-based, git-tracked, Home Manager integrated as a NixOS module.

---

## Hardware

- NVIDIA GPU (proprietary drivers, Wayland via GBM)
- Boot: GRUB → NVMe SSD
- Keyboard: Glove80 with Tailorkey 4.2m (bilateral homerow mods)

---

## Structure

```
/etc/nixos/
├── flake.nix                          # Entry point — nixpkgs pin, hosts, HM module
├── flake.lock                         # Auto-generated — pins nixos-unstable
├── secrets.nix                        # Passwords/credentials — gitignored, loaded via --impure
├── smb-credentials                    # NAS mount credentials — not committed
├── hardware-configuration.nix         # Auto-generated — do not hand-edit
├── hosts/
│   ├── desktop/default.nix            # Desktop: boot, NAS, ollama-cuda, imports shared modules
│   └── laptop/default.nix             # Laptop: scaffold (future Dell XPS)
├── modules/
│   ├── nixos/                         # System-level NixOS modules
│   │   ├── base.nix                   # Locale, timezone, nix settings, nix-ld, allowUnfree
│   │   ├── networking.nix             # NetworkManager, tailscale, mullvad, openssh
│   │   ├── desktop.nix                # xserver, SDDM, Hyprland, pipewire, printing, Firefox
│   │   ├── services.nix               # Flatpak, bluetooth
│   │   ├── users.nix                  # users.users.mhg, fonts
│   │   └── hardware/nvidia.nix        # NVIDIA drivers, modesetting, graphics
│   ├── hyprland.nix                   # Hyprland WM, Waybar, fuzzel, mako, keybinds
│   ├── terminal.nix                   # Ghostty, tmux, fish, starship, bat, fzf, zoxide
│   ├── dev.nix                        # Helix, Go, Python/uv, Nix LSP, SQLite
│   └── theming.nix                    # GTK/Qt dark theme (adw-gtk3-dark, Tokyo Night)
├── home/mhg/
│   ├── default.nix                    # Home Manager root: git, SSH, yazi, per-user packages
│   └── cheatsheet.md                  # Quick reference (rendered to ~/cheatsheet.md)
└── scripts/
    └── pomo.py                        # Pomodoro timer
```

---

## Key applications

| Role          | Tool           | Notes                                            |
|---------------|----------------|--------------------------------------------------|
| WM            | Hyprland       | Wayland compositor, NVIDIA-tuned, dwindle layout |
| Bar           | Waybar         | Top bar: workspaces, clock, CPU/MEM/NET/VOL      |
| Launcher      | fuzzel         | App launcher (`SUPER+D`)                         |
| Notifications | mako           | Desktop notifications                            |
| Terminal      | Ghostty        | GPU-accelerated, Tokyo Night theme               |
| Shell         | fish           | Vi keybindings, starship prompt                  |
| Multiplexer   | tmux           | SSH/remote only — not auto-started locally       |
| Editor        | Helix          | Modal, LSP, Tokyo Night theme                    |
| File manager  | yazi           | TUI, opens floating via `SUPER+E`                |
| Music         | spotify_player | TUI Spotify client, opens floating via `SUPER+M` |
| Browser       | Firefox        |                                                  |
| VPN           | Mullvad        | Auto-connects on boot                            |
| NAS           | Samba/CIFS     | Automounts `/mnt/nas` on access                  |

---

## Daily workflow

### Apply config changes

```bash
nrs     # sudo nixos-rebuild switch --flake /etc/nixos --impure
nrsu    # + update flake inputs (pull new package versions)

# Rollback if something breaks:
sudo nixos-rebuild switch --rollback
```

> `--impure` is required because `secrets.nix` is gitignored.

### Edit configs quickly

```bash
# Open key files directly:
hx /etc/nixos/hosts/desktop/default.nix   # boot, NAS, ollama
hx /etc/nixos/home/mhg/default.nix        # home manager root
hx /etc/nixos/modules/hyprland.nix        # keybinds, window rules
hx /etc/nixos/modules/terminal.nix        # shell, aliases
```

### Commit and push changes

```bash
cd /etc/nixos
gs           # git status
ga -p        # git add --patch (stage selectively)
gc -m "..."  # git commit
gp           # git push (via SSH)
```

---

## Remote sync / bootstrap

This repo is primarily **pushed from one machine**. The remote is a backup and bootstrap source.

| Scenario | What to do |
|---|---|
| **New machine / fresh NixOS install** | Clone repo, copy `hardware-configuration.nix`, run `nixos-rebuild switch --flake /etc/nixos --impure` |
| **Reinstall on the same machine** | Same as above — the remote is your restore point |

### Bootstrap on a new machine

```bash
# 1. Boot NixOS installer, install base system
# 2. Generate hardware config
nixos-generate-config --root /mnt

# 3. Replace /etc/nixos with this repo
cd /mnt/etc && rm -rf nixos
git clone git@github.com:mhgamble1/nixos-config.git nixos

# 4. Copy the generated hardware-configuration.nix into place
cp /mnt/etc/nixos.bak/hardware-configuration.nix nixos/

# 5. Add a new host entry in flake.nix and hosts/<hostname>/default.nix
# 6. Rebuild
nixos-install --flake /mnt/etc/nixos#<hostname>
```

> `hardware-configuration.nix` is machine-specific (disk UUIDs, detected hardware). Every host keeps its own generated copy; everything else is shared.

---

## SSH and git authentication

Authentication to GitHub uses an ed25519 SSH key (`~/.ssh/id_ed25519`). The SSH client config routes `github.com` connections through this key automatically.

When setting up a new machine:

```bash
ssh-keygen -t ed25519 -C "mhgamble1@gmail.com"
cat ~/.ssh/id_ed25519.pub   # copy to GitHub → Settings → SSH keys
ssh -T git@github.com       # verify
```

---

## Claude Code

Claude is **not** installed as a system package. It runs via a flake from the fish alias:

```fish
claude   # expands to: nix run github:sadjow/claude-code-nix --
```

---

## Housekeeping

```bash
# Remove old generations and reclaim store space (run periodically)
sudo nix-collect-garbage -d

# Deduplicate store entries (slow, optional)
sudo nix-store --optimise
```

---

## Roadmap

### Near-term

- [ ] **YubiKey FIDO2 SSH key** — replace software key with hardware-backed key
- [ ] **Commit signing** — `commit.gpgsign = true` once SSH signing key is confirmed
- [ ] **Hostname** — rename from `nixos` to something meaningful in `flake.nix`
- [ ] **Laptop host** — flesh out `hosts/laptop/default.nix` for Dell XPS

### Medium-term

- [ ] **Secrets management** — `agenix` or `sops-nix` for NAS credentials and API keys; would eliminate the `--impure` flag requirement

### Long-term

- [ ] **NAS integration** — Jellyfin or similar media server, desktop as thin client
- [ ] **Raspberry Pi NAS** — NixOS on the Pi, managed from this repo
- [ ] **Home Assistant** — home automation on NAS or dedicated Pi
