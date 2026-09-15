{ ... }:

{
  flake.modules.homeManager.dev = { config, pkgs, lib, ... }: {
    programs.go = {
      enable = true;
      env = {
        GOPATH = "/home/mhg/go";
        GOBIN = "/home/mhg/go/bin";
      };
    };

    home.packages = with pkgs; [
      gopls
      go-tools
      uv
      python3
      pyright
      ruff
      nil
      nixpkgs-fmt
      bun
      pnpm
      yarn-berry
      zed-editor
      ansible
      sqlite
      bubblewrap
      gh
      sox
    ];
  };
}
