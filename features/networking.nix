{ ... }:

{
  flake.modules.nixos.networking = { config, pkgs, ... }: {
    networking.networkmanager.enable = true;
    networking.networkmanager.unmanaged = [ "interface-name:wlp4s0" ];

    services.tailscale.enable = true;
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
    networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}
