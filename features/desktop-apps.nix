{ ... }:

{
  flake.modules.homeManager.desktop-apps = { pkgs, config, ... }:
    let
      nuvio-desktop =
        let
          pname = "nuvio-desktop";
          version = "0.1.26-alpha";
          src = pkgs.fetchurl {
            url = "https://github.com/NuvioMedia/NuvioDesktop/releases/download/${version}/Nuvio-Linux-x86_64-${version}.AppImage";
            hash = "sha256-NnXsPEF99eNZf8pGPwbCcRkXbcZPdbmZLdLGnXVjNHk=";
          };
          appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
        in
        pkgs.appimageTools.wrapType2 {
          inherit pname version src;
          extraInstallCommands = ''
            install -m 444 -D ${appimageContents}/Nuvio.desktop $out/share/applications/${pname}.desktop
            substituteInPlace $out/share/applications/${pname}.desktop \
              --replace-fail 'Exec=AppRun' 'Exec=${pname}' \
              --replace-fail 'Icon=Nuvio' 'Icon=${pname}'
            install -m 444 -D ${appimageContents}/Nuvio.png $out/share/icons/hicolor/512x512/apps/${pname}.png
          '';
        };
    in
    {
      home.packages = with pkgs; [
        google-chrome
        discord
        vlc
        zathura
        nicotine-plus
        sone
        stremio-linux-shell
        xdg-terminal-exec
        nuvio-desktop
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
