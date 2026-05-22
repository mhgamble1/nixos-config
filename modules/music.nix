{ pkgs, ... }:

{
  home.packages = with pkgs; [
    lmms
    sunvox
    audacity
    rescrobbled
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
