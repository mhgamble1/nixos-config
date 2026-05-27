{ ... }:

{
  # ── Audiobookshelf — self-hosted audiobook/podcast server ─────────────
  services.audiobookshelf = {
    enable = true;
    host = "0.0.0.0";
    port = 13378;
    # dataDir defaults to /var/lib/audiobookshelf — NixOS creates and owns it.
    # Add library folders (NAS, local) via the web UI after first launch.
  };

  networking.firewall.allowedTCPPorts = [ 13378 ];
}
