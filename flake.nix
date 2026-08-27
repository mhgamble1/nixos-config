{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents-nix.url = "github:numtide/llm-agents.nix";
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { nixpkgs, home-manager, llm-agents-nix, zen-browser, plasma-manager, ... }:
    let
      # secrets.nix is gitignored — requires --impure on rebuild so Nix can access it.
      # Run: sudo nixos-rebuild switch --flake /etc/nixos --impure
      # (The nrs/nrb aliases already include --impure.)
      secrets = import /etc/nixos/secrets.nix;

      # Shared Home Manager config block — same for all hosts
      hmConfig = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit secrets llm-agents-nix; };
        home-manager.users.mhg = import ./home/mhg;
        home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
      };
    in
    {
      nixosConfigurations = {

        # Desktop — AMD CPU, NVIDIA GPU, daily driver
        # STATUS: dormant since t14 became primary daily driver (2026-08) —
        # hardware kept powered off but not decommissioned. Config is left
        # buildable for a future revival; if the hardware is ever recycled
        # for good, delete this block the same way `laptop` was retired.
        # nixos-rebuild switch --flake /etc/nixos#desktop
        desktop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit secrets zen-browser; };
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            ./hosts/desktop
            home-manager.nixosModules.home-manager
            hmConfig
          ];
        };

        # T14 — ThinkPad T14 gen2, Intel i7-1165G7, primary daily driver
        # nixos-rebuild switch --flake /etc/nixos#t14
        t14 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit secrets; };
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            ./hosts/t14
            home-manager.nixosModules.home-manager
            hmConfig
          ];
        };

        # xps-server — Dell XPS 13 9360, headless Home Assistant box.
        # No home-manager: this is a dedicated single-purpose server, not
        # a desktop, so mhg's personal app/dotfile config doesn't apply.
        # nixos-rebuild switch --flake /etc/nixos#xps-server
        xps-server = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit secrets; };
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            ./hosts/xps-server
          ];
        };

      };
    };
}
