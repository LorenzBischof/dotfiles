{ config, pkgs, lib, ... }:

{

  home.file = {
    ".config/git/hooks/post-checkout" = {
      source = ./config/hooks/post-checkout;
      executable = true;
    };
  };

  programs.git = {
    enable = true;
    extraConfig = {
      core = {
        whitespace = "trailing-space, space-before-tab";
        quotepath = "off"; # https://stackoverflow.com/a/22828826
        # TODO: make sure local git hooks are also executed
        # hooksPath = "~/.config/hooks"; # https://stackoverflow.com/a/71939092
      };
      push = {
        autoSetupRemote = true;
      };
      pull = {
        ff = "only";
      };
      rebase = {
        autosquash = true;
      };
      init = {
        defaultBranch = "main";
      };
      help = {
        autocorrect = true;
      };
    };
    includes = [
      {
        condition = "gitdir:~/git/github.com/lorenzbischof/";
        path = ./config/config_github.com_lorenzbischof;
      }
    ];
  };
}
