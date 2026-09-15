{ ... }:

{
  flake.modules.homeManager.theming = { config, pkgs, ... }: {
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

    # Qt apps (e.g. anything built on Qt) — niri has no native Qt platform
    # integration, so this is needed there. KDE ships its own
    # (plasma-integration, the "kde" platform theme) and additionally
    # expects widgetStyle/Kvantum to control styling via kdeglobals, so it
    # must stay untouched under KDE.
    #
    # t14 offers both KDE and niri as SDDM session choices — which one is
    # active is a runtime login pick, not something home-manager can see at
    # build/activation time. home-manager's `qt.enable` can't be scoped to
    # "niri only" for that reason: it writes QT_QPA_PLATFORMTHEME /
    # QT_STYLE_OVERRIDE into ~/.profile and systemd --user's environment.d,
    # both of which apply to the whole user account regardless of which
    # session was picked — confirmed live previously (that's why this used
    # to be disabled for all of t14, back when t14 was KDE-only). The one
    # mechanism here that's genuinely session-scoped is niri's own
    # `environment` setting (features/niri.nix) — niri only injects those
    # vars into processes *it* spawns, never into a KDE session. So: just
    # install the theme packages here, and set the actual
    # QT_QPA_PLATFORMTHEME / QT_STYLE_OVERRIDE env vars over in niri.nix.
    home.packages = with pkgs; [
      adwaita-qt
      qadwaitadecorations
      qadwaitadecorations-qt6
    ];
  };
}
