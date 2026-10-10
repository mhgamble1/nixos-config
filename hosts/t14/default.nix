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
    flakeModules.nixos.noctalia
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

  environment.systemPackages = [ pkgs.brightnessctl pkgs.sshfs pkgs.nautilus ];

  # trash, network/sftp mounts and removable media in nautilus
  services.gvfs.enable = true;

  virtualisation.docker.enable = true;
  users.users.mhg.extraGroups = [ "docker" ];
  # general docker/nixos-firewall hygiene -- standard advice for bridged
  # containers, though it alone did NOT fix a real published-port hang hit
  # live (MK-147): connects then hangs forever, worked via `docker exec ...
  # wget` but timed out via host curl on both the published port and the
  # container's bridge IP directly, even after this + a rebuild. Worked
  # around by using `--network host` on that container instead of chasing
  # the exact firewall/NAT rule at fault -- keep an eye out if a *published*
  # (non-host-network) container ever needs to work on this host.
  networking.firewall.trustedInterfaces = [ "docker0" ];

  # needed so root (dockerd) can traverse an sshfs mount owned by mhg --
  # bind-mounting a FUSE mountpoint into a container fails with a
  # misleading "mkdir: file exists" error without this (see
  # bibliotheca/dev-data/sync-abs-db.sh's sibling mount setup, MK-147)
  programs.fuse.userAllowOther = true;

  services.fwupd.enable = true;

  services.gnome.gnome-keyring.enable = true;

  system.stateVersion = "25.11";
}
