{ pkgs, ... }:

# System-level GNOME Shell session — GDM + services.desktopManager.gnome.
# Used by: t14. Pair with home/../gnome-home.nix for dconf/extensions.
{
  # ── X11 base — needed for keymap and xwayland ─────────────────────────
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];

  # ── Keymap ────────────────────────────────────────────────────────────
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

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
