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

  # MacTahoe theme (github.com/vinceliuice/MacTahoe-kde), packaged locally
  # since it's not in nixpkgs — see pkgs/mactahoe-kde-theme and
  # pkgs/mactahoe-icon-theme (built the same way nixpkgs packages the
  # sibling whitesur-kde/whitesur-icon-theme). Ships as $out/share/...
  # (color-schemes, plasma/{desktoptheme,look-and-feel}, Kvantum, aurorae,
  # icons), so having it in home.packages is enough for KDE to find it on
  # XDG_DATA_DIRS — nothing gets written outside the Nix store.
  home.packages = [
    (pkgs.callPackage ../../pkgs/mactahoe-kde-theme { })
    (pkgs.callPackage ../../pkgs/mactahoe-icon-theme { })
    pkgs.kdePackages.qtstyleplugin-kvantum
  ];

  programs.plasma = {
    enable = true;

    # Applying the look-and-feel package (rather than setting colorScheme,
    # iconTheme, and cursor separately, which replaces the previous
    # colorScheme = "BreezeDark") cascades all of it in one go, per its
    # contents/defaults: ColorScheme=MacTahoeDark, Icons.Theme=MacTahoe-
    # dark, cursorTheme=MacTahoe-dark, the aurorae window decoration, and
    # KDE.widgetStyle=kvantum-dark. plasma-manager's own docs warn against
    # setting lookAndFeel alongside colorScheme/windowDecorations for
    # exactly this reason — the look-and-feel theme overrides them anyway.
    workspace.lookAndFeel = "com.github.vinceliuice.MacTahoe-Dark";

    # widgetStyle=kvantum-dark (set above by the look-and-feel package)
    # only selects the *engine* — Kvantum still needs to be told which of
    # its own themes to render. That's a separate config file the
    # look-and-feel package doesn't touch, so it's set explicitly here.
    configFile."Kvantum/kvantum.kvconfig"."General".theme = "MacTahoeDark";

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
            # An explicit panel `widgets` list fully replaces Plasma's default
            # panel layout — the System Tray isn't implicit, it's just another
            # widget. Without it there's nowhere for popups (including the
            # Notifications applet) to live: confirmed live on t14, KDE's own
            # Settings > Notifications page reported "Could not find a
            # 'Notifications' widget" and a mouse-disconnect notification got
            # stuck on screen with no way to dismiss it.
            systemTray = { };
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

        # Default KDE display timeouts are tuned for a shared/office
        # laptop (dim/blank within a couple minutes) — annoying for a
        # machine that's almost always home and unattended-but-nearby.
        # Push these out so the screen stays lit through short pauses.
        dimDisplay.idleTimeout = 900; # 15 min
        turnOffDisplay.idleTimeout = 1200; # 20 min
      };
      battery = {
        autoSuspend.action = "nothing";
        whenLaptopLidClosed = "doNothing";
        powerButtonAction = "sleep";
        whenSleepingEnter = "standbyThenHibernate";

        dimDisplay.idleTimeout = 900;
        turnOffDisplay.idleTimeout = 1200;
      };
    };

    # ── Notifications ────────────────────────────────────────────────────
    # No single "disable all notifications" switch exists in Plasma's
    # config — ShowPopups is a per-application default (true) rather than
    # a global one. The mechanism Plasma's own "Do Not Disturb" toggle uses
    # for "until manually turned back on" is just setting this timestamp
    # far in the future (confirmed from plasma-workspace's
    # applets/notifications/FullRepresentation.qml, which literally does
    # `date + 1 year` rather than track a separate "permanent" flag) — so
    # this reproduces that "permanently on" DND state declaratively.
    # Critical notifications, screen-sharing/mirroring alerts still get
    # through by default (Plasma's own DND carve-outs); toggle it off
    # early (moon icon in the system tray) if you want popups back
    # sooner than 2099.
    #
    # NOTE on format: this is NOT ISO 8601. KConfig serializes QDateTime as
    # "Year,Month,Day,Hour,Minute,Second.Millisecond" — confirmed live by
    # manually toggling DND via the tray icon and diffing the resulting
    # file (it wrote "2027,8,28,9,2,41.514"). An ISO-formatted string here
    # silently fails to parse as a valid QDateTime, so the DND state never
    # actually activates despite looking like a normal config value.
    configFile.plasmanotifyrc."DoNotDisturb".Until = "2099,1,1,0,0,0.000";

    # ── Screen lock ──────────────────────────────────────────────────────
    # Same "mostly home, not a shared machine" reasoning as the powerdevil
    # display timeouts above. First attempt was a grace-period delay before
    # requiring a password after locking — but any real interruption (not
    # just a few seconds away) blows past a several-minute grace window
    # anyway, so it never stopped feeling like a full re-login. Settled on
    # the actually-sane version for a home-only machine instead: still
    # blank/lock the screen on schedule (so it's not left lit and visible),
    # but drop the password requirement entirely — moving the mouse or a
    # keypress unlocks it instantly. This means zero access-control barrier
    # once someone has physical access to the machine; that's the accepted
    # trade-off here specifically because the machine is home-only.
    kscreenlocker = {
      autoLock = true;
      timeout = 20; # minutes idle before lock
      passwordRequired = false; # unlock is instant — no password ever
    };
  };
}
