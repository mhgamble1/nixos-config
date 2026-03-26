{ pkgs, ... }:

{
  # ── X11 / Wayland base ────────────────────────────────────────────────
  # Required for display manager, XWayland, and nvidia driver config.
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];

  # ── Keymap ────────────────────────────────────────────────────────────
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ── Display manager — SDDM with Wayland support ───────────────────────
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # ── dconf — needed for GTK4 apps and portals ──────────────────────────
  programs.dconf.enable = true;

  # ── Hyprland compositor ───────────────────────────────────────────────
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # ── XDG portals — screen sharing / file dialogs under Wayland ─────────
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # ── Default terminal for xdg-terminal-exec ────────────────────────────
  xdg.terminal-exec.settings = {
    default = [ "com.mitchellh.ghostty.desktop" ];
  };

  # ── Audio — PipeWire ──────────────────────────────────────────────────
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ── Printing ──────────────────────────────────────────────────────────
  services.printing.enable = true;

  # ── Firefox ───────────────────────────────────────────────────────────
  programs.firefox.enable = true;
}
