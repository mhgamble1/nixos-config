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

  # ── Display manager — greetd with tuigreet ───────────────────────────
  # greetd launches Hyprland directly as the PAM session command, so PAM
  # environment variables (incl. GNOME_KEYRING_CONTROL) are inherited by
  # the compositor and all child processes — fixing keyring auto-unlock.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.hyprland}/bin/start-hyprland";
        user = "greeter";
      };
    };
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
  security.pam.services.greetd.enableGnomeKeyring = true;

  # ── Firefox ───────────────────────────────────────────────────────────
  programs.firefox.enable = true;
}
