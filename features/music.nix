{ ... }:

{
  flake.modules.homeManager.music = { pkgs, ... }: {
    home.packages = with pkgs; [
      sone
    ];
  };
}
