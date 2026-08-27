{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # TIDAL client
    sone
  ];
}
