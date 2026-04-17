{ pkgs, ... }:

{
  home.packages = with pkgs; [
    lmms
    sunvox
    audacity
  ];
}
