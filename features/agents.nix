{ ... }:

{
  flake.modules.homeManager.agents = { pkgs, ... }: {
    home.packages = with pkgs; [
      claude-code
    ];
  };
}
