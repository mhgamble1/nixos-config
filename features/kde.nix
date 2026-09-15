{ ... }:

{
  flake.modules.nixos.kde = { pkgs, flakeModules, ... }: {
    imports = [ flakeModules.nixos.graphical-session-base ];

    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;

    services.desktopManager.plasma6.enable = true;

    services.power-profiles-daemon.enable = false;

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
      khelpcenter
    ];
  };

  flake.modules.homeManager.kde = { pkgs, config, ... }: {
    gtk.gtk2.force = true;

    programs.plasma = {
      enable = true;

      kwin = {
        virtualDesktops = {
          number = 4;
          rows = 1;
        };
      };

      shortcuts = {
        kwin = {
          "Overview" = "Meta";

          "Window One Desktop to the Left" = "Shift+Meta+Left";
          "Window One Desktop to the Right" = "Shift+Meta+Right";
        };
      };

      input.touchpads = [
        {
          name = "SynPS/2 Synaptics TouchPad";
          vendorId = "0002";
          productId = "0007";
          naturalScroll = false;
          tapToClick = true;
        }
      ];

      input.keyboard.numlockOnStartup = "on";

      configFile.baloofilerc.General."exclude folders" =
        "${config.home.homeDirectory}/.cache/,${config.home.homeDirectory}/go/";

      powerdevil = {
        AC = {
          autoSuspend.action = "nothing";
          whenLaptopLidClosed = "sleep";
          powerButtonAction = "sleep";
          whenSleepingEnter = "standbyThenHibernate";

          dimDisplay.idleTimeout = 900;
          turnOffDisplay.idleTimeout = 1200;
        };
        battery = {
          autoSuspend.action = "nothing";
          whenLaptopLidClosed = "sleep";
          powerButtonAction = "sleep";
          whenSleepingEnter = "standbyThenHibernate";

          dimDisplay.idleTimeout = 900;
          turnOffDisplay.idleTimeout = 1200;
        };
      };

      configFile.plasmanotifyrc."DoNotDisturb".Until = "2099,1,1,0,0,0.000";

      kscreenlocker = {
        autoLock = true;
        timeout = 20;
        passwordRequired = false;
      };
    };
  };
}
