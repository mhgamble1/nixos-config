{ ... }:

{
  # ── Home Assistant — self-hosted home automation ───────────────────────
  # Reachable at http://<tailscale-ip>:8123 via Tailscale, and also on the
  # home LAN like a normal HA install (Pi/NAS/etc. run no host firewall at
  # all — the router's NAT is the trust boundary, and every other
  # smart-home device on the LAN is equally "trusted"). mDNS/SSDP are
  # opened too so HA can discover devices broadcasting on the LAN.
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
}
