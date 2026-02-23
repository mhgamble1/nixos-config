{ config, pkgs, lib, ... }:

let
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
  # Screenshot tools and Wayland utilities
  home.packages = with pkgs; [
    hyprshot     # Native Hyprland screenshot tool
    grim         # Wayland screenshot utility (backend)
    slurp        # Region selection for screenshots
    wl-screenrec # Screen recorder
    libnotify    # notify-send for recording notifications
    swaylock     # Screen locker
    swayidle     # Idle management
    pavucontrol  # Audio control GUI
    networkmanagerapplet  # Network tray applet
    screenrec-toggle  # Toggle script for wl-screenrec
  ];

  # Hyprland compositor configuration
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      # ── NVIDIA environment variables ──────────────────────────────────
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "XDG_SESSION_TYPE,wayland"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "NVD_BACKEND,direct"
        "ELECTRON_OZONE_PLATFORM_HINT,wayland"
        "MOZ_ENABLE_WAYLAND,1"
      ];

      # ── Monitor ───────────────────────────────────────────────────────
      # Auto-detect all monitors. Override with explicit config if needed:
      # monitor = "DP-1,2560x1440@144,0x0,1";
      monitor = ",preferred,auto,1";

      # ── Autostart ─────────────────────────────────────────────────────
      exec-once = [
        "waybar"
        "mako"
        "nm-applet --indicator"
        "swayidle -w timeout 1800 'hyprctl dispatch dpms off' timeout 5400 'systemctl suspend' resume 'hyprctl dispatch dpms on'"
      ];

      # ── Input ─────────────────────────────────────────────────────────
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = false;
        };
        sensitivity = 0;
      };

      # ── General ───────────────────────────────────────────────────────
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(7aa2f7ee) rgba(bb9af7ee) 45deg";
        "col.inactive_border" = "rgba(414868aa)";
        layout = "dwindle";
        allow_tearing = false;
      };

      # ── Appearance ────────────────────────────────────────────────────
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
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # ── Cursor (required for NVIDIA) ──────────────────────────────────
      cursor = {
        no_hardware_cursors = true;
      };

      # ── Misc ──────────────────────────────────────────────────────────
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;  # suppress version notification on launch
      };

      # ── Keybinds ──────────────────────────────────────────────────────
      "$mod" = "SUPER";

      bind = [
        # Applications
        "$mod, RETURN, exec, ghostty"
        "$mod, D, exec, wofi --show drun"
        "$mod SHIFT, D, exec, wofi --show run"
        "$mod, E, exec, ghostty --class=yazi -e yazi"
        "$mod, slash, exec, ghostty --class=cheatsheet -e bat --paging=always ~/cheatsheet.md"
        "$mod, M, exec, ghostty --class=spotify-player -e spotify_player"

        # Window management
        "$mod, Q, killactive,"
        "$mod, F, fullscreen, 0"
        "$mod SHIFT, F, togglefloating,"
        "$mod, P, pseudo,"       # dwindle pseudotile
        "$mod, S, togglesplit,"  # dwindle split direction

        # Focus — vim keys
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"

        # Move windows — vim keys
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, l, movewindow, r"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, j, movewindow, d"

        # Workspaces 1–9
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        # Move window to workspace 1–9
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"

        # Scroll through workspaces
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # Screenshots (hyprshot) + screen recording (wl-screenrec)
        "$mod SHIFT, S, exec, hyprshot -m region"
        "$mod SHIFT, W, exec, screenrec-toggle"   # toggle recording (saves to ~/Videos)
        "$mod SHIFT, P, exec, hyprshot -m output"

        # Screen lock
        "$mod SHIFT, L, exec, swaylock -f"

        # Reload / exit
        "$mod SHIFT, R, exec, hyprctl reload"
        "$mod SHIFT, E, exit,"
      ];

      # Mouse binds for window resize/move
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # ── Window rules ──────────────────────────────────────────────────
      windowrulev2 = [
        # Cheatsheet — floating, centered, fixed size
        "float, class:(cheatsheet)"
        "size 920 700, class:(cheatsheet)"
        "center, class:(cheatsheet)"
        "stayfocused, class:(cheatsheet)"

        # Yazi file manager — floating when opened via SUPER+E
        "float, class:(yazi)"
        "size 900 600, class:(yazi)"
        "center, class:(yazi)"

        # Spotify TUI — floating when opened via SUPER+M
        "float, class:(spotify-player)"
        "size 1100 700, class:(spotify-player)"
        "center, class:(spotify-player)"
      ];
    };
  };

  # ── Waybar ────────────────────────────────────────────────────────────
  programs.waybar = {
    enable = true;

    settings = [{
      layer = "top";
      position = "top";
      height = 32;
      spacing = 4;

      modules-left = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right = [ "pulseaudio" "network" "cpu" "memory" "battery" "tray" ];

      "hyprland/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
        format = "{id}";
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

  # ── Wofi launcher ─────────────────────────────────────────────────────
  programs.wofi = {
    enable = true;
    settings = {
      width = 600;
      height = 400;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 24;
      gtk_dark = true;
    };
    style = ''
      window {
        background-color: rgba(26, 27, 38, 0.95);
        border: 2px solid rgba(122, 162, 247, 0.3);
        border-radius: 12px;
        font-family: "JetBrainsMono Nerd Font";
        font-size: 14px;
      }

      #input {
        background-color: rgba(36, 40, 59, 0.8);
        color: #c0caf5;
        border: 1px solid rgba(122, 162, 247, 0.2);
        border-radius: 8px;
        padding: 8px 12px;
        margin: 8px;
      }

      #inner-box {
        background-color: transparent;
      }

      #outer-box {
        padding: 8px;
      }

      #entry {
        padding: 6px 12px;
        border-radius: 6px;
        color: #c0caf5;
      }

      #entry:selected {
        background-color: rgba(122, 162, 247, 0.2);
        color: #7aa2f7;
      }

      #text {
        color: #c0caf5;
      }

      #text:selected {
        color: #7aa2f7;
      }
    '';
  };

  # ── Mako notifications ────────────────────────────────────────────────
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
      "[urgency=high]" = {
        border-color = "#f7768e";
        default-timeout = 0;
      };
    };
  };
}
