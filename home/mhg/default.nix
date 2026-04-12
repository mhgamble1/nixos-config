{ config, pkgs, lib, secrets, ... }:

{
  imports = [
    ../../modules/hyprland.nix
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
    matchBlocks."github.com" = {
      user = "git";
      identityFile = "~/.ssh/id_ed25519";
    };
    # Hermes VPS — AI agent / remote workspace
    matchBlocks."hermes" = {
      hostname = secrets.hermes.hostname;
      user = secrets.hermes.user;
      identityFile = "~/.ssh/id_ed25519";
      serverAliveInterval = 60;
      serverAliveCountMax = 10;
    };
    # exe.dev VMs — direct SSH with keepalives and connection multiplexing
    matchBlocks."*.exe.xyz" = {
      user = "exedev";
      identityFile = "~/.ssh/id_ed25519";
      serverAliveInterval = 30;
      serverAliveCountMax = 6;
      extraOptions = {
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

  # ── Session variables ─────────────────────────────────────────────────
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
    TERMINAL = "ghostty";
    NIXOS_OZONE_WL = "1";
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

    circumflex

    cheese
  ];
}
