{ config, pkgs, lib, secrets, ... }:
let
  asustor-platform-driver = config.boot.kernelPackages.callPackage ./asustor-platform-driver.nix { };
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./monitoring.nix
      ./homelab.nix
      ./homepage.nix
      ./authelia.nix
      ./backup.nix
      ./paperless.nix
    ];

  homelab.domain = lib.mkDefault secrets.prod-domain;

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    extraModulePackages = [ asustor-platform-driver ];
  };

  networking.hostName = "nas";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Zurich";

  i18n.defaultLocale = "en_GB.UTF-8";

  console.keyMap = "sg";

  users.users.lbischof = {
    isNormalUser = true;
    description = "lbischof";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDSKZEtyhueGqUow/G2ewR5TuccLqhrgwWd5VUnd6ImqAAAAC3NzaDpob21lbGFi"
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    lm_sensors
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  hardware.fancontrol =
    let
      fan = "/sys/devices/platform/asustor_it87.2608/hwmon/hwmon[[:print:]]*";
    in
    {
      enable = true;
      config = ''
        INTERVAL=10
        FCTEMPS=${fan}/pwm1=/sys/devices/platform/coretemp.0/hwmon/hwmon[[:print:]]*/temp2_input
        FCFANS=${fan}/pwm1=${fan}/fan1_input
        MINTEMP=${fan}/pwm1=20
        MAXTEMP=${fan}/pwm1=110
        MINSTART=${fan}/pwm1=30
        MINSTOP=${fan}/pwm1=18
        MINPWM=0 ${fan}/pwm1=0
        MAXPWM=255
      '';
    };

  virtualisation.vmVariant = {
    homelab.domain = secrets.test-domain;
    security.acme.defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";
    services.restic.backups.daily.repositoryFile = pkgs.writeText "restic-repo" "/srv/restic-repo";

    virtualisation.qemu.networkingOptions = [
      "-device virtio-net-pci,netdev=net0"
      "-netdev tap,id=net0,br=br0,helper=/run/wrappers/bin/qemu-bridge-helper"
    ];

    virtualisation = {
      memorySize = 2048; # Use 2048MiB memory.
      cores = 3;
    };

    # Make sure the password is always correctly set
    users.mutableUsers = false;
    users.users.lbischof.password = "test";

    # Set a static IP in the VM
    # eth0 is the SLIRP interface (not sure why it still exists)
    networking.interfaces.eth1.ipv4.addresses = [{
      address = "192.168.1.2";
      prefixLength = 24;
    }];
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
