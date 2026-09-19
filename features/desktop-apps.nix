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
        path = "xscg7vfa.default";
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
        window-decoration = false;
      };
    };
  };
}
