{ ... }:

{
  flake.modules.nixos.graphical-session-base = { pkgs, ... }: {
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
