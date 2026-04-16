{ config, pkgs, lib, ... }:

let
  # Zed has recurring Wayland/NVIDIA hangs on this machine. Force XWayland by
  # removing WAYLAND_DISPLAY from the launched process.
  zedXwayland = pkgs.symlinkJoin {
    name = "zed-editor-xwayland-${pkgs.zed-editor.version}";
    paths = [ pkgs.zed-editor ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/zeditor \
        --unset WAYLAND_DISPLAY \
        --unset XDG_BACKEND
    '';
  };
in
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

    racket

    sqlite
    litecli
    (llm.withPlugins {
      llm-ollama = true;
      llm-jq = true;
    })

    llama-cpp

    bubblewrap

    gh
  ];

  programs.zed-editor = {
    enable = true;
    package = zedXwayland;
    userSettings = {
      auto_update = false;
      vim_mode = false;
      restore_on_startup = "empty_tab";
      restore_on_file_reopen = false;
      session = {
        restore_unsaved_buffers = false;
        trust_all_worktrees = false;
      };
      theme = {
        mode = "dark";
        dark = "One Dark";
        light = "One Light";
      };
      ui_font_size = 16;
      buffer_font_size = 15;
      soft_wrap = "editor_width";
      project_panel = {
        git_status = false;
      };
      file_finder = {
        git_status = false;
      };
      git_panel = {
        button = false;
      };
      telemetry = {
        metrics = false;
        diagnostics = false;
      };
    };
  };
}
