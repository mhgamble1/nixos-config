{ ... }:

{
  flake.modules.nixos.niri = { pkgs, flakeModules, ... }: {
    imports = [ flakeModules.nixos.graphical-session-base ];

    programs.niri.enable = true;

    programs.niri.package = pkgs.niri-unstable;
  };

  flake.modules.homeManager.niri = { pkgs, lib, ... }: {
    home.packages = with pkgs; [
      wl-clipboard
      playerctl
      brightnessctl
    ];

    programs.niri.settings = {
      environment.NIXOS_OZONE_WL = "1";

      xwayland-satellite = {
        enable = true;
        path = lib.getExe pkgs.xwayland-satellite-unstable;
      };

      input = {
        keyboard.xkb.layout = "us";
        touchpad.tap = true;
      };

      outputs."eDP-1".scale = 1.5;

      spawn-at-startup = [
        { argv = [ "noctalia" ]; }
      ];

      binds = {
        "Mod+Return".action.spawn = "${pkgs.ghostty}/bin/ghostty";
        "Mod+D".action.spawn-sh = "noctalia msg panel-toggle launcher";
        "Mod+Shift+L".action.spawn-sh = "noctalia msg session lock";

        "XF86AudioRaiseVolume" = { allow-when-locked = true; action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+ -l 1.0"; };
        "XF86AudioLowerVolume" = { allow-when-locked = true; action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-"; };
        "XF86AudioMute" = { allow-when-locked = true; action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; };
        "XF86AudioPlay" = { allow-when-locked = true; action.spawn-sh = "playerctl play-pause"; };
        "XF86AudioNext" = { allow-when-locked = true; action.spawn-sh = "playerctl next"; };
        "XF86AudioPrev" = { allow-when-locked = true; action.spawn-sh = "playerctl previous"; };
        "XF86MonBrightnessUp" = { allow-when-locked = true; action.spawn = [ "brightnessctl" "set" "5%+" ]; };
        "XF86MonBrightnessDown" = { allow-when-locked = true; action.spawn = [ "brightnessctl" "set" "5%-" ]; };

        # Upstream niri default binds (from niri's resources/default-config.kdl),
        # ported here since this flake's settings module starts with no binds at all.
        "Mod+Q".action.close-window = { };

        "Mod+Left".action.focus-column-left = { };
        "Mod+Down".action.focus-window-down = { };
        "Mod+Up".action.focus-window-up = { };
        "Mod+Right".action.focus-column-right = { };

        "Mod+Ctrl+Left".action.move-column-left = { };
        "Mod+Ctrl+Down".action.move-window-down = { };
        "Mod+Ctrl+Up".action.move-window-up = { };
        "Mod+Ctrl+Right".action.move-column-right = { };
        "Mod+Ctrl+H".action.move-column-left = { };
        "Mod+Ctrl+J".action.move-window-down = { };
        "Mod+Ctrl+K".action.move-window-up = { };
        "Mod+Ctrl+L".action.move-column-right = { };

        "Mod+Home".action.focus-column-first = { };
        "Mod+End".action.focus-column-last = { };
        "Mod+Ctrl+Home".action.move-column-to-first = { };
        "Mod+Ctrl+End".action.move-column-to-last = { };

        "Mod+Shift+Right".action.focus-monitor-right = { };

        "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = { };
        "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = { };
        "Mod+Ctrl+U".action.move-column-to-workspace-down = { };
        "Mod+Ctrl+I".action.move-column-to-workspace-up = { };

        "Mod+WheelScrollDown" = { cooldown-ms = 150; action.focus-workspace-down = { }; };
        "Mod+WheelScrollUp" = { cooldown-ms = 150; action.focus-workspace-up = { }; };
        "Mod+Ctrl+WheelScrollDown" = { cooldown-ms = 150; action.move-column-to-workspace-down = { }; };
        "Mod+Ctrl+WheelScrollUp" = { cooldown-ms = 150; action.move-column-to-workspace-up = { }; };

        "Mod+WheelScrollRight".action.focus-column-right = { };
        "Mod+WheelScrollLeft".action.focus-column-left = { };
        "Mod+Ctrl+WheelScrollRight".action.move-column-right = { };
        "Mod+Ctrl+WheelScrollLeft".action.move-column-left = { };

        "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = { };
        "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = { };

        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;

        "Mod+Ctrl+1".action.move-column-to-workspace = 1;
        "Mod+Ctrl+2".action.move-column-to-workspace = 2;
        "Mod+Ctrl+3".action.move-column-to-workspace = 3;
        "Mod+Ctrl+4".action.move-column-to-workspace = 4;
        "Mod+Ctrl+5".action.move-column-to-workspace = 5;
        "Mod+Ctrl+6".action.move-column-to-workspace = 6;
        "Mod+Ctrl+7".action.move-column-to-workspace = 7;
        "Mod+Ctrl+8".action.move-column-to-workspace = 8;
        "Mod+Ctrl+9".action.move-column-to-workspace = 9;

        "Mod+BracketLeft".action.consume-or-expel-window-left = { };
        "Mod+BracketRight".action.consume-or-expel-window-right = { };

        "Mod+Comma".action.consume-window-into-column = { };
        "Mod+Period".action.expel-window-from-column = { };

        "Mod+R".action.switch-preset-column-width = { };
        "Mod+Shift+R".action.switch-preset-column-width-back = { };
        "Mod+Ctrl+Shift+R".action.switch-preset-window-height = { };
        "Mod+Ctrl+R".action.reset-window-height = { };

        "Mod+F".action.maximize-column = { };
        "Mod+Ctrl+F".action.expand-column-to-available-width = { };
        "Mod+Ctrl+C".action.center-visible-columns = { };

        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";
      };
    };
  };
}
