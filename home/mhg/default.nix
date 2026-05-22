{ config, pkgs, lib, secrets, ... }:

{
  imports = [
    ../../modules/hyprland.nix
    ../../modules/music.nix
    ../../modules/terminal.nix
    ../../modules/dev.nix
    ../../modules/agents.nix
    ../../modules/theming.nix
  ];

  home.username = "mhg";
  home.homeDirectory = "/home/mhg";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # ── SSH ───────────────────────────────────────────────────────────────
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519";
      };
      # Hermes VPS — AI agent / remote workspace
      "hermes" = {
        Hostname = secrets.hermes.hostname;
        User = secrets.hermes.user;
        IdentityFile = "~/.ssh/id_ed25519";
        ServerAliveInterval = 60;
        ServerAliveCountMax = 10;
      };
      # exe.dev gateway
      "exe.dev" = {
        User = "mhg";
        IdentityFile = "~/.ssh/id_ed25519";
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
      };
      # exe.dev VMs — direct SSH with keepalives and connection multiplexing
      "*.exe.xyz" = {
        User = "exedev";
        IdentityFile = "~/.ssh/id_ed25519";
        ServerAliveInterval = 30;
        ServerAliveCountMax = 6;
        ControlMaster = "auto";
        ControlPath = "~/.ssh/cm-%r@%h:%p";
        ControlPersist = "10m";
      };
    };
  };

  # ── Git ───────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user.name = "Mark Gamble";
      user.email = "mhgamble1@gmail.com";
      init.defaultBranch = "main";
      gpg.format = "ssh";
      commit.gpgsign = false; # enable once SSH signing key is set
      pull.rebase = false;
    };
  };

  # Git — delta pager for beautiful diffs
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "TwoDark";
    };
  };

  # ── Yazi — TUI file manager ───────────────────────────────────────────
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    shellWrapperName = "yy";
  };

  # ── XDG ───────────────────────────────────────────────────────────────
  xdg.enable = true;

  # ── GTK / GNOME — dark mode for libadwaita apps (e.g. high-tide) ─────
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # ── Session variables ─────────────────────────────────────────────────
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
    TERMINAL = "ghostty";
    NIXOS_OZONE_WL = "1";
    ADW_DEBUG_COLOR_SCHEME = "prefer-dark";
  };

  # ── Packages ──────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Clipboard
    wl-clipboard

    # System utilities
    ripgrep
    fd
    jq
    htop
    unzip

    google-chrome

    calibre

    w3m
    browsh

    newsboat

    tealdeer

    # Wayland utilities
    wlr-randr

    # Spotify TUI client
    spotify-player

    # Discord
    discord

    # Note-taking
    zk
    obsidian

    # Terminal launcher helper — GIO checks for this before its hardcoded xterm fallback
    xdg-terminal-exec

    zola
    wrangler

    # Media / docs
    vlc
    spotify
    zathura
    gnome-text-editor

    # Downloads
    aria2
    yt-dlp
    openbooks
    nicotine-plus

    circumflex

    cheese

    # Media processing
    ffmpeg

    # TIDAL music player
    high-tide

    # Wayland key event viewer
    wev
  ];
}
