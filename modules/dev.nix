{ config, pkgs, lib, ... }:

{
  # ── Helix ─────────────────────────────────────────────────────────────
  programs.helix = {
    enable = true;

    settings = {
      theme = "tokyonight";

      editor = {
        line-number = "relative";
        mouse = true;
        rulers = [ 80 120 ];
        idle-timeout = 400;
        true-color = true;
        color-modes = true;
        completion-trigger-len = 2;
        bufferline = "multiple";

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        file-picker = {
          hidden = false; # show dotfiles
        };

        indent-guides = {
          render = true;
          character = "╎";
        };

        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };

        statusline = {
          left = [ "mode" "spinner" "file-name" "file-modification-indicator" ];
          center = [ ];
          right = [ "diagnostics" "selections" "position" "file-encoding" "file-type" ];
          separator = "│";
          mode = {
            normal = "NOR";
            insert = "INS";
            select = "SEL";
          };
        };
      };
    };

    languages = {
      language-server = {
        zk = {
          command = "zk";
          args = [ "lsp" ];
        };
        gopls = {
          command = "gopls";
        };
        pyright = {
          command = "pyright-langserver";
          args = [ "--stdio" ];
        };
        ruff = {
          command = "ruff";
          args = [ "server" ];
        };
        nil = {
          command = "nil";
        };
      };

      language = [
        {
          name = "markdown";
          language-servers = [ "zk" ];
          soft-wrap.enable = true;
        }
        {
          name = "go";
          auto-format = true;
          language-servers = [ "gopls" ];
        }
        {
          name = "python";
          auto-format = true;
          language-servers = [ "pyright" "ruff" ];
          formatter = {
            command = "ruff";
            args = [ "format" "-" ];
          };
        }
        {
          name = "nix";
          auto-format = true;
          language-servers = [ "nil" ];
          formatter = {
            command = "nixpkgs-fmt";
          };
        }
      ];
    };
  };

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
    gotools
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

    sqlite
    litecli
    opencode

    gh
  ];

  programs.zed-editor = {
    enable = true;
  };
}
