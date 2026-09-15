{ config, ... }:

# Shared home-manager wiring, exposed as a library function rather than a
# flake.modules.* feature — this is cross-cutting flake-parts/home-manager
# glue (how home-manager gets integrated as a NixOS module), not itself a
# feature a host opts into. Each host's nixosSystem in flake.nix calls
# config.flake.lib.mkHomeManagerConfig, passing only the sharedModules that
# host actually needs (e.g. plasma-manager, kde-only).

let
  # secrets.nix is gitignored — requires --impure on rebuild so Nix can
  # access it. Run: sudo nixos-rebuild switch --flake /etc/nixos --impure
  # (The nrs/nrb aliases already include --impure.)
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
        config.flake.modules.homeManager.music
        config.flake.modules.homeManager.agents
        config.flake.modules.homeManager.dev
        config.flake.modules.homeManager.terminal
        config.flake.modules.homeManager.theming
      ];
    };
    home-manager.sharedModules = extraSharedModules;
    # KDE's own subsystems (kde-gtk-config, font management, etc.) write
    # directly into paths home-manager also manages, the moment you touch
    # the relevant System Settings page — turning a home-manager-owned
    # symlink into a plain file underneath it. Without this, the next
    # activation fails outright on "would be clobbered" for whichever
    # file KDE touched last, one at a time. Auto-backing up instead of
    # failing is the documented remedy for exactly this NixOS-module
    # situation (see the home-manager-mhg.service error text). Harmless
    # on hosts without KDE too, so applied unconditionally.
    home-manager.backupFileExtension = "hm-bak";
  };
}
