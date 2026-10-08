{ config, pkgs, secrets, flakeModules, ... }:

{
  imports = [
    ./hardware-configuration.nix
    flakeModules.nixos.server
    flakeModules.nixos.networking
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

  # aiostreams, until MK-156 moves it behind Caddy/cloudflared on 127.0.0.1.
  networking.firewall.allowedTCPPorts = [ 3000 ];

  # TODO (MK-156, after Stremio BASE_URL is public): turn Wi-Fi off; the USB
  # ethernet dongle becomes the sole network.
  # 1TB SATA->USB SSD: downloads + library on ONE filesystem so hardlinks work (MK-154).
  fileSystems."/mnt/ssd" = {
    device = "/dev/disk/by-uuid/5997678d-720b-4ea7-b1ea-1dd8cf86161a";
    fsType = "ext4";
    options = [ "nofail" "noatime" "x-systemd.device-timeout=10s" ];
  };

  system.stateVersion = "25.11";
}
