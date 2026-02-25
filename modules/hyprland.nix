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
    swaylock     # Screen locker (hypridle calls it directly)
    pavucontrol  # Audio control GUI
    networkmanagerapplet  # Network tray applet
    screenrec-toggle  # Toggle script for wl-screenrec
    playerctl    # Media key control (play/pause/next/prev)
    brightnessctl # Backlight brightness control
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
        # hypridle is started automatically as a systemd user service (see services.hypridle below)
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

      # ── Named workspaces ──────────────────────────────────────────────
      workspace = [
        "1, name:code"
        "2, name:web"
        "3, name:comms"
        "4, name:music"
        "5, name:scratch"
      ];

      # ── Keybinds ──────────────────────────────────────────────────────
      "$mod" = "SUPER";

      bind = [
        # Applications
        "$mod, RETURN, exec, ghostty"
        "$mod, D, exec, fuzzel"
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

        # Cycle recent workspaces
        "$mod, Tab, workspace, previous"

        # Screenshots (hyprshot) + screen recording (wl-screenrec)
        "$mod SHIFT, S, exec, hyprshot -m region"
        "$mod SHIFT, W, exec, screenrec-toggle"   # toggle recording (saves to ~/Videos)
        "$mod SHIFT, P, exec, hyprshot -m output"

        # Screen lock
        "$mod SHIFT, L, exec, swaylock -f"

        # Reload / exit
        "$mod SHIFT, R, exec, hyprctl reload"
        "$mod SHIFT, E, exit,"

        # Media controls
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      # Repeatable binds (held key repeats action — good for volume/brightness)
      binde = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
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

  # ── Desktop entries (override system defaults) ────────────────────────
  # Yazi: launch via ghostty directly with --class=yazi so the window rule applies.
  # Terminal=false so fuzzel doesn't wrap it in a second terminal layer.
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
        exec = "mullvad status 2>/dev/null | grep -q 'Connected' && echo '{\"text\":\"VPN\",\"class\":\"connected\"}' || echo '{\"text\":\"NO VPN\",\"class\":\"disconnected\"}'";
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

  # ── Fuzzel launcher ───────────────────────────────────────────────────
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

  # ── Hypridle (replaces swayidle — uses Hyprland's native idle protocol) ──
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd         = "pidof swaylock || swaylock -f"; # don't double-lock
        before_sleep_cmd = "swaylock -f";                  # lock before suspend
        after_sleep_cmd  = "hyprctl dispatch dpms on";     # display on after resume
      };
      listener = [
        {
          timeout   = 1500;   # 25 min: lock screen
          on-timeout = "swaylock -f";
        }
        {
          timeout   = 1800;   # 30 min: display off
          on-timeout = "hyprctl dispatch dpms off";
          on-resume  = "hyprctl dispatch dpms on";   # reliably re-enabled by Hyprland IPC
        }
        {
          timeout   = 5400;   # 90 min: suspend
          on-timeout = "systemctl suspend";
        }
      ];
    };
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
    };
    # Criteria sections must go in extraConfig — not settings — to render as [section] headers
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
}
