{
  config,
  pkgs,
  lib,
  ...
}:

{

  home.file = {
    ".config/git/hooks/post-checkout" = {
      source = ./config/hooks/post-checkout;
      executable = true;
    };
  };
  programs.jujutsu = {
    enable = true;
    settings = {
      signing = {
        sign-all = true;
        backend = "ssh";
        key = "~/.ssh/id_ed25519_github.com_lorenzbischof_signing.pub";
      };
      user = {
        name = "LorenzBischof";
        email = "1837725+LorenzBischof@users.noreply.github.com";
      };
      colors = {
        commit_id = "bright black";
        author = "bright black";
        timestamp = "bright black";
        "working_copy commit_id" = "bright black";
        "working_copy author" = "bright black";
        "working_copy timestamp" = "bright black";
      };
      ui = {
        diff-editor = ":builtin";
        default-command = "log";
      };
      template-aliases = {
        "format_short_change_id(id)" = "id.shortest()";
        "format_short_commit_id(id)" = "id.short(7)";
        "format_short_signature(signature)" = "signature.name()";
        "format_timestamp(timestamp)" = "timestamp.ago()";
      };
      git.subprocess = true;
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
