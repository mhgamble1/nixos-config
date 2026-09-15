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
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, nixpkgs, home-manager, plasma-manager, niri, ... }:
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
        desktop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit secrets; flakeModules = config.flake.modules; };
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            ./hosts/desktop
            home-manager.nixosModules.home-manager
            (config.flake.lib.mkHomeManagerConfig { })
          ];
        };

        t14 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit secrets; flakeModules = config.flake.modules; };
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            ./hosts/t14
            niri.nixosModules.niri
            home-manager.nixosModules.home-manager
            (config.flake.lib.mkHomeManagerConfig {
              extraSharedModules = [ plasma-manager.homeModules.plasma-manager ];
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
