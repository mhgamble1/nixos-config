{ pkgs, ... }:

{
  # ── Flatpak ───────────────────────────────────────────────────────────
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # ── Logitech Unifying — installs udev rules for hidraw access and Solaar ─
  hardware.logitech.wireless.enable = true;
  programs.solaar.enable = true;

  # ── Bluetooth ─────────────────────────────────────────────────────────
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # BlueZ main.conf — tuned for BLE HID reliability (Glove80).
  #
  # FastConnectable: speeds up link re-establishment so GATT reads happen after
  #   the LE link is stable, reducing "Attribute can't be read" errors on reconnect.
  #
  # JustWorksRepairing: auto-handles bonding without user prompts on reconnect,
  #   preventing the cascade where BlueZ drops the link because it can't re-bond.
  #
  # LE connection parameters deliberately omitted. Setting a tight interval range
  # (e.g. Min=7, Max=9) causes BlueZ to reject ZMK's post-connect parameter update
  # request (ZMK asks for ~50ms interval for power saving) — BlueZ rejects it as
  # out-of-range, ZMK disconnects. Let BlueZ and the keyboard negotiate freely.
  #
  # Experimental deliberately omitted — enables RAP/BAP profiles the Intel adapter
  # (Legacy ROM 2015) doesn't support, causing rap_accept() failures every reconnect.
  hardware.bluetooth.settings = {
    General = {
      FastConnectable = true;
      JustWorksRepairing = "always";
    };
  };

  # The btusb module enables autosuspend by default (enable_autosuspend=Y), which
  # overrides udev rules written on ACTION=="add". Disabling it at the module level
  # is the only reliable way to keep a Bluetooth adapter from resetting under a
  # BLE HID device (e.g. Glove80) — without this the adapter can re-flash its
  # firmware periodically, dropping the link and triggering UHID reconnect churn.
  boot.extraModprobeConfig = ''
    options btusb enable_autosuspend=0
  '';
}
