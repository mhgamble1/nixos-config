{ config, pkgs, secrets, ... }:

# ── xps-server ───────────────────────────────────────────────────────────
# Dell XPS 13 9360, i3-7100U, 4GB RAM. Repurposed from the old `laptop`
# daily-carry role (superseded by t14) into a dedicated, headless
# Home Assistant box. WiFi-only for now — add a USB-Ethernet adapter only
# if WiFi proves unreliable in practice. SSH is reachable over Tailscale
# only (see networking.nix); no LAN firewall exception is opened.

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/home-assistant.nix
  ];

  networking.hostName = "xps-server";

  # ── Distributed builds — offload to t14 ────────────────────────────────
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

  # ── Boot ──────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Headless — ignore lid switch so closing it doesn't suspend ─────────
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  # Intel integrated graphics driver only — no display server runs on top.
  hardware.graphics.enable = true;

  # ── Docker — for self-hosted addons (AIOStreams, AIOMetadata, etc.) ────
  virtualisation.docker.enable = true;
  users.users.mhg.extraGroups = [ "docker" ];

  # ── Passwordless sudo, scoped to this host only ────────────────────────
  # Reachable over Tailscale only, single-user homelab box — not a daily
  # driver, so the usual password-on-sudo protection buys little here vs.
  # the friction of needing a human at the console for every deploy/rebuild.
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.11";
}
