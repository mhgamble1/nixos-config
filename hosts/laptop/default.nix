{ config, pkgs, secrets, ... }:

# ── Dell XPS laptop — scaffold ──────────────────────────────────────────
# Not yet provisioned. Steps to activate:
#   1. Install NixOS on the laptop
#   2. Copy the generated hardware-configuration.nix to this directory
#   3. Uncomment the hardware-configuration.nix import below
#   4. Add/adjust any laptop-specific hardware config (GPU, touchpad, etc.)
#   5. nixos-rebuild switch --flake /etc/nixos#laptop

{
  imports = [
    # ../../hosts/laptop/hardware-configuration.nix  # TODO: uncomment when provisioned
    ../../modules/nixos/base.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/services.nix
    ../../modules/nixos/users.nix
    # No nvidia.nix — laptop has different GPU; add hardware/intel.nix or hardware/amd.nix
  ];

  networking.hostName = "laptop";

  # TODO: configure bootloader for laptop (likely systemd-boot on EFI)
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  # TODO: add laptop-specific config:
  #   - touchpad (libinput)
  #   - battery/power management
  #   - backlight
  #   - different monitor config in hyprland.nix (or override here)

  system.stateVersion = "25.11";
}
