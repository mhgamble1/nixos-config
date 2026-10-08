{ ... }:

{
  # Lean baseline for headless servers (xps-server). Deliberately does NOT
  # import `base` (desktop-oriented: ccache, nix-ld, niri/noctalia caches,
  # fonts, graphics).
  flake.modules.nixos.server = { pkgs, secrets, ... }: {
    time.timeZone = "America/New_York";
    i18n.defaultLocale = "en_US.UTF-8";

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "mhg" ];
      auto-optimise-store = true;
    };
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    boot.loader.systemd-boot.configurationLimit = 10;

    users.users.mhg = {
      isNormalUser = true;
      shell = pkgs.bash;
      extraGroups = [ "wheel" "docker" ];
      openssh.authorizedKeys.keys = secrets.authorizedKeys.mark;
    };
    security.sudo.wheelNeedsPassword = false;

    environment.systemPackages = with pkgs; [ git wget smartmontools ];

    virtualisation.docker = {
      enable = true;
      autoPrune = { enable = true; dates = "weekly"; };
      # Applies to containers created after this; recreate existing ones
      # (docker compose up -d --force-recreate) to pick it up.
      daemon.settings = {
        log-driver = "json-file";
        log-opts = { max-size = "10m"; max-file = "3"; };
      };
    };

    services.fstrim.enable = true;
    zramSwap.enable = true;
    services.journald.settings.Journal.SystemMaxUse = "500M";
    services.fwupd.enable = true;

    # Reboot on a hard hang instead of sitting dead.
    systemd.settings.Manager.RuntimeWatchdogSec = "30s";

    # A stray power-button press shut this host down on 2026-10-04.
    services.logind.settings.Login = {
      HandlePowerKey = "ignore";
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
    };
  };
}
