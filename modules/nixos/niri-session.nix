{ pkgs, ... }:

# System-level niri session — adds niri as a second login-screen choice
# alongside KDE Plasma (modules/nixos/kde.nix owns the SDDM + audio/printing/
# Firefox baseline; SDDM is already running in Wayland mode there, so it
# picks up niri's session entry automatically, no greetd needed).
# Used by: t14. Pair with modules/home/niri.nix for the home-manager side.
#
# `niri.nixosModules.niri` (added to t14's module list in flake.nix) is what
# actually provides this `programs.niri` option — enabling it here installs
# niri, the niri.desktop session file SDDM lists, and the supporting bits
# (polkit agent, xdg-desktop-portal-gnome for screencasting, dconf, PAM entry
# for swaylock) documented in niri-flake's docs.md.
{
  programs.niri.enable = true;

  # niri-flake's own niri-stable build currently fails against this
  # nixpkgs snapshot (references the removed `libdisplay-info_0_2`
  # attribute — confirmed live while building this config). Falling back
  # to nixpkgs's own `niri` package sidesteps that; it updates slower than
  # niri-flake's pin, but builds cleanly. Revisit dropping this override
  # once niri-flake's lockfile catches back up.
  programs.niri.package = pkgs.niri;
}
