{
  description = "Nix configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-secrets = {
      # Access token expires after one year!
      # https://nix.dev/manual/nix/stable/command-ref/conf-file#conf-access-tokens
      # https://github.blog/2022-10-18-introducing-fine-grained-personal-access-tokens-for-github/
      url = "github:lorenzbischof/nix-secrets";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    talon = {
      # https://github.com/nix-community/talon-nix/pull/21
      url = "github:LorenzBischof/talon-nix/pango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    numen = {
      url = "github:LorenzBischof/numen-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-config = {
      url = "github:LorenzBischof/neovim-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      stylix,
      nix-index-database,
      nix-secrets,
      pre-commit-hooks,
      talon,
      numen,
      nixos-generators,
      treefmt-nix,
      neovim-config,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "electron-27.3.11"
            # Sonarr: https://github.com/NixOS/nixpkgs/issues/360592
            "aspnetcore-runtime-6.0.36"
            "aspnetcore-runtime-wrapped-6.0.36"
            "dotnet-sdk-6.0.428"
            "dotnet-sdk-wrapped-6.0.428"
          ];
        };
        overlays = [
          neovim-config.overlays.default
        ];
      };
      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
    in
    {
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          modules = [
            ./hosts/laptop/configuration.nix
            stylix.nixosModules.stylix
            talon.nixosModules.talon
            home-manager.nixosModules.home-manager
            nix-secrets.nixosModules.laptop
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.lbischof = import ./hosts/laptop/home.nix;
                extraSpecialArgs = {
                  inherit self inputs;
                };
              };
            }
            nix-index-database.nixosModules.nix-index
          ];
        };
        nas = nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          modules = [
            ./hosts/nas/configuration.nix
            nix-secrets.nixosModules.nas
          ];
          specialArgs = {
            secrets = import nix-secrets;
          };
        };
        rpi2 = nixpkgs.lib.nixosSystem {
          modules = [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix"
            {
              nixpkgs = {
                config.allowUnsupportedSystem = true;
                hostPlatform.system = "armv7l-linux";
                buildPlatform.system = "x86_64-linux"; # If you build on x86 other wise changes this.
                # ... extra configs as above
              };
            }
          ];
        };
        rpi3 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            {
              environment.systemPackages = [ pkgs.git ];
              users.users.nixos = {
                isNormalUser = true;
                extraGroups = [
                  "wheel"
                  "networkmanager"
                ];
                openssh.authorizedKeys.keys = [
                  "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDSKZEtyhueGqUow/G2ewR5TuccLqhrgwWd5VUnd6ImqAAAAC3NzaDpob21lbGFi"
                ];
              };
              services.openssh.enable = true;
              security.sudo.wheelNeedsPassword = false;
              nix.settings.trusted-users = [
                "nixos"
                "root"
              ];

              # bzip2 compression takes loads of time with emulation, skip it.
              sdImage.compressImage = false;
            }
          ];
        };
      };
      homeConfigurations.bischoflo = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./hosts/wsl/home.nix
          nix-index-database.hmModules.nix-index
          {
            programs.nix-index-database.comma.enable = true;
          }
        ];
      };
      images = {
        rpi2 = self.nixosConfigurations.rpi2.config.system.build.sdImage;
        rpi3 = self.nixosConfigurations.rpi3.config.system.build.sdImage;
      };
      packages.x86_64-linux = {
        nas-iso = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          modules = [
            {
              device = "nas";
              mainuser = "lbischof";
            }
            ./hosts/iso/configuration.nix
          ];
          specialArgs = {
            inherit self nixpkgs;
          };
          format = "install-iso";
        };
      };
      formatter.${system} = treefmtEval.config.build.wrapper;
      checks.${system} = {
        formatting = treefmtEval.config.build.check self;

        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt-rfc-style.enable = true;
            check-merge-conflicts.enable = true;
          };
        };
      };
      devShells.${system}.default = pkgs.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages ++ [
          pkgs.flyctl
          pkgs.attic-client
        ];
      };
    };
}
