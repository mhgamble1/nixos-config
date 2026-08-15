{ pkgs, ... }:

# Home-manager GNOME config — extensions, dconf settings, GUI tools.
# Used by: laptop, t14 (imported conditionally in home/mhg/default.nix by
# hostName). Pair with modules/nixos/gnome.nix for the session.
{
  # ── GNOME Shell extensions ────────────────────────────────────────────
  home.packages = with pkgs; [
    gnomeExtensions.vitals
    gnomeExtensions.dash-to-dock
    gnome-tweaks
    dconf-editor
  ];

  dconf.settings = {
    # Touchpad — GNOME overrides libinput so must be set here too
    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = false;
      tap-to-click = true;
    };

    "org/gnome/shell" = {
      enabled-extensions = [
        "Vitals@CoreCoding.com"
        "dash-to-dock@micxgx.gmail.com"
      ];
    };

    # Titlebar buttons — stock GNOME ships close-only; add minimize/maximize.
    # Fixed workspace count instead of GNOME's default dynamic grow/shrink.
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
      num-workspaces = 4;
    };
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
    };

    # Dash to Dock — captured from live settings via Extensions app GUI
    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-fixed = false;               # autohide, not always pinned visible
      autohide = true;
      dock-position = "BOTTOM";
      extend-height = false;            # icon-sized bar, not full screen edge to edge
      background-opacity = 0.8;
      dash-max-icon-size = 48;
      height-fraction = 0.9;
      intellihide-mode = "FOCUS_APPLICATION_WINDOWS";
    };

    # Vitals preferences — show the stats most useful on a laptop
    "org/gnome/shell/extensions/vitals" = {
      show-cpu = true;
      show-memory = true;
      show-battery = true;
      show-network = true;
      show-temperature = true;
      show-fan = false;
      show-storage = false;
      show-voltage = false;
      show-system = false;
      hot-sensors = [ "_processor_usage_" "_memory_usage_" ];
      position-in-panel = 0; # left of the status area
    };
  };
}
