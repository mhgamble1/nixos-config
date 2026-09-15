{ ... }:

{
  flake.modules.homeManager.theming = { config, pkgs, ... }: {
    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
      iconTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
      };
      gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
      gtk4.theme = config.gtk.theme;
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "adw-gtk3-dark";
      };
    };

    home.packages = with pkgs; [
      adwaita-qt
      qadwaitadecorations
      qadwaitadecorations-qt6
    ];
  };
}
