{ ... }:

{
  flake.modules.nixos.users = { pkgs, secrets, ... }: {
    users.users.mhg = {
      isNormalUser = true;
      description = "mhg";
      shell = pkgs.fish;
      extraGroups = [ "networkmanager" "wheel" "audio" ];
      openssh.authorizedKeys.keys = secrets.authorizedKeys.mark;
    };

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.noto
    ];
  };
}
