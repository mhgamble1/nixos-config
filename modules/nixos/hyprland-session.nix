{ pkgs, ... }:

# System-level Hyprland session — greetd/tuigreet + Hyprland compositor.
# Used by: desktop. Pair with desktop-session-common.nix for the shared
# X11/audio/printing/Firefox baseline.
{
  imports = [ ./desktop-session-common.nix ];

  # ── Display manager — greetd with tuigreet ───────────────────────────
  # greetd launches Hyprland directly as the PAM session command, so PAM
  # environment variables (incl. GNOME_KEYRING_CONTROL) are inherited by
  # the compositor and all child processes — fixing keyring auto-unlock.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.hyprland}/bin/start-hyprland";
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

  # Realtime scheduling for audio apps (PipeWire, etc.)
  security.pam.loginLimits = [
    { domain = "@audio"; item = "rtprio";  type = "-"; value = "95"; }
    { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
  ];

  # ── Secret Service — required by apps using libsecret (e.g. high-tide) ──
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
}
