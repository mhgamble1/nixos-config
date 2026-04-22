{ config, pkgs, secrets, ... }:

# ── Laptop configuration ────────────────────────────────────────────────

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/services.nix
    ../../modules/nixos/users.nix
  ];

  networking.hostName = "laptop";

  # ── Boot ──────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Laptop hardware ───────────────────────────────────────────────────
  # Intel integrated graphics (no nvidia)
  hardware.graphics.enable = true;

  # Touchpad support
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
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
