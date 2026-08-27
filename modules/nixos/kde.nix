{ pkgs, ... }:

# System-level KDE Plasma 6 session — SDDM + services.desktopManager.plasma6.
# Used by: t14. Pair with home/../kde-home.nix for plasma-manager config.
# Replaces modules/nixos/gnome.nix (kept dormant, not deleted, in case this
# doesn't stick — see hosts/t14/default.nix).
{
  # ── X11 base — needed for keymap and xwayland ─────────────────────────
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];

  # ── Keymap ────────────────────────────────────────────────────────────
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ── Display manager — SDDM ─────────────────────────────────────────────
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # ── KDE Plasma desktop ──────────────────────────────────────────────────
  services.desktopManager.plasma6.enable = true;

  # Plasma enables power-profiles-daemon by default; disable it so TLP
  # (configured in the laptop host) can manage power without conflict.
  # Same reasoning as the GNOME config it replaces.
  services.power-profiles-daemon.enable = false;

  # Remove apps we don't use (have better alternatives installed) —
  # mirrors modules/nixos/gnome.nix's environment.gnome.excludePackages.
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa # music player (using spotify_player)
    khelpcenter
  ];

  # ── Audio — PipeWire ──────────────────────────────────────────────────
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # ── Printing ──────────────────────────────────────────────────────────
  services.printing.enable = true;

  # ── Firefox ───────────────────────────────────────────────────────────
  programs.firefox.enable = true;
}
