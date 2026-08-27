{ pkgs, ... }:

# System-level GNOME Shell session — GDM + services.desktopManager.gnome.
# Used by: t14. Pair with modules/home/gnome-home.nix for dconf/extensions, and
# desktop-session-common.nix for the shared X11/audio/printing/Firefox baseline.
{
  imports = [ ./desktop-session-common.nix ];

  # ── Display manager — GDM ─────────────────────────────────────────────
  services.displayManager.gdm.enable = true;

  # ── GNOME desktop ─────────────────────────────────────────────────────
  services.desktopManager.gnome.enable = true;

  # GNOME enables power-profiles-daemon by default; disable it so TLP
  # (configured in the laptop host) can manage power without conflict.
  services.power-profiles-daemon.enable = false;

  # Remove apps we don't use (have better alternatives installed)
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour        # first-run welcome tour
    gnome-connections # remote desktop client
    epiphany          # GNOME browser (using Firefox)
    geary             # email client
    totem             # video player (using VLC)
    gnome-music       # music player (using spotify_player)
  ];

}
