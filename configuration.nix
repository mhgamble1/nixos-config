{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # X11 / Wayland base (needed for display manager, XWayland, nvidia config)
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];

  # NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true; # adds nvidia-suspend/resume hooks; fixes Wayland wake
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.graphics.enable = true;

  # Display manager — SDDM with Wayland support
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # dconf — needed for GTK4 apps and portals to read theme/color-scheme settings
  programs.dconf.enable = true;

  # Hyprland compositor
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # XDG portals for screen sharing / file dialogs under Wayland
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Configure keymap in X11 / Wayland
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # NAS - Samba mount (automounts on access, unmounts after idle)
  fileSystems."/mnt/nas" = {
    device = "//192.168.1.100/nas";
    fsType = "cifs";
    options = [
      "credentials=/etc/nixos/smb-credentials"
      "uid=1000"
      "gid=100"
      "iocharset=utf8"
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
    ];
  };

  # Default terminal for xdg-terminal-exec (used by GIO for Terminal=true desktop apps)
  xdg.terminal-exec.settings = {
    default = [ "com.mitchellh.ghostty.desktop" ];
  };

  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };


  # Mullvad VPN
  services.mullvad-vpn.enable = true;

  # Allow LAN traffic to bypass the VPN tunnel (required for NAS at 192.168.1.100)
  systemd.services.mullvad-lan-allow = {
    description = "Allow LAN access through Mullvad VPN";
    after = [ "mullvad-daemon.service" ];
    wants = [ "mullvad-daemon.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.mullvad-vpn}/bin/mullvad lan set allow";
      RemainAfterExit = true;
    };
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Fish shell — must be enabled system-wide to appear in /etc/shells
  programs.fish.enable = true;

  # User account
  users.users.mhg = {
    isNormalUser = true;
    description = "mhg";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.noto
  ];

  # Home Manager — NixOS module integration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.mhg = import ./home.nix;
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    wget
    git
    gh
    spotify
    cifs-utils
    zathura
  ];

  system.stateVersion = "25.11";
}
