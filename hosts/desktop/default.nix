{ config, pkgs, secrets, flakeModules, ... }:

{
  imports = [
    ./hardware-configuration.nix
    flakeModules.nixos.base
    flakeModules.nixos.networking
    flakeModules.nixos.users
    flakeModules.nixos.services
    flakeModules.nixos.nvidia
    flakeModules.nixos.hyprland
  ];

  networking.hostName = "desktop";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;
  # AMD platform (SP5100 southbridge) needs reboot=pci to avoid GPU hang on reboot
  boot.kernelParams = [ "reboot=pci" ];

  boot.resumeDevice = "/dev/disk/by-uuid/6430a86b-0e47-4c9b-ad47-619efb5a39e8";

  fileSystems."/mnt/nas" = {
    device = "//${secrets.nas.ip}/shared";
    fsType = "cifs";
    options = [
      "credentials=/etc/nixos/smb-credentials"
      "uid=1000"
      "gid=100"
      "iocharset=utf8"
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
    ];
  };

  systemd.services.tailscale-exit-node = {
    description = "Set Tailscale Mullvad exit node";
    after = [ "tailscaled.service" "network-online.target" ];
    wants = [ "tailscaled.service" "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.tailscale ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/tailscale-exit-node-set";
      RemainAfterExit = true;
    };
  };

  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "-1"; # keep model in VRAM indefinitely
    };
  };

  environment.systemPackages = with pkgs; [
    rclone
  ];

  system.stateVersion = "25.11";
}
