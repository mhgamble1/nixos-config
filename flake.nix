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
  };

  outputs = { nixpkgs, home-manager, llm-agents-nix, zen-browser, ... }:
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
      };
    in
    {
      nixosConfigurations = {

        # Desktop — AMD CPU, NVIDIA GPU, daily driver
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

        # Laptop — Intel, GNOME, daily-carry laptop
        # nixos-rebuild switch --flake /etc/nixos#laptop
        laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit secrets; };
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            ./hosts/laptop
            home-manager.nixosModules.home-manager
            hmConfig
          ];
        };

        # T14 — ThinkPad T14 gen2, Intel i7-1165G7 (scaffold, not yet provisioned)
        # Add hosts/t14/hardware-configuration.nix before deploying
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

      };
    };
}
