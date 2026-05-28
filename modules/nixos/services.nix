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
  hardware.logitech.wireless.enableGraphical = true;

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
  # is the only reliable way to keep the Intel adapter (8087:0aa7) from resetting.
  # Without this the adapter re-flashes its firmware every ~30min, dropping all
  # BLE HID devices (Glove80) and triggering a cascade of UHID reconnect events.
  boot.extraModprobeConfig = ''
    options btusb enable_autosuspend=0
  '';

  services.udev.extraRules = ''
    # Belt-and-suspenders: also pin the Intel BT adapter via udev
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="8087", ATTR{idProduct}=="0aa7", ATTR{power/control}="on"
    # Prevent Genesys Logic USB hub (05e3:0610) from autosuspending — downstream
    # devices (e.g. Logitech Unifying Receiver) lag or disconnect if the hub sleeps.
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="05e3", ATTR{idProduct}=="0610", ATTR{power/control}="on"
  '';
}
