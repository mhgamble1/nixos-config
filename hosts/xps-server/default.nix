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

  # Docker never restarts a container that is merely `unhealthy`, so a hung
  # mam-ts (stale Mullvad exit, wedged tailscaled) would sit there with the
  # egress guard dropping everything. Restart it, and push a heartbeat to
  # Kuma every run (a missing heartbeat = the host/watchdog itself is dead).
  # Optional /etc/mam-watchdog.env (not in the repo) sets
  #   KUMA_PUSH_URL=http://100.89.106.16:3001/api/push/<token>
  systemd.services.mam-ts-watchdog = {
    description = "Restart mam-ts when unhealthy; heartbeat to Kuma";
    path = [ pkgs.docker pkgs.curl pkgs.coreutils ];
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = "-/etc/mam-watchdog.env";
    };
    script = ''
      health=$(docker inspect -f '{{.State.Health.Status}}' mam-ts 2>/dev/null || echo missing)
      status=up; msg=healthy
      if [ "$health" = unhealthy ]; then
        echo "mam-ts unhealthy, restarting"
        docker restart mam-ts || true
        status=down; msg=restarted-unhealthy
      elif [ "$health" != healthy ]; then
        status=down; msg="mam-ts-$health"
      fi
      if [ -n "''${KUMA_PUSH_URL:-}" ]; then
        curl -fsS -m 10 "$KUMA_PUSH_URL?status=$status&msg=$msg" >/dev/null || true
      fi
    '';
  };
  systemd.timers.mam-ts-watchdog = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "3min";
      OnUnitActiveSec = "1min";
    };
  };

  system.stateVersion = "25.11";
}
