{ ... }:

{
  flake.modules.nixos.networking = { config, pkgs, ... }: {
    networking.networkmanager.enable = true;
    networking.networkmanager.unmanaged = [ "interface-name:wlp4s0" ];

    services.tailscale.enable = true;
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
    networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];

    environment.systemPackages = [
      (pkgs.runCommand "tailscale-vpn-scripts" { } ''
        mkdir -p $out/bin
        install -m755 ${../scripts/tailscale-exit-node-set.sh} $out/bin/tailscale-exit-node-set
        install -m755 ${../scripts/vpn-on.sh} $out/bin/vpn-on
        install -m755 ${../scripts/vpn-off.sh} $out/bin/vpn-off
      '')
    ];

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}
