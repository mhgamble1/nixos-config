{ ... }:

{
  # ── Home Assistant — self-hosted home automation ───────────────────────
  # Reachable at http://<tailscale-ip>:8123 — tailscale0 is a trusted
  # firewall interface (see networking.nix), so no LAN port is opened.
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
