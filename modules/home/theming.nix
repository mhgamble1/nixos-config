{ config, pkgs, lib, osConfig, ... }:

{
  # GTK dark theme — adw-gtk3-dark makes GTK3 apps look like modern GTK4 Adwaita
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

  # GTK4 apps and XDG portals read this for the system color-scheme preference
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3-dark";
    };
  };

  # Qt apps (e.g. anything built on Qt) — GNOME has no native Qt platform
  # integration, so this was needed there. KDE ships its own
  # (plasma-integration, the "kde" platform theme) and additionally
  # expects widgetStyle/Kvantum to control styling via kdeglobals —
  # forcing QT_QPA_PLATFORMTHEME=adwaita / QT_STYLE_OVERRIDE=adwaita-dark
  # here would override that for every Qt app, confirmed live in the
  # generated environment.d config. Skip it on t14.
  qt = lib.mkIf (osConfig.networking.hostName != "t14") {
    enable = true;
    platformTheme.name = "adwaita";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };
}
