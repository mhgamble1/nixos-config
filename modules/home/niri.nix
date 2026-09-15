{ pkgs, ... }:

# Home-manager niri config — keybindings, waybar, fuzzel, idle/lock.
# Used by: t14 (imported conditionally in home/mhg/default.nix by hostName).
# Pair with modules/nixos/niri-session.nix for the system-level session.
#
# Deliberately minimal: a small essential bind set (not a full transcription
# of niri's upstream defaults) plus the bare minimum to get a bar, launcher,
# and lock screen working. Extend once this is confirmed working live.
{
  home.packages = with pkgs; [
    swaylock # Screen locker (ext-session-lock protocol; swayidle calls it)
    swayidle # Idle-timeout daemon — niri has no built-in idle handling
    wl-clipboard
    pavucontrol
    networkmanagerapplet
    playerctl
    brightnessctl
  ];

  # ── niri compositor configuration ──────────────────────────────────────
  programs.niri.settings = {
    # Electron apps need this to behave under Wayland; niri only applies
    # env vars set here (not ~/.profile ones) to processes it spawns,
    # because it starts as `niri-session` and imports these into the
    # systemd/D-Bus activation environment itself.
    environment.NIXOS_OZONE_WL = "1";

    # Qt platform theme — niri has no native Qt integration (unlike KDE),
    # and this needs to stay scoped to the niri session specifically (see
    # modules/home/theming.nix for why it can't live in home-manager's
    # qt.enable instead: those vars would also leak into the KDE session
    # sharing this host).
    environment.QT_QPA_PLATFORMTHEME = "adwaita";
    environment.QT_STYLE_OVERRIDE = "adwaita-dark";

    input = {
      keyboard.xkb.layout = "us";
      touchpad.tap = true;
    };

    # T14's internal panel — matches the 1.5x scale used in hyprland.nix
    # for the same panel on the desktop host.
    outputs."eDP-1".scale = 1.5;

    layout.gaps = 8;

    # nm-applet/mako need a tray + notification server to show up in;
    # waybar itself is started by home-manager as a systemd unit below
    # (programs.waybar.systemd.enable), NOT here — starting it both ways
    # is what caused the doubled bar.
    spawn-at-startup = [
      { argv = [ "mako" ]; }
      { argv = [ "nm-applet" "--indicator" ]; }
      { argv = [ "blueman-applet" ]; }
    ];

    # ── Keybindings ─────────────────────────────────────────────────────
    # A small essential set, not a full copy of niri's defaults. Anything
    # not bound here still shows in the startup hotkey-overlay (niri always
    # lists its "important" suggested actions there, bound or not) so it's
    # discoverable — Mod+Shift+/ reopens that overlay any time.
    binds = {
      "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

      "Mod+Return".action.spawn = "${pkgs.ghostty}/bin/ghostty";
      "Mod+D".action.spawn = "fuzzel";
      "Mod+Shift+L".action.spawn = "swaylock";
      "Mod+Q".action.close-window = [ ];
      "Mod+Shift+E".action.quit = [ ];

      "Mod+Left".action.focus-column-left = [ ];
      "Mod+Down".action.focus-window-down = [ ];
      "Mod+Up".action.focus-window-up = [ ];
      "Mod+Right".action.focus-column-right = [ ];
      "Mod+H".action.focus-column-left = [ ];
      "Mod+J".action.focus-window-down = [ ];
      "Mod+K".action.focus-window-up = [ ];
      "Mod+L".action.focus-column-right = [ ];

      "Mod+Ctrl+Left".action.move-column-left = [ ];
      "Mod+Ctrl+Down".action.move-window-down = [ ];
      "Mod+Ctrl+Up".action.move-window-up = [ ];
      "Mod+Ctrl+Right".action.move-column-right = [ ];
      "Mod+Ctrl+H".action.move-column-left = [ ];
      "Mod+Ctrl+J".action.move-window-down = [ ];
      "Mod+Ctrl+K".action.move-window-up = [ ];
      "Mod+Ctrl+L".action.move-column-right = [ ];

      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;

      "Mod+R".action.switch-preset-column-width = [ ];
      "Mod+F".action.maximize-column = [ ];
      "Mod+Shift+F".action.fullscreen-window = [ ];
      "Mod+V".action.toggle-window-floating = [ ];

      "Mod+Shift+S".action.screenshot = [ ];

      "XF86AudioRaiseVolume" = { allow-when-locked = true; action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+ -l 1.0"; };
      "XF86AudioLowerVolume" = { allow-when-locked = true; action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-"; };
      "XF86AudioMute" = { allow-when-locked = true; action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; };
      "XF86AudioPlay" = { allow-when-locked = true; action.spawn-sh = "playerctl play-pause"; };
      "XF86AudioNext" = { allow-when-locked = true; action.spawn-sh = "playerctl next"; };
      "XF86AudioPrev" = { allow-when-locked = true; action.spawn-sh = "playerctl previous"; };
      "XF86MonBrightnessUp" = { allow-when-locked = true; action.spawn = [ "brightnessctl" "set" "5%+" ]; };
      "XF86MonBrightnessDown" = { allow-when-locked = true; action.spawn = [ "brightnessctl" "set" "5%-" ]; };
    };
  };

  # ── Waybar ──────────────────────────────────────────────────────────────
  # niri needs layer = "top" explicitly (unlike Hyprland, which layers bars
  # above tiled windows by default) or waybar ends up underneath windows.
  # systemd.enable = true starts it as a user unit on graphical-session.target
  # (niri triggers that) instead of via spawn-at-startup — pick one, not both.
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = [{
      layer = "top";
      position = "top";
      height = 32;
      spacing = 4;

      modules-left = [ "niri/workspaces" "niri/window" ];
      modules-center = [ "clock" ];
      modules-right = [ "pulseaudio" "network" "battery" "tray" ];

      "niri/workspaces".format = "{index}";
      "niri/window".max-length = 60;

      "clock".format = "{:%a %b %d  %H:%M}";

      "network" = {
        format-wifi = "WIFI {signalStrength}%";
        format-ethernet = "ETH";
        format-disconnected = "OFFLINE";
      };

      "pulseaudio" = {
        format = "VOL {volume}%";
        format-muted = "MUTED";
        on-click = "pavucontrol";
      };

      "battery" = {
        states = { warning = 30; critical = 15; };
        format = "BAT {capacity}%";
        format-charging = "CHG {capacity}%";
        format-full = "FULL";
      };
    }];
  };

  # ── Fuzzel launcher ───────────────────────────────────────────────────
  programs.fuzzel = {
    enable = true;
    settings.main = {
      terminal = "${pkgs.ghostty}/bin/ghostty -e";
      width = 40;
      lines = 15;
    };
  };

  # ── Idle / lock ─────────────────────────────────────────────────────────
  # niri has no built-in idle daemon (unlike Hyprland's hypridle) — it just
  # implements the idle-notify protocol that swayidle consumes, so swayidle
  # is the standard pairing here. swaylock works unmodified via the
  # ext-session-lock protocol, same as on Hyprland.
  services.swayidle = {
    enable = true;
    events = {
      before-sleep = "swaylock -f";
      lock = "swaylock -f";
    };
    timeouts = [
      { timeout = 1500; command = "swaylock -f"; } # 25 min: lock screen
      { timeout = 5400; command = "systemctl suspend"; } # 90 min: suspend
    ];
  };

  # ── Mako notifications ────────────────────────────────────────────────
  services.mako.enable = true;
}
