{ pkgs, ... }:

{
  # ── GNOME Shell extensions ────────────────────────────────────────────
  home.packages = with pkgs; [
    gnomeExtensions.vitals
  ];

  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [ "Vitals@CoreCoding.com" ];
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
