{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;

  # ── Tailscale ─────────────────────────────────────────────────────────
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];

  # ── SSH ───────────────────────────────────────────────────────────────
  # PasswordAuthentication and root login are disabled.
  # Firewall access is via tailscale0 (trustedInterfaces above).
  # To restrict sshd to the Tailscale interface only, set:
  #   services.openssh.settings.ListenAddress = "<tailscale-ip>";
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # ── Mullvad VPN ───────────────────────────────────────────────────────
  services.mullvad-vpn.enable = true;
}
