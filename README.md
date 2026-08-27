# nixos-config

NixOS system configuration. Flake-based, git-tracked, Home Manager integrated as a NixOS module.

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

---

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

Claude Code is installed as a Home Manager package from nixpkgs (see `modules/home/agents.nix`). The `claude` binary is available directly on `$PATH` — no alias required.

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

- [ ] **Commit signing** — `commit.gpgsign = true` once SSH signing key is confirmed
- [ ] **ccache wiring** — `programs.ccache.enable = true` is set but `packageNames` is not configured; nothing actually routes through ccache yet. Identify packages worth caching (CUDA-heavy builds, anything compiled locally) and add them.
- [ ] **YubiKey FIDO2 SSH key** — replace software key with hardware-backed key
- [ ] **Secrets management** — `agenix` or `sops-nix` for NAS credentials and API keys; would eliminate the `--impure` flag requirement
