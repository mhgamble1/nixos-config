{ pkgs, ... }:

# Home-manager KDE Plasma config — plasma-manager, scoped to closing the same
# three macOS-muscle-memory gaps the GNOME setup targeted (kde-home.nix
# replaces gnome-home.nix): keyboard-driven quarter-tiling (native KWin,
# nothing to configure), an all-windows overview bound to a bare Meta press,
# and moving the focused window to an adjacent workspace via keyboard.
# Used by: t14 (imported conditionally in home/mhg/default.nix by hostName).
# Pair with modules/nixos/kde.nix for the session.
{
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
  };

  # ── Powerdevil vs. logind idle-suspend authority ───────────────────────
  # ACTION NEEDED AFTER FIRST LOGIN — do not skip: hosts/t14/power-
  # management.nix gives logind sole authority over idle-triggered suspend
  # (IdleAction = suspend-then-hibernate) specifically so the machine never
  # sits in plain, no-hibernate-fallback s2idle suspend — that's what
  # caused the 2026-08-25 hang documented there. Powerdevil has its own
  # competing "suspend session when idle" setting (System Settings ->
  # Power Management -> Energy Saving, both AC and Battery profiles) that
  # must be turned OFF, exactly like GNOME's equivalent was disabled for
  # the same reason. Also set Powerdevil's power-button action to "Sleep"
  # to match logind's HandlePowerKey (see the comment there). Not encoded
  # declaratively here: the powerdevilrc key names/enum values weren't
  # confirmed against a live session, and a wrong guess here would fail
  # silently — worse than leaving this as a manual step for a safety-net
  # setting. Revisit once verified.

  # ── Touchpad ─────────────────────────────────────────────────────────
  # ACTION NEEDED AFTER FIRST LOGIN: confirm whether KDE's libinput KCM
  # shadows the NixOS-level services.libinput settings in hosts/t14/
  # default.nix the same way GNOME's did (that's why gnome-home.nix carried
  # its own dconf touchpad override). If so, set natural-scroll off /
  # tap-to-click on via System Settings -> Touchpad, or add the override
  # here through programs.plasma.configFile."touchpadxlibinputrc" once the
  # real per-device group name is known (it's keyed by device name, e.g.
  # "SynPS/2 Synaptics TouchPad" — not guessed here for the same
  # don't-encode-unverified-config reason as the Powerdevil note above).
}
