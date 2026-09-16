{ ... }:

{
  flake.modules.nixos.niri = { pkgs, flakeModules, ... }: {
    imports = [ flakeModules.nixos.graphical-session-base ];

    programs.niri.enable = true;

    programs.niri.package = pkgs.niri;
  };

  flake.modules.homeManager.niri = { pkgs, ... }: {
    home.packages = with pkgs; [
      wl-clipboard
      playerctl
      brightnessctl
    ];

    programs.niri.settings = {
      environment.NIXOS_OZONE_WL = "1";

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
      };
    };
  };
}
