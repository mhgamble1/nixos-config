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
  # Pin the default session to the plain Hyprland entry. Without this, SDDM
  # may default to hyprland-uwsm.desktop (added by a nixpkgs bump) which
  # requires UWSM user-systemd units that we don't install (withUWSM = false).
  services.displayManager.defaultSession = "hyprland";

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
    jack.enable = true;
  };

  # Realtime scheduling for audio apps (PipeWire, etc.)
  security.pam.loginLimits = [
    { domain = "@audio"; item = "rtprio";  type = "-"; value = "95"; }
    { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
  ];

  # ── Printing ──────────────────────────────────────────────────────────
  services.printing.enable = true;

  # ── Secret Service — required by apps using libsecret (e.g. high-tide) ──
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  # ── Firefox ───────────────────────────────────────────────────────────
  programs.firefox.enable = true;
}
