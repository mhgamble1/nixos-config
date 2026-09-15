{ ... }:

# System-level KDE Plasma 6 session — SDDM + services.desktopManager.plasma6.
# Used by: t14. Replaces modules/nixos/gnome.nix (kept dormant, not deleted,
# in case this doesn't stick — see hosts/t14/default.nix).

{
  flake.modules.nixos.kde = { pkgs, flakeModules, ... }: {
    imports = [ flakeModules.nixos.graphical-session-base ];

    # ── Display manager — SDDM ─────────────────────────────────────────────
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;

    # ── KDE Plasma desktop ──────────────────────────────────────────────────
    services.desktopManager.plasma6.enable = true;

    # Plasma enables power-profiles-daemon by default; disable it so TLP
    # (configured in the laptop host) can manage power without conflict.
    # Same reasoning as the GNOME config it replaces.
    services.power-profiles-daemon.enable = false;

    # Remove apps we don't use (have better alternatives installed) —
    # mirrors modules/nixos/gnome.nix's environment.gnome.excludePackages.
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      elisa # music player (using spotify_player)
      khelpcenter
    ];
  };

  flake.modules.homeManager.kde = { pkgs, config, ... }: {
    # Home-manager KDE Plasma config — plasma-manager, scoped to closing the
    # same three macOS-muscle-memory gaps the GNOME setup targeted:
    # keyboard-driven quarter-tiling (native KWin, nothing to configure), an
    # all-windows overview bound to a bare Meta press, and moving the
    # focused window to an adjacent workspace via keyboard.

    # KDE's own GTK-theme sync (kde-gtk-config, triggered by applying a color
    # scheme in System Settings / plasma-apply-colorscheme) rewrites
    # ~/.gtkrc-2.0 as a plain file, clobbering the symlink features/
    # theming.nix's gtk.enable manages it with — confirmed live on t14: it
    # got overwritten the moment the BreezeDark scheme was applied, breaking
    # the next activation. gtk.gtk2.force means activation always wins back,
    # even though KDE may re-clobber it again live in between switches.
    gtk.gtk2.force = true;

    programs.plasma = {
      enable = true;

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
        # whenLaptopLidClosed is "sleep", not "doNothing": Powerdevil always
        # holds a systemd-logind `block`-type inhibitor on handle-lid-switch
        # (confirmed live via `systemd-inhibit --list`), which suppresses
        # logind's own HandleLidSwitch action entirely rather than just
        # racing it — so "doNothing" here previously meant lid-close did
        # *nothing at all*, not "defer to logind". Verified by an 11h21m
        # gap in the journal (2026-09-01 21:12 lid-close to 2026-09-02
        # 08:33 lid-open) with zero suspend/resume log entries — the
        # machine sat fully awake all night and drained the battery. Since
        # Powerdevil is unavoidably the real lid-switch owner, it has to be
        # the one that suspends; whenSleepingEnter = standbyThenHibernate
        # routes that through the same suspend-then-hibernate behavior
        # logind would have used.
        AC = {
          autoSuspend.action = "nothing";
          whenLaptopLidClosed = "sleep";
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
          whenLaptopLidClosed = "sleep";
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
  };
}
