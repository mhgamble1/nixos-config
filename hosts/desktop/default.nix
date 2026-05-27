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
    ../../modules/nixos/audiobookshelf.nix
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
  # Uses pkgs.mullvad (the daemon package) so the CLI version matches the running daemon.
  systemd.services.mullvad-autoconnect-disable = {
    description = "Disable Mullvad auto-connect on boot";
    after = [ "mullvad-daemon.service" ];
    wants = [ "mullvad-daemon.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      # Wait up to 10s for the daemon socket, then run the command.
      ExecStartPre = "${pkgs.bash}/bin/bash -c 'for i in 1 2 3 4 5; do ${pkgs.mullvad}/bin/mullvad status >/dev/null 2>&1 && break; sleep 2; done'";
      ExecStart = "${pkgs.mullvad}/bin/mullvad auto-connect set off";
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
      ExecStartPre = "${pkgs.bash}/bin/bash -c 'for i in 1 2 3 4 5; do ${pkgs.mullvad}/bin/mullvad status >/dev/null 2>&1 && break; sleep 2; done'";
      ExecStart = "${pkgs.mullvad}/bin/mullvad lan set allow";
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
