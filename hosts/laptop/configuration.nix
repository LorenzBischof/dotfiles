# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./system/hardware-configuration.nix
      ./system/suspend.nix
      ./system/autoupgrade.nix
      ./system/detect-reboot-needed.nix
      ./system/detect-syncthing-conflicts.nix
    ];

  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/eighties.yaml";
  services.batteryNotifier = {
    enable = true;
    notifyCapacity = 15;
    suspendCapacity = 10;
  };
  system.activationScripts.diff = ''
    ${pkgs.nix}/bin/nix store \
        diff-closures /run/current-system "$systemConfig"
  '';

  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.kernelParams = [ "nohibernate" ];
  boot.loader.grub = {
    enable = true;
    zfsSupport = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    mirroredBoots = [
      { devices = [ "nodev" ]; path = "/boot"; }
    ];
  };
  programs.command-not-found.enable = false;

  # find "$(nix eval --raw 'nixpkgs#kbd')/share/keymaps" -name '*.map.gz' | grep "de_CH"
  console.keyMap = "de_CH-latin1";

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  networking.hostId = "ac63adf1";
  networking.hostName = "laptop"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # AppArmor
  # Disabled for now, because I get an error when switching
  #security.apparmor.enable = true;

  # Temporary fix for Swaylock issue TODO: what issue?
  security.pam.services.swaylock = { };

  # Containers
  virtualisation.podman.enable = true;

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  services.tailscale.enable = true;

  #services.avahi.enable = true;
  #services.avahi.nssmdns = true;
  hardware.sane.enable = true;
  # For some reason the avahi options above do not work
  hardware.sane.netConf = "192.168.0.157";

  hardware.brillo.enable = true;

  hardware.i2c.enable = true;
  # Required for Sway
  hardware.opengl.enable = true;

  hardware.opentabletdriver.enable = true;

  security.polkit.enable = true;

  # Sound
  sound.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.syncthing = {
    enable = true;
    user = "lbischof";
    dataDir = "/home/lbischof";
    # overrideDevices = true;
    #overrideFolders = true;
  };
  # Syncthing ports:
  # 22000 TCP and/or UDP for sync traffic
  # 21027/UDP for discovery
  # source: https://docs.syncthing.net/users/firewall.html
  networking.firewall.allowedTCPPorts = [ 22000 ];
  networking.firewall.allowedUDPPorts = [ 22000 21027 ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lbischof = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "keyd" "i2c" "scanner" "adbUsers" ];
    shell = pkgs.zsh;
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    home-manager
    ddcutil
    just
  ];

  programs.nix-index-database.comma.enable = true;

  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.sway}/bin/sway";
        user = "lbischof";
      };
      default_session = initial_session;
    };
  };
  programs = {
    zsh.enable = true;
    # Required for Stylix
    dconf.enable = true;
    yubikey-touch-detector.enable = true;
    evolution.enable = true;
    adb.enable = true;
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        alsa-lib
        at-spi2-atk
        at-spi2-core
        atk
        cairo
        cups
        curl
        dbus
        expat
        fontconfig
        freetype
        fuse
        fuse3
        gdk-pixbuf
        glib
        gtk3
        icu
        libGL
        libappindicator-gtk3
        libdrm
        libglvnd
        libnotify
        libpulseaudio
        libunwind
        libusb1
        libuuid
        libxkbcommon
        mesa
        nspr
        nss
        openssl
        pango
        pipewire
        stdenv.cc.cc
        systemd
        vulkan-loader
        xorg.libX11
        xorg.libXScrnSaver
        xorg.libXcomposite
        xorg.libXcursor
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXi
        xorg.libXrandr
        xorg.libXrender
        xorg.libXtst
        xorg.libxcb
        xorg.libxkbfile
        xorg.libxshmfence
        zlib
      ];
    };
  };

  # xdg-desktop-portal works by exposing a series of D-Bus interfaces
  # known as portals under a well-known name
  # (org.freedesktop.portal.Desktop) and object path
  # (/org/freedesktop/portal/desktop).
  # The portal interfaces include APIs for file access, opening URIs,
  # printing and others.
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    # TODO: Figure out if we can use configPackages
    config.common.default = "*";
  };

  services = {
    hardware.bolt.enable = true;

    # Firmware updater
    fwupd.enable = true;

    # Power optimization
    auto-cpufreq.enable = true;
    thermald.enable = true;
  };

  system.stateVersion = "23.05"; # Did you read the comment?
}
