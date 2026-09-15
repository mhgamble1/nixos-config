{ config, pkgs, secrets, flakeModules, ... }:

{
  imports = [
    ./hardware-configuration.nix
    flakeModules.nixos.base
    flakeModules.nixos.networking
    flakeModules.nixos.users
    flakeModules.nixos.home-assistant
  ];

  networking.hostName = "xps-server";

  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = secrets.t14.hostname;
      system = "x86_64-linux";
      protocol = "ssh-ng";
      sshUser = "mhg";
      sshKey = "/etc/nix/builder-key";
      maxJobs = 8;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    }
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  hardware.graphics.enable = true;

  virtualisation.docker.enable = true;
  users.users.mhg.extraGroups = [ "docker" ];

  services.avahi = {
    enable = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };
  networking.firewall.allowedTCPPorts = [ 3000 ]; # aiostreams

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.11";
}
