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
    ../../modules/nixos/kde.nix
    ../../modules/nixos/services.nix
    ../../modules/nixos/peripherals.nix
    ../../modules/nixos/users.nix
    ./power-management.nix
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

      # Charge threshold: this machine is plugged in most of the time
      # (home-only, see kde-home.nix), so calendar aging at high
      # state-of-charge — not cycle count — is the dominant wear factor.
      # Capping below 100% avoids that; 90 stop / 85 start (rather than
      # a single value) gives a 5-point hysteresis band so TLP isn't
      # toggling charging on/off right at the ceiling.
      #
      # NOTE: nothing was actually enforcing a threshold before this —
      # `upower -i` was reporting a stale charge-start/end-threshold of
      # 75/80%, but live sysfs (charge_control_start/end_threshold under
      # /sys/class/power_supply/BAT0) read 0/100 (unrestricted). That
      # upower value was leftover from something outside this repo, not
      # a fact of the current config.
      START_CHARGE_THRESH_BAT0 = 85;
      STOP_CHARGE_THRESH_BAT0 = 90;
    };
  };

  # Backlight control
  environment.systemPackages = [ pkgs.brightnessctl ];

  # Lets `fwupdmgr` talk to the fwupd daemon to check for/apply BIOS/EC
  # firmware updates.
  services.fwupd.enable = true;

  system.stateVersion = "25.11";
}
