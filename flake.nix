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
      # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-access-tokens
      # https://github.blog/2022-10-18-introducing-fine-grained-personal-access-tokens-for-github/
      url = "github:lorenzbischof/nix-secrets";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, stylix, nix-index-database, nix-secrets, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/laptop/configuration.nix
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.lbischof = import ./hosts/laptop/home.nix;
            home-manager.extraSpecialArgs = {
              inherit nix-secrets;
            };
          }
          nix-index-database.nixosModules.nix-index
          {
            # Pin the registry
            # https://ayats.org/blog/channels-to-flakes/
            nix.registry.nixpkgs.flake = nixpkgs;
            nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
          }
        ];
      };
      homeConfigurations.bischoflo = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./hosts/wsl/home.nix
          nix-index-database.hmModules.nix-index
          {
            programs.nix-index-database.comma.enable = true;
            # Pin the registry
            # https://ayats.org/blog/channels-to-flakes/
            nix.registry.nixpkgs.flake = nixpkgs;
            home.sessionVariables.NIX_PATH = "nixpkgs=flake:nixpkgs$\{NIX_PATH:+:$NIX_PATH}";
          }
        ];
      };
      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
