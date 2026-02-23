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
          hidden = false;  # show dotfiles
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
      GOBIN  = "/home/mhg/go/bin";
    };
  };

  # ── Dev packages ──────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Go tooling
    gopls       # Go LSP
    gotools     # goimports, godoc, etc.
    go-tools    # staticcheck

    # Python
    uv          # fast Python package/project manager
    python3     # system Python fallback
    pyright     # Python LSP (type checking + completion)
    ruff        # Python linter + formatter (also LSP)

    # Nix
    nil         # Nix LSP
    nixpkgs-fmt # Nix formatter

    # SQLite
    sqlite      # SQLite CLI
    litecli     # Better SQLite CLI (autocomplete, syntax highlighting)
  ];
}
