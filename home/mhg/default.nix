{ config, lib, secrets, osConfig, flakeModules, ... }:

{
  imports = lib.optional (osConfig.networking.hostName == "t14") flakeModules.homeManager.niri;

  home.username = "mhg";
  home.homeDirectory = "/home/mhg";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519";
      };
      "piserver" = {
        User = "pi";
        IdentityFile = "~/.ssh/id_ed25519";
      };
      "mam-vps" = {
        User = "mhg";
        IdentityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user.name = "Mark Gamble";
      user.email = "mhgamble1@gmail.com";
      init.defaultBranch = "main";
      gpg.format = "ssh";
      commit.gpgsign = false;
      pull.rebase = false;
      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };

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

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    shellWrapperName = "yy";
  };

  xdg.enable = true;

  home.sessionVariables = {
    EDITOR = "zeditor --wait";
    VISUAL = "zeditor --wait";
    TERMINAL = "ghostty";
    BROWSER = "firefox";
    NIXOS_OZONE_WL = "1";
    ADW_DEBUG_COLOR_SCHEME = "prefer-dark";
  };
}
