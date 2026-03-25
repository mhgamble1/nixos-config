{ config, ... }:

let
  cockpit = "/home/mhg/projects/cockpit";
  fn = name: {
    ".config/fish/functions/${name}.fish".source =
      config.lib.file.mkOutOfStoreSymlink "${cockpit}/functions/${name}.fish";
  };
in

{
  # Symlink fish functions from the cockpit repo.
  # mkOutOfStoreSymlink means edits to .fish files take effect immediately
  # without a nixos-rebuild — the symlink points to the live repo path.
  home.file = fn "cockpit"
    // fn "capture"
    // fn "focus"
    // fn "loop"
    // fn "qq"
    // fn "lq";

  # Run cockpit on every interactive shell start.
  programs.fish.interactiveShellInit = "cockpit";
}
