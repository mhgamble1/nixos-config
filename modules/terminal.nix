{ config, pkgs, lib, ... }:

{
  # ── Modern Unix utilities ─────────────────────────────────────────────
  home.packages = with pkgs; [
    # ls → eza
    eza

    # find → fd  (already in home.nix)
    # grep → ripgrep  (already in home.nix)

    # cat → bat  (configured as program below)

    # git diff pager → delta  (wired into git via programs.git.delta below)
    delta

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
  ];

  # zoxide — smarter cd with frecency ranking
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

  # ── Ghostty ───────────────────────────────────────────────────────────
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
        "0=#15161e"   # black
        "1=#f7768e"   # red
        "2=#9ece6a"   # green
        "3=#e0af68"   # yellow
        "4=#7aa2f7"   # blue
        "5=#bb9af7"   # magenta
        "6=#7dcfff"   # cyan
        "7=#a9b1d6"   # white
        "8=#414868"   # bright black
        "9=#f7768e"   # bright red
        "10=#9ece6a"  # bright green
        "11=#e0af68"  # bright yellow
        "12=#7aa2f7"  # bright blue
        "13=#bb9af7"  # bright magenta
        "14=#7dcfff"  # bright cyan
        "15=#c0caf5"  # bright white
      ];

      # Window
      background-opacity = 0.95;
      window-padding-x = 10;
      window-padding-y = 8;
      window-decoration = false;

      # Tab bar
      gtk-tabs-location = "bottom";
      gtk-single-instance = false;

      # Behavior
      scrollback-limit = 10000;
      mouse-hide-while-typing = true;
      clipboard-read = "allow";
      clipboard-write = "allow";

      # Keybinds — pane navigation (vim-style)
      keybind = [
        "ctrl+shift+h=goto_split:left"
        "ctrl+shift+l=goto_split:right"
        "ctrl+shift+k=goto_split:top"
        "ctrl+shift+j=goto_split:bottom"
        "ctrl+shift+backslash=new_split:right"
        "ctrl+shift+minus=new_split:down"
        "ctrl+shift+q=close_surface"
      ];
    };
  };

  # ── tmux ──────────────────────────────────────────────────────────────
  programs.tmux = {
    enable = true;
    prefix = "C-a";            # Ctrl+a as prefix (instead of Ctrl+b)
    baseIndex = 1;             # Windows start at 1, not 0
    historyLimit = 10000;
    mouse = true;
    terminal = "tmux-256color";

    extraConfig = ''
      # True color support
      set -ag terminal-overrides ",xterm-256color:RGB"

      # Pane indexing
      setw -g pane-base-index 1

      # Vim-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Resize panes with vim keys (repeatable)
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Split panes with more intuitive keys
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # New window in current path
      bind c new-window -c "#{pane_current_path}"

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded"

      # Quick pane cycling
      bind -n M-o select-pane -t :.+

      # Status bar (minimal, Tokyo Night colors)
      set -g status-style bg='#1a1b26',fg='#c0caf5'
      set -g status-left-length 30
      set -g status-left '#[fg=#7aa2f7,bold] #S '
      set -g status-right '#[fg=#565f89] %Y-%m-%d %H:%M '
      set -g window-status-format '#[fg=#565f89] #I:#W '
      set -g window-status-current-format '#[fg=#7aa2f7,bold] #I:#W '
      set -g pane-border-style fg='#414868'
      set -g pane-active-border-style fg='#7aa2f7'
      set -g message-style bg='#24283b',fg='#c0caf5'

      # No delay on escape
      set -sg escape-time 0

      # Longer status messages
      set -g display-time 2000
    '';
  };

  # ── Fish shell ────────────────────────────────────────────────────────
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # Suppress greeting
      set fish_greeting ""

      # Use vim keybindings in fish
      fish_vi_key_bindings
    '';

    shellAliases = {
      # Navigation
      ".."   = "cd ..";
      "..."  = "cd ../..";
      # eza replaces ls
      ls    = "eza --icons --group-directories-first";
      ll    = "eza -lah --icons --group-directories-first --git";
      la    = "eza -lah --icons --group-directories-first";
      lt    = "eza --tree --icons --level=2";
      lta   = "eza --tree --icons --level=2 -a";
      # zoxide: use 'z' to jump, 'zi' for interactive
      # (zoxide is initialized via programs.zoxide.enableFishIntegration)

      # Git shortcuts
      g     = "git";
      gs    = "git status";
      ga    = "git add";
      gc    = "git commit";
      gp    = "git push";
      gl    = "git log --oneline --graph --decorate";
      gd    = "git diff";

      # Modern utils
      cat   = "bat";
      diff  = "difft";    # structural diff
      du    = "dust";     # intuitive disk usage
      df    = "duf";      # readable disk free
      ps    = "procs";    # readable process list
      top   = "btm";      # bottom system monitor

      # NixOS
      nrs   = "sudo nixos-rebuild switch";
      nrsu  = "sudo nixos-rebuild switch --upgrade";
      nrb   = "sudo nixos-rebuild boot";
      # sudoedit: safely edits root files in $EDITOR without running editor as root
      ne    = "sudoedit /etc/nixos/configuration.nix";
      nhm   = "sudoedit /etc/nixos/home.nix";
    };

    functions = {
      # View the system cheatsheet in a pager
      cht = {
        description = "View the system cheatsheet";
        body = "bat --paging=always ~/cheatsheet.md";
      };
    };
  };

  # bat — better cat (used in alias above)
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      style = "numbers,changes,header";
    };
  };

  # starship prompt — works well with fish
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
}
