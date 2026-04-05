{ pkgs, ... }:

{
  # ── Timezone and locale ────────────────────────────────────────────────
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

  # ── Nix settings ──────────────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.max-jobs = 2;
  nix.settings.cores = 4;

  # ── Unfree packages ───────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;

  # ── Shell ─────────────────────────────────────────────────────────────
  # Must be enabled system-wide so fish appears in /etc/shells
  programs.fish.enable = true;

  # ── nix-ld — run unpatched dynamic binaries ───────────────────────────
  programs.nix-ld.enable = true;

  # ── Base system packages ───────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    wget
    git
    cifs-utils
    vulkan-tools
    feh
  ];
}
