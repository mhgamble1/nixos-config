{ config, pkgs, lib, secrets, osConfig, ... }:

{
  imports = [
    ../../modules/music.nix
    ../../modules/terminal.nix
    ../../modules/dev.nix
    ../../modules/agents.nix
    ../../modules/theming.nix
  ] ++ lib.optional (osConfig.networking.hostName == "desktop") ../../modules/hyprland.nix
    ++ lib.optional (osConfig.networking.hostName == "t14") ../../modules/gnome-home.nix;

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
      # home Pi, reachable over Tailscale
      "piserver" = {
        User = "pi";
        IdentityFile = "~/.ssh/id_ed25519";
      };
      # dev VPS, reachable over Tailscale
      "mam-vps" = {
        User = "mhg";
        IdentityFile = "~/.ssh/id_ed25519";
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
      url."git@github.com:".insteadOf = "https://github.com/";
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
    BROWSER = "firefox";
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

    google-chrome # Claude-in-Chrome requires real Chrome; Firefox stays default browser

    calibre

    newsboat

    tealdeer

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
    zathura
    # Downloads
    aria2
    yt-dlp
    openbooks
    nicotine-plus

    circumflex

    # Media processing
    ffmpeg
  ];
}
