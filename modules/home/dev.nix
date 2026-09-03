{ config, pkgs, lib, ... }:

{
  # ── Go ────────────────────────────────────────────────────────────────
  programs.go = {
    enable = true;
    env = {
      GOPATH = "/home/mhg/go";
      GOBIN = "/home/mhg/go/bin";
    };
  };

  # ── Dev packages ──────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Go
    gopls
    go-tools

    # Python
    uv
    python3
    pyright
    ruff

    # Nix
    nil # Nix LSP
    nixpkgs-fmt # Nix formatter

    bun
    pnpm

    zed-editor

    sqlite

    bubblewrap

    gh

    sox
  ];
}
