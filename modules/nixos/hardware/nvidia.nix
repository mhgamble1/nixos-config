{ config, ... }:

{
  # ── NVIDIA proprietary drivers ────────────────────────────────────────
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;  # adds nvidia-suspend/resume hooks; fixes Wayland wake
    powerManagement.finegrained = false;
    open = true;  # RTX 30xx+ (Ampere): open module has better Wayland stability
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.graphics.enable = true;
}
