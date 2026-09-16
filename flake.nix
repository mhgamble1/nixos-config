{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:epireyn/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, nixpkgs, home-manager, niri, noctalia, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ config, ... }:
    let
      secrets = import /etc/nixos/secrets.nix;
    in
    {
      imports = [
        flake-parts.flakeModules.modules
        (inputs.import-tree ./features)
      ];

      flake.nixosConfigurations = {
        t14 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit secrets; flakeModules = config.flake.modules; };
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            ./hosts/t14
            niri.nixosModules.niri
            noctalia.nixosModules.default
            home-manager.nixosModules.home-manager
            (config.flake.lib.mkHomeManagerConfig {
              extraSharedModules = [ noctalia.homeModules.default ];
            })
          ];
        };

        xps-server = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit secrets; flakeModules = config.flake.modules; };
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            ./hosts/xps-server
          ];
        };

      };
    });
}
