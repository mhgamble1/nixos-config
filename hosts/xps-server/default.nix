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

  # ── Passwordless sudo, scoped to this host only ────────────────────────
  # Reachable over Tailscale only, single-user homelab box — not a daily
  # driver, so the usual password-on-sudo protection buys little here vs.
  # the friction of needing a human at the console for every deploy/rebuild.
  security.sudo.wheelNeedsPassword = false;

  # ── Docker — for self-hosted services (AFFiNE, etc.) ───────────────────
  virtualisation.docker.enable = true;

  # ── AFFiNE (self-hosted docs/whiteboard) ───────────────────────────────
  # Compose file is a real file in this repo (services/xps-server/affine/),
  # not fetched imperatively — the only thing generated at activation is
  # .env, because it needs the tailnet IP (assigned at runtime, not known
  # at eval time) and the DB password from secrets.nix.
  environment.etc."affine/docker-compose.yml".source =
    ../../services/xps-server/affine/docker-compose.yml;

  systemd.tmpfiles.rules = [
    "d /var/lib/affine 0750 root root -"
    "d /var/lib/affine/postgres 0750 root root -"
    "d /var/lib/affine/storage 0750 root root -"
    "d /var/lib/affine/config 0750 root root -"
  ];

  systemd.services.affine = {
    description = "AFFiNE self-hosted (docker compose)";
    after = [ "docker.service" "network-online.target" "tailscaled.service" ];
    wants = [ "network-online.target" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.docker pkgs.docker-compose pkgs.tailscale ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/etc/affine";
      ExecStartPre = pkgs.writeShellScript "affine-render-env" ''
        set -eu
        {
          echo "AFFINE_REVISION=stable"
          echo "PORT=3010"
          echo "AFFINE_SERVER_HTTPS=true"
          echo "AFFINE_SERVER_EXTERNAL_URL=https://xps-server.tail25cfe0.ts.net"
          echo "DB_DATA_LOCATION=/var/lib/affine/postgres"
          echo "UPLOAD_LOCATION=/var/lib/affine/storage"
          echo "CONFIG_LOCATION=/var/lib/affine/config"
          echo "DB_USERNAME=affine"
          echo "DB_PASSWORD=${secrets.affine.dbPassword}"
          echo "DB_DATABASE=affine"
        } > /etc/affine/.env
      '';
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /etc/affine/docker-compose.yml up -d --remove-orphans";
      ExecStartPost = "${pkgs.tailscale}/bin/tailscale serve --bg --https=443 http://127.0.0.1:3010";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f /etc/affine/docker-compose.yml down";
    };
  };

  system.stateVersion = "25.11";
}
