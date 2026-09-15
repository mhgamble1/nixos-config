{ ... }:

{
  flake.modules.nixos.peripherals = { ... }: {
    hardware.logitech.wireless.enable = true;
    programs.solaar.enable = true;

    hardware.bluetooth.settings = {
      General = {
        FastConnectable = true;
        JustWorksRepairing = "always";
      };
    };

    boot.extraModprobeConfig = ''
      options btusb enable_autosuspend=0
    '';
  };
}
