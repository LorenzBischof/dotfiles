{ config, pkgs, lib, ... }:
{
  programs = {
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        format = "$character";
        right_format = "$all";
      };
    };
    zsh = {
      enable = true;
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
