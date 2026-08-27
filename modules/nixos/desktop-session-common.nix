{ pkgs, ... }:

# Shared baseline for any host running a graphical desktop session, regardless
# of which compositor/DE it uses. Paired with a session-specific module
# (gnome.nix, hyprland-session.nix) that layers on the display manager and
# compositor itself.

{
  # ── X11 base — needed for keymap and xwayland ─────────────────────────
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];

  # ── Keymap ────────────────────────────────────────────────────────────
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

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
