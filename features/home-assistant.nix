{ ... }:

{
  flake.modules.nixos.home-assistant = { ... }: {
    networking.firewall.allowedTCPPorts = [ 8123 ];
    networking.firewall.allowedUDPPorts = [ 5353 1900 ];

    services.home-assistant = {
      enable = true;
      config = {
        default_config = { };
        homeassistant = {
          name = "Home";
          time_zone = "America/New_York";
          unit_system = "us_customary";
        };
      };
    };
  };
}
