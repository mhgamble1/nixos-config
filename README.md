# nixos-config

NixOS system configuration for a single Wayland/Hyprland workstation. Declarative, git-tracked, home-manager integrated.

---

## Hardware

- NVIDIA GPU (proprietary drivers, Wayland via GBM)
- Boot: GRUB → NVMe SSD
- Keyboard: Glove80 with Tailorkey 4.2m (bilateral homerow mods)

---

## Module structure

```
/etc/nixos/
├── configuration.nix           # System: boot, hardware, networking, services, users
├── hardware-configuration.nix  # Auto-generated — do not hand-edit
├── home.nix                    # Home Manager root: git, SSH, yazi, per-user packages
├── modules/
│   ├── hyprland.nix            # Hyprland WM, waybar, fuzzel, mako, keybinds, window rules
│   ├── terminal.nix            # Ghostty, tmux, fish, starship, bat, fzf, zoxide, modern utils
│   ├── dev.nix                 # Helix editor, Go, Python/uv, Nix LSP, SQLite
│   └── theming.nix             # GTK/Qt dark theme (adw-gtk3-dark, Tokyo Night)
└── smb-credentials             # NAS mount credentials (not committed)
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
nrs     # sudo nixos-rebuild switch
nrsu    # + pull new package versions from upstream

# Rollback if something breaks:
sudo nixos-rebuild switch --rollback
```

### Edit configs quickly

```bash
ne      # sudoedit /etc/nixos/configuration.nix
nhm     # sudoedit /etc/nixos/home.nix
# For modules, open directly:
hx /etc/nixos/modules/hyprland.nix
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

## Remote sync

This repo is primarily **pushed from one machine**. The remote is a backup and a bootstrap source.

| Scenario | What to do |
|---|---|
| **New machine / fresh NixOS install** | `git clone git@github.com:mhgamble1/nixos-config.git /etc/nixos && nrs` |
| **Reinstall on the same machine** | Same as above — the remote is your restore point |
| **Recovering from a broken store** | Clone fresh, run `nixos-rebuild switch` |

### Bootstrap on a new machine

```bash
# 1. Boot NixOS installer, install base system
# 2. Generate hardware config
nixos-generate-config --root /mnt

# 3. Replace /etc/nixos with this repo
cd /mnt/etc && rm -rf nixos
git clone git@github.com:mhgamble1/nixos-config.git nixos

# 4. Replace hardware-configuration.nix with the generated one
cp /mnt/etc/nixos/hardware-configuration.nix.bak nixos/hardware-configuration.nix

# 5. Rebuild
nixos-install  # or nixos-rebuild switch if already booted
```

> `hardware-configuration.nix` is machine-specific (disk UUIDs, detected hardware). Keep the auto-generated one per machine; everything else is portable.

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
- [ ] **Hostname** — rename from `nixos` to something meaningful in `configuration.nix`

### Medium-term

- [ ] **Flake-ify the NixOS config** — convert to `flake.nix` with pinned nixpkgs for reproducible builds
- [ ] **Multi-host support** — once flake-based, support laptop vs desktop from the same repo
- [ ] **Secrets management** — `agenix` or `sops-nix` for NAS credentials and API keys

### Long-term

- [ ] **NAS integration** — Jellyfin or similar media server, desktop as thin client
- [ ] **Raspberry Pi NAS** — NixOS on the Pi, managed from this repo
- [ ] **Home Assistant** — home automation on NAS or dedicated Pi
