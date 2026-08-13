{ config, pkgs, secrets, ... }:

# ── ThinkPad T14 gen2 configuration ─────────────────────────────────────
# i7-1165G7, Intel Iris Xe (no NVIDIA). Provisioned fresh 2026-08 —
# hardware-configuration.nix is generated on-site during install, not
# hand-written; do not copy the desktop/laptop one in.

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/gnome.nix
    ../../modules/nixos/services.nix
    ../../modules/nixos/users.nix
  ];

  networking.hostName = "t14";

  # ── Boot — UEFI, systemd-boot (matches laptop's setup) ────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Intel integrated graphics (no NVIDIA) ──────────────────────────────
  hardware.graphics.enable = true;

  # Touchpad support
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = false;
      tapping = true;
    };
  };

  # Power management
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };

  # Backlight control
  environment.systemPackages = [ pkgs.brightnessctl ];

  system.stateVersion = "25.11";
}
