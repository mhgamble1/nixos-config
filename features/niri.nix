{ ... }:

{
  flake.modules.nixos.niri = { pkgs, ... }: {
    programs.niri.enable = true;

    programs.niri.package = pkgs.niri;
  };

  flake.modules.homeManager.niri = { pkgs, ... }: {
    home.packages = with pkgs; [
      swaylock
      swayidle
      wl-clipboard
      pavucontrol
      networkmanagerapplet
      playerctl
      brightnessctl
    ];

    programs.niri.settings = {
      environment.NIXOS_OZONE_WL = "1";

      environment.QT_QPA_PLATFORMTHEME = "adwaita";
      environment.QT_STYLE_OVERRIDE = "adwaita-dark";

      input = {
        keyboard.xkb.layout = "us";
        touchpad.tap = true;
      };

      outputs."eDP-1".scale = 1.5;

      layout.gaps = 8;

      spawn-at-startup = [
        { argv = [ "mako" ]; }
        { argv = [ "nm-applet" "--indicator" ]; }
        { argv = [ "blueman-applet" ]; }
      ];

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

    programs.fuzzel = {
      enable = true;
      settings.main = {
        terminal = "${pkgs.ghostty}/bin/ghostty -e";
        width = 40;
        lines = 15;
      };
    };

    services.swayidle = {
      enable = true;
      events = {
        before-sleep = "swaylock -f";
        lock = "swaylock -f";
      };
      timeouts = [
        { timeout = 1500; command = "swaylock -f"; }
        { timeout = 5400; command = "systemctl suspend"; }
      ];
    };

    services.mako.enable = true;
  };
}
