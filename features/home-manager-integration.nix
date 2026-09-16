{ config, ... }:

let
  secrets = import /etc/nixos/secrets.nix;
in
{
  flake.lib.mkHomeManagerConfig = { extraSharedModules ? [ ] }: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = { inherit secrets; flakeModules = config.flake.modules; };
    home-manager.users.mhg = {
      imports = [
        (import ../home/mhg)
        config.flake.modules.homeManager.extras
        config.flake.modules.homeManager.dev
        config.flake.modules.homeManager.terminal
      ];
    };
    home-manager.sharedModules = extraSharedModules;

    home-manager.backupFileExtension = "hm-bak";
  };
}
