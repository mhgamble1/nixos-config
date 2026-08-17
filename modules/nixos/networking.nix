{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = [ "interface-name:wlp4s0" ];

  # ── Tailscale ─────────────────────────────────────────────────────────
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];

  # vpn-on/vpn-off: toggle a Mullvad exit node on demand. See scripts/.
  environment.systemPackages = [
    (pkgs.runCommand "tailscale-vpn-scripts" { } ''
      mkdir -p $out/bin
      install -m755 ${../../scripts/tailscale-exit-node-set.sh} $out/bin/tailscale-exit-node-set
      install -m755 ${../../scripts/vpn-on.sh} $out/bin/vpn-on
      install -m755 ${../../scripts/vpn-off.sh} $out/bin/vpn-off
    '')
  ];

  # ── SSH ───────────────────────────────────────────────────────────────
  # PasswordAuthentication and root login are disabled.
  # NOTE: services.openssh.openFirewall defaults to true, which opens port
  # 22 globally (all interfaces), not just tailscale0 — trustedInterfaces
  # only affects interfaces listed in it, it doesn't scope other ports'
  # allowlists down to it. So SSH is reachable on the LAN too, key-auth
  # only. To restrict sshd to the Tailscale interface only, set:
  #   services.openssh.settings.ListenAddress = "<tailscale-ip>";
  #   services.openssh.openFirewall = false;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

}
