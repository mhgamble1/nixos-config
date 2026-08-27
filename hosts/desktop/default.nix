{ config, pkgs, secrets, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/hyprland-session.nix
    ../../modules/nixos/services.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/nvidia.nix
  ];

  networking.hostName = "desktop";

  # ── Boot ──────────────────────────────────────────────────────────────
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;
  # AMD platform (SP5100 southbridge) needs reboot=pci to avoid GPU hang on reboot
  boot.kernelParams = [ "reboot=pci" ];

  # Hibernation — point kernel to swap partition for resume image
  boot.resumeDevice = "/dev/disk/by-uuid/6430a86b-0e47-4c9b-ad47-619efb5a39e8";

  # ── NAS — Samba automount ──────────────────────────────────────────────
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

  # Route all traffic through a Mullvad exit node via Tailscale on boot.
  # Uses `tailscale exit-node suggest` rather than a hardcoded relay
  # hostname — Mullvad relays are decommissioned/rotated without notice,
  # so a pinned hostname is a latent outage.
  # --exit-node-allow-lan-access keeps NAS reachable while VPN is active.
  systemd.services.tailscale-exit-node = {
    description = "Set Tailscale Mullvad exit node";
    after = [ "tailscaled.service" "network-online.target" ];
    wants = [ "tailscaled.service" "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.tailscale ];
    serviceConfig = {
      Type = "oneshot";
      # tailscale-exit-node-set is installed system-wide by networking.nix.
      ExecStart = "/run/current-system/sw/bin/tailscale-exit-node-set";
      RemainAfterExit = true;
    };
  };

  # ── Ollama — local LLM inference with CUDA ─────────────────────────────
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "-1"; # keep model in VRAM indefinitely
    };
  };

  # ── Desktop-only packages ─────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    rclone
  ];

  system.stateVersion = "25.11";
}
