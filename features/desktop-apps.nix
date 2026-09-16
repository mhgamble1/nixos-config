{ ... }:

{
  flake.modules.homeManager.desktop-apps = { pkgs, config, ... }: {
    home.packages = with pkgs; [
      google-chrome
      discord
      vlc
      zathura
      nicotine-plus
      sone
      xdg-terminal-exec
    ];

    programs.firefox = {
      enable = true;
      configPath = "${config.xdg.configHome}/mozilla/firefox";
      profiles.mhg = {
        isDefault = true;
        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
        userChrome = ''
          .titlebar-buttonbox-container {
            display: none;
          }
        '';
      };
    };

    programs.ghostty = {
      enable = true;
      settings = {
        font-family = "JetBrainsMono Nerd Font";
        font-size = 13;

        # Tokyo Night colors
        background = "#1a1b26";
        foreground = "#c0caf5";
        cursor-color = "#c0caf5";
        selection-background = "#283457";
        selection-foreground = "#c0caf5";

        palette = [
          "0=#15161e" # black
          "1=#f7768e" # red
          "2=#9ece6a" # green
          "3=#e0af68" # yellow
          "4=#7aa2f7" # blue
          "5=#bb9af7" # magenta
          "6=#7dcfff" # cyan
          "7=#a9b1d6" # white
          "8=#414868" # bright black
          "9=#f7768e" # bright red
          "10=#9ece6a" # bright green
          "11=#e0af68" # bright yellow
          "12=#7aa2f7" # bright blue
          "13=#bb9af7" # bright magenta
          "14=#7dcfff" # bright cyan
          "15=#c0caf5" # bright white
        ];

        background-opacity = 0.95;
        window-padding-x = 10;
        window-padding-y = 8;
        window-decoration = false;

        gtk-tabs-location = "bottom";
        gtk-single-instance = false;

        scrollback-limit = 10000;
        mouse-hide-while-typing = true;
        clipboard-read = "allow";
        clipboard-write = "allow";
      };
    };
  };
}
