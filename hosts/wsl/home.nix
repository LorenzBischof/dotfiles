{ config, pkgs, ... }:
let
  regula = pkgs.stdenv.mkDerivation {
    name = "regula";
    src = pkgs.fetchzip {
      url = "https://github.com/fugue/regula/releases/download/v3.2.1/regula_3.2.1_Linux_x86_64.tar.gz";
      sha256 = "sha256-fN6ABQnDfhqnRBcBlc6hV4iKtJRvngNPDrBkCXd9k+k=";
      curlOpts = "-k";
      stripRoot = false;
    };
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      cp $src/$name $out/bin/$name
      chmod +x $out/bin/$name
    '';
  };
  fregot = pkgs.stdenv.mkDerivation {
    name = "fregot";
    src = pkgs.fetchzip {
      url = "https://github.com/fugue/fregot/releases/download/v0.14.2/fregot-v0.14.2-linux.tar.gz";
      sha256 = "sha256-883R1ocsx98oq73D//8jVQOz/3G8Cw7XxTb5Ugn+yJQ=";
      curlOpts = "-k";
      #stripRoot = false;
    };
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      cp $src/$name $out/bin/$name
      chmod +x $out/bin/$name
    '';
  };
in
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
    kubectl

    #    cue
    #    open-policy-agent
    #    kubebuilder
    #    kind
    #    argocd
    terraform
    #    yq

    #    helmfile
    #    (wrapHelm kubernetes-helm { plugins = [ kubernetes-helmPlugins.helm-diff ]; })
    regula
    fregot
    gitlab-runner
    gotools
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
