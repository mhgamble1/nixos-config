{ config, pkgs, secrets, flakeModules, ... }:

{
  imports = [
    ./hardware-configuration.nix
    flakeModules.nixos.base
    flakeModules.nixos.networking
    flakeModules.nixos.users
    flakeModules.nixos.services
    flakeModules.nixos.peripherals
    flakeModules.nixos.niri
    flakeModules.nixos.kde
    ./power-management.nix
  ];

  networking.hostName = "t14";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.graphics.enable = true;

  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = false;
      tapping = true;
    };
  };

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      START_CHARGE_THRESH_BAT0 = 85;
      STOP_CHARGE_THRESH_BAT0 = 90;
    };
  };

  environment.systemPackages = [ pkgs.brightnessctl ];

  services.fwupd.enable = true;

  services.gnome.gnome-keyring.enable = true;

  system.stateVersion = "25.11";
}
