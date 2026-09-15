{ config, lib, pkgs, ... }:

{
  hardware.enableRedistributableFirmware = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "suspend-then-hibernate";
    HandleSuspendKey = "suspend-then-hibernate";

    IdleAction = "suspend-then-hibernate";
    IdleActionSec = "15min";
  };

  systemd.sleep.settings.Sleep.HibernateDelaySec = "2h";

  boot.resumeDevice = "/dev/disk/by-uuid/2ba9bbb1-a3e8-4d3e-a625-c4e49906ca97";

  services.upower = {
    enable = true;
    percentageLow = 15;
    percentageCritical = 5;
    percentageAction = 3;
    criticalPowerAction = "Hibernate";
  };
}
