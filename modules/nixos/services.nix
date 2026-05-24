{ pkgs, ... }:

{
  # ── Flatpak ───────────────────────────────────────────────────────────
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
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
