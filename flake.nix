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
      # secrets.nix is gitignored — requires --impure on rebuild so Nix can access it.
      # Run: sudo nixos-rebuild switch --flake /etc/nixos --impure
      # (The nrs/nrb aliases already include --impure.)
      secrets = import /etc/nixos/secrets.nix;
    in
    {
      imports = [
        flake-parts.flakeModules.modules
        (inputs.import-tree ./features)
      ];

      flake.nixosConfigurations = {

        # Desktop — AMD CPU, NVIDIA GPU, daily driver
        # STATUS: dormant since t14 became primary daily driver (2026-08) —
        # hardware kept powered off but not decommissioned. Config is left
        # buildable for a future revival; if the hardware is ever recycled
        # for good, delete this block the same way `laptop` was retired.
        # nixos-rebuild switch --flake /etc/nixos#desktop
        desktop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit secrets; flakeModules = config.flake.modules; };
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            ./hosts/desktop
            home-manager.nixosModules.home-manager
            (config.flake.lib.mkHomeManagerConfig { })
          ];
        };

        # T14 — ThinkPad T14 gen2, Intel i7-1165G7, primary daily driver
        # nixos-rebuild switch --flake /etc/nixos#t14
        t14 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit secrets; flakeModules = config.flake.modules; };
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            ./hosts/t14
            # niri.homeModules.niri is deliberately NOT added here: when
            # home-manager is used as a NixOS module (as it is below)
            # alongside niri.nixosModules.niri, niri-flake auto-imports its
            # home-manager config module (niri.homeModules.config, which
            # provides `programs.niri.settings`) for you. Adding
            # homeModules.niri too double-imports that module and fails the
            # build with "option ... is already declared" — confirmed by
            # trying it.
            niri.nixosModules.niri
            home-manager.nixosModules.home-manager
            (config.flake.lib.mkHomeManagerConfig {
              extraSharedModules = [ plasma-manager.homeModules.plasma-manager ];
            })
          ];
        };

        # xps-server — Dell XPS 13 9360, headless Home Assistant box.
        # No home-manager: this is a dedicated single-purpose server, not
        # a desktop, so mhg's personal app/dotfile config doesn't apply.
        # nixos-rebuild switch --flake /etc/nixos#xps-server
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
