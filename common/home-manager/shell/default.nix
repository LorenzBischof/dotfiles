{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    devenv
    kubectl
  ];
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        format = "$character";
        right_format = "$all";
        aws = {
          disabled = true;
        };
      };
    };
    zsh = {
      enable = true;
      shellAliases = {
        "k" = "kubectl";
      };
      initExtra = ''
        source ~/.zshrc-extra
      '';
    };
    eza = {
      enable = true;
      git = true;
      icons = true;
    };
  };

  home.file = {
    ".zshrc-extra".source = ./initextra;
  };


}
