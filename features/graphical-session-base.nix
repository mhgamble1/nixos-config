{ ... }:

{
  flake.modules.nixos.graphical-session-base = { pkgs, ... }: {
    services.xserver.enable = true;
    services.xserver.excludePackages = [ pkgs.xterm ];

    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    services.printing.enable = true;

    programs.firefox.enable = true;
  };
}
