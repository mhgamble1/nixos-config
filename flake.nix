{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents-nix.url = "github:numtide/llm-agents.nix";
  };

  outputs = { nixpkgs, home-manager, llm-agents-nix, ... }:
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
  in {
    nixosConfigurations = {

      # Desktop — AMD CPU, NVIDIA GPU, daily driver
      # nixos-rebuild switch --flake /etc/nixos#desktop
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit secrets; };
        modules = [
          ./hosts/desktop
          home-manager.nixosModules.home-manager
          hmConfig
        ];
      };

      # Laptop — Dell XPS (scaffold, not yet provisioned)
      # Add hosts/laptop/hardware-configuration.nix before deploying
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit secrets; };
        modules = [
          ./hosts/laptop
          home-manager.nixosModules.home-manager
          hmConfig
        ];
      };

    };
  };
}
