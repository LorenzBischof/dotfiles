{ config, pkgs, lib, ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # add_newline = false;
      # format = "$character";
      # right_format = "$all";
    };
  };
  programs.zsh = {
    enable = true;
    initExtra = ''
      source ~/.zshrc-extra
    '';
  };

  home.file = {
    ".zshrc-extra".source = ./initextra;
  };

  programs.eza = {
    enable = true;
    git = true;
    icons = true;
  };

}
