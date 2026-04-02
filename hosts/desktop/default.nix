{ config, pkgs, secrets, ... }:

{
  imports = [
    ../../hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/services.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/hardware/nvidia.nix
  ];

  networking.hostName = "nixos";

  # ── Boot ──────────────────────────────────────────────────────────────
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  # Hibernation — point kernel to swap partition for resume image
  boot.resumeDevice = "/dev/disk/by-uuid/6430a86b-0e47-4c9b-ad47-619efb5a39e8";

  # ── NAS — Samba automount ──────────────────────────────────────────────
  fileSystems."/mnt/nas" = {
    device = "//${secrets.nas.ip}/nas";
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

  # Disable Mullvad auto-connect — use manually to avoid conflicting with Tailscale
  systemd.services.mullvad-autoconnect-disable = {
    description = "Disable Mullvad auto-connect on boot";
    after = [ "mullvad-daemon.service" ];
    wants = [ "mullvad-daemon.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.mullvad-vpn}/bin/mullvad auto-connect set off";
      RemainAfterExit = true;
    };
  };

  # Allow LAN traffic to bypass the VPN tunnel (required for NAS when VPN is active)
  systemd.services.mullvad-lan-allow = {
    description = "Allow LAN access through Mullvad VPN";
    after = [ "mullvad-daemon.service" ];
    wants = [ "mullvad-daemon.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.mullvad-vpn}/bin/mullvad lan set allow";
      RemainAfterExit = true;
    };
  };

  # ── Ollama — local LLM inference with CUDA ─────────────────────────────
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };

  system.stateVersion = "25.11";
}
