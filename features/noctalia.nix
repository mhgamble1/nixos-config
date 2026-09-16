{ ... }:

{
  flake.modules.nixos.noctalia = { ... }: {
    programs.noctalia.enable = true;

    services.power-profiles-daemon.enable = false;

    services.displayManager.noctalia-greeter = {
      enable = true;
      settings.keyboard.layout = "us";
    };
  };

  flake.modules.homeManager.noctalia = { ... }: {
    programs.noctalia.enable = true;
  };
}
