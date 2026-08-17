{ pkgs, hiresti, ... }:

{
  home.packages = with pkgs; [
    audacity
    rescrobbled

    # TIDAL clients (non-Electron, side-by-side comparison)
    high-tide
    sone
    hiresti.packages.${pkgs.system}.default
  ];

  systemd.user.services.rescrobbled = {
    Unit = {
      Description = "MPRIS scrobbler for Last.fm";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.rescrobbled}/bin/rescrobbled";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
