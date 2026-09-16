{ ... }:

{
  flake.modules.nixos.services = { pkgs, ... }: {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
  };
}
