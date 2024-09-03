{ config, pkgs, ... }:
let
  asustor-platform-driver = config.boot.kernelPackages.callPackage ./asustor-platform-driver.nix { };
in
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    extraModulePackages = [ asustor-platform-driver ];
  };

  networking.hostName = "nixos";

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

  hardware.fancontrol = {
    enable = true;
    config = ''
      INTERVAL=10
      DEVPATH=hwmon1=devices/platform/asustor_it87.2608 hwmon2=devices/platform/coretemp.0
      DEVNAME=hwmon1=it8728 hwmon2=coretemp
      FCTEMPS= hwmon1/pwm1=hwmon2/temp2_input
      FCFANS= hwmon1/pwm1=hwmon1/fan1_input
      MINTEMP= hwmon1/pwm1=20
      MAXTEMP= hwmon1/pwm1=110
      MINSTART= hwmon1/pwm1=30
      MINSTOP= hwmon1/pwm1=18
      MINPWM=0 hwmon1/pwm1=0
      MAXPWM=255
    '';
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
