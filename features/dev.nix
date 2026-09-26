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
      clang
      gnumake
      gopls
      go-tools
      uv
      python3
      pyright
      ruff
      nil
      nixd
      nixpkgs-fmt
      bun
      pnpm
      yarn-berry
      ansible
      sqlite
      bubblewrap
      gh
      sox
    ] ++ (with pkgs.elmPackages; [
      elm
      elm-format
      elm-test
      elm-json
    ]);

    programs.zed-editor = {
      enable = true;
      extraPackages = [ pkgs.elmPackages.elm-language-server ];
      extensions = [ "elm" "nix" ];
      userSettings = {
        languages.Elm.format_on_save = "on";
      };
    };
  };
}
