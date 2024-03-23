{ config, pkgs, ... }:

{
  imports = [
    ../../common/home-manager/nvim
    ../../common/home-manager/shell
    ../../common/home-manager/git
  ];

  nixpkgs.config.allowUnfree = true;

  programs.zsh = {
    sessionVariables = {
      http_proxy = "http://localhost:8888";
      https_proxy = "http://localhost:8888";
      HTTP_PROXY = "http://localhost:8888";
      HTTPS_PROXY = "http://localhost:8888";
      no_proxy = "localhost,127.0.0.1";
      NO_PROXY = "localhost,127.0.0.1";
    };
  };

  # TODO: can we use a yubikey?
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    golangci-lint
    comma
    kubectl

    #    cue
    #    open-policy-agent
    #    kubebuilder
    #    kind
    #    argocd
    #    terraform
    #    yq

    #    helmfile
    #    (wrapHelm kubernetes-helm { plugins = [ kubernetes-helmPlugins.helm-diff ]; })
  ];

  programs.go.enable = true;

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "bischoflo";
  home.homeDirectory = "/home/bischoflo";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.
}
