{ ... }:

{
  flake.modules.homeManager.terminal = { config, pkgs, lib, ... }: {
    # ── Modern Unix utilities ─────────────────────────────────────────────
    home.packages = with pkgs; [
      # ls → eza
      eza
      exercism
      fd
      ripgrep
      # cat → bat  (configured as program below)
      # du → dust
      dust
      # df → duf
      duf
      # ps → procs
      procs
      # sed → sd
      sd
      # top → bottom
      bottom
      # tldr pages
      tealdeer
      # YAML/JSON/TOML/XML processor (like jq but for everything)
      yq-go
      # HTTP client (httpie-like, with --json)
      xh
      # Universal archive tool (handles zip, tar, gz, zst, 7z…)
      ouch
      # Count lines of code
      tokei
      # Structural diff (understands syntax, not just text)
      difftastic
      # Watch files and re-run commands
      watchexec
      # cut/awk replacement
      choose
      # Hex viewer
      hexyl
      # TUI git client
      lazygit
      jujutsu

      # ── General CLI/GUI packages ──
      wl-clipboard
      jq
      htop
      unzip
      google-chrome
      discord
      xdg-terminal-exec
      zola
      vlc
      zathura
      aria2
      yt-dlp
      nicotine-plus
      ffmpeg
    ];

    # zoxide — smarter cd
    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    # fzf — fuzzy finder (Ctrl+R history, Ctrl+T file picker, Alt+C dir jump)
    programs.fzf = {
      enable = true;
      enableFishIntegration = true;
      defaultOptions = [
        "--height=40%"
        "--layout=reverse"
        "--border"
        "--color=bg+:#24283b,bg:#1a1b26,spinner:#7aa2f7,hl:#7dcfff"
        "--color=fg:#c0caf5,header:#7aa2f7,info:#bb9af7,pointer:#7aa2f7"
        "--color=marker:#9ece6a,fg+:#c0caf5,prompt:#7aa2f7,hl+:#7dcfff"
      ];
    };

    programs.ghostty = {
      enable = true;
      settings = {
        font-family = "JetBrainsMono Nerd Font";
        font-size = 13;

        # Tokyo Night colors
        background = "#1a1b26";
        foreground = "#c0caf5";
        cursor-color = "#c0caf5";
        selection-background = "#283457";
        selection-foreground = "#c0caf5";

        palette = [
          "0=#15161e" # black
          "1=#f7768e" # red
          "2=#9ece6a" # green
          "3=#e0af68" # yellow
          "4=#7aa2f7" # blue
          "5=#bb9af7" # magenta
          "6=#7dcfff" # cyan
          "7=#a9b1d6" # white
          "8=#414868" # bright black
          "9=#f7768e" # bright red
          "10=#9ece6a" # bright green
          "11=#e0af68" # bright yellow
          "12=#7aa2f7" # bright blue
          "13=#bb9af7" # bright magenta
          "14=#7dcfff" # bright cyan
          "15=#c0caf5" # bright white
        ];

        background-opacity = 0.95;
        window-padding-x = 10;
        window-padding-y = 8;
        window-decoration = true;

        gtk-tabs-location = "bottom";
        gtk-single-instance = false;

        scrollback-limit = 10000;
        mouse-hide-while-typing = true;
        clipboard-read = "allow";
        clipboard-write = "allow";

      };
    };

    programs.fish = {
      enable = true;

      interactiveShellInit = ''
        # Suppress greeting
        set fish_greeting ""

        # Bun global bin
        fish_add_path /home/mhg/.cache/.bun/bin

        # Use vim keybindings in fish
        fish_vi_key_bindings

        # Restore emacs-style line navigation in insert mode
        bind --mode insert \ca beginning-of-line
        bind --mode insert \ce end-of-line
      '';

      shellAliases = {
        ".." = "cd ..";
        "..." = "cd ../..";
        ls = "eza --icons --group-directories-first";
        ll = "eza -lah --icons --group-directories-first --git";
        la = "eza -lah --icons --group-directories-first";
        lt = "eza --tree --icons --level=2";
        lta = "eza --tree --icons --level=2 -a";

        cat = "bat";
        diff = "difft";
        du = "dust";
        df = "duf";
        ps = "procs";
        top = "btm";
      };

      functions = {
        nrs = {
          description = "NixOS rebuild switch for current host";
          body = "sudo nixos-rebuild switch --flake /etc/nixos#(hostname) --impure $argv";
        };
        nrsu = {
          description = "NixOS rebuild switch with flake update for current host";
          body = "sudo nix flake update --flake /etc/nixos && sudo nixos-rebuild switch --flake /etc/nixos#(hostname) --impure $argv";
        };
        nrb = {
          description = "NixOS rebuild boot for current host";
          body = "sudo nixos-rebuild boot --flake /etc/nixos#(hostname) --impure $argv";
        };
        nrbu = {
          description = "NixOS rebuild boot with flake update for current host";
          body = "sudo nix flake update --flake /etc/nixos && sudo nixos-rebuild boot --flake /etc/nixos#(hostname) --impure $argv";
        };
        nre = {
          description = "Evaluate NixOS config for current host without building";
          body = "nix eval --impure --raw /etc/nixos#nixosConfigurations.(hostname).config.system.build.toplevel.drvPath $argv";
        };
        nrd = {
          description = "NixOS dry-build for current host (build without activating)";
          body = "sudo nixos-rebuild dry-build --flake /etc/nixos#(hostname) --impure $argv";
        };
      };
    };

    programs.bat = {
      enable = true;
      config = {
        theme = "TwoDark";
        style = "numbers,changes,header";
      };
    };

    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        format = lib.concatStrings [
          "$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$git_status"
          "$cmd_duration"
          "$line_break"
          "$character"
        ];

        directory = {
          truncation_length = 4;
          truncate_to_repo = true;
          style = "bold blue";
        };

        git_branch = {
          format = "[$symbol$branch]($style) ";
          symbol = " ";
          style = "bold purple";
        };

        git_status = {
          format = "([\\[$all_status$ahead_behind\\]]($style) )";
          style = "bold red";
        };

        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
          vimcmd_symbol = "[❮](bold green)";
        };

        cmd_duration = {
          min_time = 2000;
          format = "took [$duration]($style) ";
          style = "bold yellow";
        };
      };
    };
  };
}
