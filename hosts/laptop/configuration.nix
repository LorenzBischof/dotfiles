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

  stylix = {
    enable = true;
    image = ./home-manager/sway/wallpaper_cropped_1.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/eighties.yaml";
    autoEnable = false;
    fonts.sizes = {
      popups = 18;
      desktop = 14;
    };
    cursor = {
      size = 28;
      #  package = pkgs.breeze-qt5;
      #  name = "Breeze";
    };
  };

  services = {
    batteryNotifier = {
      enable = true;
      notifyCapacity = 15;
      suspendCapacity = 10;
    };
    blueman.enable = true;

    tailscale.enable = true;
  };
  system.activationScripts.diff = ''
    ${pkgs.nix}/bin/nix store \
        diff-closures /run/current-system "$systemConfig"
  '';

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    kernelParams = [ "nohibernate" ];
    loader.grub = {
      enable = true;
      zfsSupport = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      mirroredBoots = [
        { devices = [ "nodev" ]; path = "/boot"; }
      ];
    };
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  networking = {
    hostId = "ac63adf1";
    hostName = "laptop"; # Define your hostname.
    # Pick only one of the below networking options.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
  };

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # AppArmor
  # Disabled for now, because I get an error when switching
  #security.apparmor.enable = true;

  # Temporary fix for Swaylock issue TODO: what issue?
  security.pam.services.swaylock = { };

  # Containers
  virtualisation = {
    podman.enable = true;
    libvirtd.enable = true;
  };
  programs.virt-manager.enable = true;


  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    sane.enable = true;
    # For some reason the avahi options above do not work
    sane.netConf = "192.168.0.157";

    brillo.enable = true;

    i2c.enable = true;
    # Required for Sway
    opengl.enable = true;

    opentabletdriver.enable = true;
  };
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
    extraGroups = [ "wheel" "video" "keyd" "i2c" "scanner" "adbUsers" "libvirtd" ];
    shell = pkgs.zsh;
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    home-manager
    ddcutil
    just
    snixembed
  ];


  services.xserver = {
    enable = true;
    xkb = {
      layout = "de";
      variant = "adnw";
    };
  };
  console.useXkbConfig = true;

  services.libinput.enable = true;
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.displayManager.startx.enable = true;

  # The following is required for the entries in the login manager
  # Configuration is managed by home-manager
  services.xserver.windowManager.i3.enable = true;
  programs.sway.enable = true;

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --xsessions ${config.services.displayManager.sessionData.desktops}/share/xsessions --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --remember --remember-user-session";
      user = "greeter";
    };
  };

  programs = {
    nix-index-database.comma.enable = true;
    command-not-found.enable = false;
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

  # https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;

  system.stateVersion = "23.05"; # Did you read the comment?
}
