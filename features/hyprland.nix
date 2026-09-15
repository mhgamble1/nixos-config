{ ... }:

{
  flake.modules.nixos.hyprland = { pkgs, flakeModules, ... }: {
    imports = [ flakeModules.nixos.graphical-session-base ];

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.hyprland}/bin/start-hyprland";
          user = "greeter";
        };
      };
    };

    programs.dconf.enable = true;

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };

    xdg.terminal-exec.settings = {
      default = [ "com.mitchellh.ghostty.desktop" ];
    };

    security.pam.loginLimits = [
      { domain = "@audio"; item = "rtprio";  type = "-"; value = "95"; }
      { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
    ];

    services.gnome.gnome-keyring.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = true;
  };

  flake.modules.homeManager.hyprland = { config, pkgs, lib, osConfig, ... }:
    let
      startupApps = [
        {
          name = "code-term";
          workspace = "name:1:code";
          classRegex = "^(code-term)$";
          command = "${pkgs.ghostty}/bin/ghostty --class=code-term";
        }
      ];

      hypr-session-bootstrap = pkgs.writeShellScriptBin "hypr-session-bootstrap" ''
        set -eu

        has_client() {
          match_re="$1"
          ${pkgs.hyprland}/bin/hyprctl clients -j \
            | ${pkgs.jq}/bin/jq -e --arg match_re "$match_re" \
              'any(.[]; ((.class // "") | test($match_re)) or ((.initialClass // "") | test($match_re)))' \
            > /dev/null 2>&1
        }

        launch_if_missing() {
          match_re="$1"
          workspace="$2"
          command="$3"

          if has_client "$match_re"; then
            return 0
          fi

          ${pkgs.hyprland}/bin/hyprctl dispatch exec "[workspace ''${workspace} silent] ''${command}"
          sleep 0.4
        }

        ${lib.concatMapStringsSep "\n" (app:
          "launch_if_missing "
          + lib.escapeShellArg app.classRegex
          + " "
          + lib.escapeShellArg app.workspace
          + " "
          + lib.escapeShellArg app.command
        ) startupApps}

        ${pkgs.hyprland}/bin/hyprctl dispatch workspace name:1:code
      '';

      screenrec-toggle = pkgs.writeShellScriptBin "screenrec-toggle" ''
        if pgrep -x wl-screenrec > /dev/null; then
          pkill -INT wl-screenrec
          ${pkgs.libnotify}/bin/notify-send "Screen Recording" "Saved to ~/Videos" -i camera-video
        else
          mkdir -p ~/Videos
          ${pkgs.wl-screenrec}/bin/wl-screenrec -f ~/Videos/$(date +%Y-%m-%d_%H-%M-%S).mp4 &
          ${pkgs.libnotify}/bin/notify-send "Screen Recording" "Recording started" -i camera-video
        fi
      '';
    in
    {
      home.packages = with pkgs; [
        hyprshot # Native Hyprland screenshot tool
        grim # Wayland screenshot utility (backend)
        slurp # Region selection for screenshots
        wl-screenrec # Screen recorder
        libnotify # notify-send for recording notifications
        swaylock # Screen locker (hypridle calls it directly)
        pavucontrol # Audio control GUI
        networkmanagerapplet # Network tray applet
        screenrec-toggle # Toggle script for wl-screenrec
        hypr-session-bootstrap # Launch the standard session layout onto fixed workspaces
        playerctl # Media key control (play/pause/next/prev)
        brightnessctl # Backlight brightness control
      ];

      wayland.windowManager.hyprland = {
        enable = true;
        configType = "hyprlang";

        settings = {
          env = [
            "LIBVA_DRIVER_NAME,nvidia"
            "XDG_SESSION_TYPE,wayland"
            "GBM_BACKEND,nvidia-drm"
            "__GLX_VENDOR_LIBRARY_NAME,nvidia"
            "NVD_BACKEND,direct"
            "ELECTRON_OZONE_PLATFORM_HINT,wayland"
            "MOZ_ENABLE_WAYLAND,1"
            "ADW_DEBUG_COLOR_SCHEME,prefer-dark"
          ];

          monitor = if osConfig.networking.hostName == "desktop"
            then "HDMI-A-1,3440x1440@120,0x0,1"
            else "eDP-1,1920x1080@60,0x0,1.5";

          exec-once = [
            "waybar"
            "mako"
            "nm-applet --indicator"
            "blueman-applet"
            "hypr-session-bootstrap"
          ];

          input = {
            kb_layout = "us";
            follow_mouse = 1;
            touchpad = {
              natural_scroll = false;
            };
            sensitivity = 0;
          };

          general = {
            gaps_in = 5;
            gaps_out = 10;
            border_size = 2;
            "col.active_border" = "rgba(7aa2f7ee) rgba(bb9af7ee) 45deg";
            "col.inactive_border" = "rgba(414868aa)";
            layout = "dwindle";
            allow_tearing = false;
          };

          decoration = {
            rounding = 8;
            blur = {
              enabled = true;
              size = 3;
              passes = 1;
            };
            shadow = {
              enabled = true;
              range = 4;
              render_power = 3;
              color = "rgba(1a1a2eee)";
            };
          };

          animations = {
            enabled = true;
            bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
            animation = [
              "windows, 1, 4, myBezier"
              "windowsOut, 1, 4, default, popin 80%"
              "border, 1, 5, default"
              "fade, 1, 4, default"
              "workspaces, 1, 3, default"
            ];
          };

          dwindle = {
            preserve_split = true;
          };

          ecosystem = {
            no_update_news = true;
          };

          cursor = {
            no_hardware_cursors = false;
          };

          misc = {
            force_default_wallpaper = 0;
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
          };

          workspace = [
            "1, name:1:code"
            "2, name:2:web"
            "3, name:3:scratch"
            "4, name:4:music"
            "5, name:5:comms"
          ];

          "$mod" = "SUPER";

          bind = [
            "$mod, RETURN, exec, ghostty"
            "$mod, D, exec, fuzzel"
            "$mod, E, exec, ghostty --class=yazi -e yazi"
            "$mod, M, exec, ghostty --class=spotify-player -e spotify_player"

            "$mod, Q, killactive,"
            "$mod, F, fullscreen, 0"
            "$mod SHIFT, F, togglefloating,"
            "$mod, P, pseudo,"
            "$mod, S, layoutmsg, togglesplit"

            "$mod, h, movefocus, l"
            "$mod, l, movefocus, r"
            "$mod, k, movefocus, u"
            "$mod, j, movefocus, d"

            "$mod SHIFT, h, movewindow, l"
            "$mod SHIFT, l, movewindow, r"
            "$mod SHIFT, k, movewindow, u"
            "$mod SHIFT, j, movewindow, d"

            "$mod, 1, workspace, name:1:code"
            "$mod, 2, workspace, name:2:web"
            "$mod, 3, workspace, name:3:scratch"
            "$mod, 4, workspace, name:4:music"
            "$mod, 5, workspace, name:5:comms"
            "$mod, 6, workspace, 6"
            "$mod, 7, workspace, 7"
            "$mod, 8, workspace, 8"
            "$mod, 9, workspace, 9"

            "$mod SHIFT, 1, movetoworkspace, name:1:code"
            "$mod SHIFT, 2, movetoworkspace, name:2:web"
            "$mod SHIFT, 3, movetoworkspace, name:3:scratch"
            "$mod SHIFT, 4, movetoworkspace, name:4:music"
            "$mod SHIFT, 5, movetoworkspace, name:5:comms"
            "$mod SHIFT, 6, movetoworkspace, 6"
            "$mod SHIFT, 7, movetoworkspace, 7"
            "$mod SHIFT, 8, movetoworkspace, 8"
            "$mod SHIFT, 9, movetoworkspace, 9"

            "$mod, mouse_down, workspace, e+1"
            "$mod, mouse_up, workspace, e-1"

            "$mod, Tab, workspace, previous"

            "$mod SHIFT, S, exec, hyprshot -m region"
            "$mod SHIFT, W, exec, screenrec-toggle"
            "$mod SHIFT, P, exec, hyprshot -m output"

            "$mod SHIFT, L, exec, swaylock -f"

            "$mod SHIFT, B, exec, hypr-session-bootstrap"
            "$mod SHIFT, R, exec, hyprctl reload"
            "$mod SHIFT, E, exit,"

            ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ", XF86AudioPlay, exec, playerctl play-pause"
            ", XF86AudioNext, exec, playerctl next"
            ", XF86AudioPrev, exec, playerctl previous"
          ];

          binde = [
            ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
            ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
            ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
          ];

          bindm = [
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizewindow"
          ];

        };

        extraConfig = ''
          windowrule {
            name = yazi-float
            match:class = yazi
            float = yes
            size = 900 600
            center = yes
          }

          windowrule {
            name = spotify-float
            match:class = spotify-player
            float = yes
            size = 1100 700
            center = yes
          }
        '';
      };

      xdg.desktopEntries.yazi = {
        name = "Yazi";
        icon = "yazi";
        comment = "Blazing fast terminal file manager";
        exec = "/etc/profiles/per-user/mhg/bin/ghostty --class=yazi -e yazi";
        terminal = false;
        type = "Application";
        categories = [ "Utility" "FileManager" ];
        mimeType = [ "inode/directory" ];
      };

      programs.waybar = {
        enable = true;

        settings = [{
          layer = "top";
          position = "top";
          height = 32;
          spacing = 4;

          modules-left = [ "hyprland/workspaces" "hyprland/window" ];
          modules-center = [ "clock" ];
          modules-right = [ "custom/vpn" "pulseaudio" "network" "cpu" "memory" "battery" "tray" ];

          "hyprland/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
            format = "{name}";
          };

          "hyprland/window" = {
            max-length = 60;
          };

          "clock" = {
            format = "{:%a %b %d  %H:%M}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          };

          "cpu" = {
            format = "CPU {usage}%";
            interval = 2;
            tooltip = false;
          };

          "memory" = {
            format = "MEM {percentage}%";
            interval = 2;
            tooltip = false;
          };

          "network" = {
            format-wifi = "WIFI {signalStrength}%";
            format-ethernet = "ETH";
            format-disconnected = "OFFLINE";
            tooltip-format = "{ifname}: {ipaddr}/{cidr}";
          };

          "custom/vpn" = {
            exec = "tailscale exit-node list 2>/dev/null | grep -q 'selected' && echo '{\"text\":\"VPN\",\"class\":\"connected\"}' || echo '{\"text\":\"NO VPN\",\"class\":\"disconnected\"}'";
            return-type = "json";
            interval = 5;
            tooltip = false;
          };

          "pulseaudio" = {
            format = "VOL {volume}%";
            format-muted = "MUTED";
            on-click = "pavucontrol";
          };

          "battery" = {
            states = { warning = 30; critical = 15; };
            format = "BAT {capacity}%";
            format-charging = "CHG {capacity}%";
            format-full = "FULL";
          };

          "tray" = {
            spacing = 10;
          };
        }];

        style = ''
          * {
            font-family: "JetBrainsMono Nerd Font", monospace;
            font-size: 13px;
            min-height: 0;
          }

          window#waybar {
            background-color: rgba(26, 27, 38, 0.92);
            color: #c0caf5;
            border-bottom: 2px solid rgba(122, 162, 247, 0.3);
          }

          .modules-left,
          .modules-right,
          .modules-center {
            padding: 0 8px;
          }

          #workspaces button {
            padding: 2px 8px;
            background: transparent;
            color: #565f89;
            border-radius: 4px;
            margin: 4px 2px;
            border: none;
          }

          #workspaces button.active {
            background-color: rgba(122, 162, 247, 0.2);
            color: #7aa2f7;
          }

          #workspaces button:hover {
            background-color: rgba(122, 162, 247, 0.1);
            color: #c0caf5;
          }

          #window {
            color: #9aa5ce;
            padding: 0 8px;
          }

          #clock {
            color: #7aa2f7;
            font-weight: bold;
          }

          #cpu, #memory {
            color: #9ece6a;
          }

          #custom-vpn.connected {
            color: #9ece6a;
          }

          #custom-vpn.disconnected {
            color: #f7768e;
          }

          #network {
            color: #2ac3de;
          }

          #pulseaudio {
            color: #ff9e64;
          }

          #pulseaudio.muted {
            color: #565f89;
          }

          #battery {
            color: #9ece6a;
          }

          #battery.warning {
            color: #ff9e64;
          }

          #battery.critical {
            color: #f7768e;
          }

          #tray {
            padding: 0 4px;
          }

          #tray > .passive {
            -gtk-icon-effect: dim;
          }
        '';
      };

      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            terminal = "/etc/profiles/per-user/mhg/bin/ghostty -e";
            width = 40;
            lines = 15;
            font = "JetBrainsMono Nerd Font:size=13";
            prompt = "'Search... '";
            icon-theme = "hicolor";
            icons-enabled = true;
          };
          colors = {
            background = "1a1b26f2";
            text = "c0caf5ff";
            match = "7aa2f7ff";
            selection = "283457ff";
            selection-text = "c0caf5ff";
            selection-match = "7dcfffff";
            border = "7aa2f766";
          };
          border = {
            width = 2;
            radius = 8;
          };
        };
      };

      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof swaylock || swaylock -f";
            before_sleep_cmd = "swaylock -f";
            after_sleep_cmd = "hyprctl dispatch dpms on";
          };
          listener = [
            {
              timeout = 1500;
              on-timeout = "swaylock -f";
            }
            {
              timeout = 1800;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
            {
              timeout = 5400;
              on-timeout = "systemctl suspend";
            }
          ];
        };
      };

      services.mako = {
        enable = true;
        settings = {
          background-color = "#1a1b26ee";
          text-color = "#c0caf5";
          border-color = "#7aa2f7";
          border-radius = 8;
          border-size = 2;
          default-timeout = 5000;
          max-visible = 5;
          width = 360;
          height = 100;
          margin = "10";
          padding = "12";
          font = "JetBrainsMono Nerd Font 12";
        };
        extraConfig = ''
          [urgency=high]
          border-color=#f7768e
          default-timeout=0

          [app-name=Spotify]
          invisible=1

          [app-name=spotify_player]
          invisible=1
        '';
      };
    };
}
