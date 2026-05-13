{ pkgs, secrets, ... }:

{
  # ── User account ──────────────────────────────────────────────────────
  users.users.mhg = {
    isNormalUser = true;
    description = "mhg";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" "audio" ];
    openssh.authorizedKeys.keys = secrets.authorizedKeys.mark;
  };

  # ── Fonts ─────────────────────────────────────────────────────────────
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.noto
  ];
}
