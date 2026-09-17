{ ... }:

let
  # Binary caches this flake pulls from (niri/noctalia builds, mainly).
  # Also declared in flake.nix's `nixConfig` so a fresh checkout benefits
  # before this module has ever been applied.
  binaryCaches = {
    substituters = [
      "https://nix-community.cachix.org"
      "https://noctalia.cachix.org"
    ];
    publicKeys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };
in
{
  flake.modules.nixos.base = { pkgs, lib, ... }: {
    time.timeZone = "America/New_York";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.settings.trusted-users = [ "root" "mhg" ];
    nix.settings.extra-substituters = binaryCaches.substituters;
    nix.settings.extra-trusted-public-keys = binaryCaches.publicKeys;

    nix.settings.accept-flake-config = true;

    systemd.services.nix-daemon.serviceConfig = {
      Nice = lib.mkForce 19;
      IOSchedulingClass = lib.mkForce "idle";
      CPUSchedulingPolicy = lib.mkForce "idle";
    };

    nix.settings.sandbox = true;
    nix.settings.extra-sandbox-paths = [ "/var/cache/ccache" ];

    programs.ccache.enable = true;

    nixpkgs.config.allowUnfree = true;

    programs.fish.enable = true;

    programs.nix-ld.enable = true;

    environment.systemPackages = with pkgs; [
      wget
      git
      cifs-utils
      vulkan-tools
    ];
  };
}
