{ modulesPath, lib, self, nixpkgs, pkgs, config, ... }: {
  imports = [
    #"${toString modulesPath}/installer/cd-dvd/installation-cd-graphical-plasma5-new-kernel.nix"
    "${toString modulesPath}/installer/cd-dvd/installation-cd-base.nix"
  ];

  options = {
    device = lib.mkOption { type = lib.types.str; };
    mainuser = lib.mkOption { type = lib.types.str; };
  };

  config = {
    networking.hostName = config.device;

    environment.systemPackages = [ pkgs.git pkgs.kitty ];
    nix = {
      nixPath = lib.mkForce [ "self=/etc/self/compat" "nixpkgs=/etc/nixpkgs" ];
      registry.self.flake = self;
      registry.nixpkgs.flake = nixpkgs;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      settings = {
        trusted-users = [ "root" config.mainuser "@wheel" ];
      };
    };
    environment.etc.nixpkgs.source = nixpkgs;
    environment.etc.self.source = self;

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.PermitRootLogin = lib.mkForce "without-password";
    };

    users.users.nixos.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKbzinQvw6VH6UeR3QcdU4tnzzgI9nWWWtqJd7SHN6rG"
    ];

    users.users.root.openssh.authorizedKeys.keys = config.users.users.nixos.openssh.authorizedKeys.keys;

    isoImage.squashfsCompression = "zstd -Xcompression-level 3";
  };
}
