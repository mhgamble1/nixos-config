{ pkgs, config, ... }:

# Home-manager KDE Plasma config — plasma-manager, scoped to closing the same
# three macOS-muscle-memory gaps the GNOME setup targeted (kde-home.nix
# replaces gnome-home.nix): keyboard-driven quarter-tiling (native KWin,
# nothing to configure), an all-windows overview bound to a bare Meta press,
# and moving the focused window to an adjacent workspace via keyboard.
# Used by: t14 (imported conditionally in home/mhg/default.nix by hostName).
# Pair with modules/nixos/kde.nix for the session.
{
  # KDE's own GTK-theme sync (kde-gtk-config, triggered by applying a color
  # scheme in System Settings / plasma-apply-colorscheme) rewrites
  # ~/.gtkrc-2.0 as a plain file, clobbering the symlink modules/home/
  # theming.nix's gtk.enable manages it with — confirmed live on t14: it
  # got overwritten the moment the BreezeDark scheme was applied, breaking
  # the next activation. gtk.gtk2.force means activation always wins back,
  # even though KDE may re-clobber it again live in between switches.
  gtk.gtk2.force = true;

  programs.plasma = {
    enable = true;

    workspace.colorScheme = "BreezeDark";

    # Fixed workspace count, single row — a horizontal strip like macOS
    # Spaces, not GNOME's default vertical stack. Matches the fixed
    # num-workspaces=4 the GNOME config used.
    kwin = {
      virtualDesktops = {
        number = 4;
        rows = 1;
      };
    };

    # Titlebar buttons: Breeze ships minimize/maximize/close by default, so
    # unlike the GNOME config there's no button-layout override needed here.

    shortcuts = {
      kwin = {
        # Bare-Meta modifier-only shortcut for the Overview effect — KWin's
        # Mission-Control/Activities equivalent. Meta defaults to opening
        # the Kickoff app launcher instead; this reassigns it.
        # NOTE: kglobalshortcutsrc entries aren't validated at build time —
        # confirm this took effect after first login (System Settings ->
        # Shortcuts -> search "Overview") and adjust if KDE didn't accept
        # the modifier-only binding.
        "Overview" = "Meta";

        # Move the focused window to the adjacent workspace, mirroring
        # GNOME's Shift+Super+Left/Right (this repo's GNOME config used
        # Up/Down since GNOME defaults to a vertical stack; KWin here is
        # configured as a single horizontal row, so Left/Right is the
        # equivalent direction).
        "Window One Desktop to the Left" = "Shift+Meta+Left";
        "Window One Desktop to the Right" = "Shift+Meta+Right";
      };
    };

    # Quarter-tiling is native KWin behavior (Meta+Arrow, chained while
    # held, e.g. Meta+Up then Meta+Right for the top-right quarter) —
    # nothing to configure to get it.

    # ── Touchpad ───────────────────────────────────────────────────────
    # Plasma's libinput KCM shadows the NixOS-level services.libinput
    # settings in hosts/t14/default.nix the same way GNOME's did — verified
    # live: ~/.config/touchpadxlibinputrc starts out absent/empty, so this
    # device was running on KDE's own compiled-in defaults, not the NixOS
    # ones, until set explicitly here. Name/vendorId/productId confirmed
    # via /proc/bus/input/devices on t14 (I: Bus=0011 Vendor=0002
    # Product=0007, N: Name="SynPS/2 Synaptics TouchPad").
    input.touchpads = [
      {
        name = "SynPS/2 Synaptics TouchPad";
        vendorId = "0002";
        productId = "0007";
        naturalScroll = false;
        tapToClick = true;
      }
    ];

    panels = [
      {
        location = "bottom";
        hiding = "autohide";
        widgets = [
          {
            iconTasks = { };
          }
          {
            systemMonitor = {
              title = "System Monitor";
              totalSensors = [
                "cpu/all/usage"
                "memory/physical/usedPercent"
                "battery/battery0/percent"
                "network/all/download"
                "network/all/upload"
              ];
            };
          }
        ];
      }
    ];

    # ── Keyboard ─────────────────────────────────────────────────────────
    input.keyboard.numlockOnStartup = "on";

    # ── Baloo indexing ───────────────────────────────────────────────────
    # Default is to index the whole home directory with no exclusions —
    # checked live, ~/.config/baloofilerc starts out with none set. On a
    # dev machine that means churning through build/module caches with no
    # search value: ~/.cache alone is 3.2G, ~/go (Go module/build cache)
    # another ~1G, both rewritten constantly. Exclude them from indexing;
    # the rest of home stays indexed.
    configFile.baloofilerc.General."exclude folders" =
      "${config.home.homeDirectory}/.cache/,${config.home.homeDirectory}/go/";

    # ── Powerdevil vs. logind sleep authority ───────────────────────────
    # hosts/t14/power-management.nix gives logind sole authority over
    # idle-triggered suspend (IdleAction = suspend-then-hibernate)
    # specifically so the machine never sits in plain, no-hibernate-
    # fallback s2idle suspend — that's what caused the 2026-08-25 hang
    # documented there. Powerdevil has its own competing idle-suspend,
    # lid-close, and power-button actions (previously GNOME's
    # settings-daemon equivalents, disabled there for the same reason) —
    # all three set below, for both AC and battery profiles, to defer to
    # logind rather than race it. whenSleepingEnter is set to
    # "standbyThenHibernate" so that on the rare path where Powerdevil's
    # own sleep action *does* fire (e.g. a manual System Settings action),
    # it goes through the same suspend-then-hibernate behavior instead of
    # plain s2idle.
    powerdevil = {
      AC = {
        autoSuspend.action = "nothing";
        whenLaptopLidClosed = "doNothing";
        powerButtonAction = "sleep";
        whenSleepingEnter = "standbyThenHibernate";
      };
      battery = {
        autoSuspend.action = "nothing";
        whenLaptopLidClosed = "doNothing";
        powerButtonAction = "sleep";
        whenSleepingEnter = "standbyThenHibernate";
      };
    };
  };
}
