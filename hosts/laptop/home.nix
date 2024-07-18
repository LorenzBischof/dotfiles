{ config, pkgs, lib, stylix, nix-secrets, ... }:
{
  imports = [
    ./home-manager/alacritty
    ./home-manager/dunst
    ./home-manager/foot.nix
    ./home-manager/sway
    ./home-manager/i3
    ./home-manager/scripts
    ../../common/home-manager/git
    ../../common/home-manager/neovim
    ../../common/home-manager/shell
    nix-secrets.homeManagerModule
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    mullvad-browser
    firefox
    keepassxc
    gnumake
    logseq
    pavucontrol
    tmux
    dtrx
    jellyfin-media-player
    xournalpp
    gnome.simple-scan
    mpv
    gramps
    imv
    # Required so that Logseq can open links
    # There is probably a NixOS option for this...
    xdg-utils
    # fonts
    fira-code
    fira-code-symbols
    font-awesome
    liberation_ttf
    mplus-outline-fonts.githubRelease
    nerdfonts
    noto-fonts
    noto-fonts-emoji
    proggyfonts
  ];

  systemd.user.startServices = true;
  gtk = {
    enable = true;
    theme = {
      package = pkgs.gnome.gnome-themes-extra;
      name = "Adwaita-dark";
    };
  };

  fonts.fontconfig.enable = true;
  programs = {
    go.enable = true;
    thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
      };
    };
    ssh = {
      enable = true;
      matchBlocks = {
        "*" = {
          identitiesOnly = true;
        };
        "nas" = {
          hostname = "192.168.0.124";
          user = "jagxtqoanxgsj";
          identityFile = "~/.ssh/id_ed25519_sk_rk_homelab";
        };
        "helios" = {
          hostname = "192.168.0.20";
          user = "lbischof";
          identityFile = "~/.ssh/id_ed25519_sk_rk_homelab";
        };
        "scanner" = {
          hostname = "192.168.0.157";
          user = "pi";
          identityFile = "~/.ssh/id_ed25519_sk_rk_homelab";
        };
        "ha" = {
          hostname = "192.168.0.102";
          user = "hassio";
          identityFile = "~/.ssh/id_ed25519_sk_rk_homelab";
        };
        "rpi3" = {
          hostname = "192.168.0.108";
          user = "nixos";
          identityFile = "~/.ssh/id_ed25519_sk_rk_homelab";
        };
      };
    };
  };

  services.etesync-dav.enable = true;


  home = {
    file.".config/yubikey-touch-detector/service.conf".text = ''
      YUBIKEY_TOUCH_DETECTOR_LIBNOTIFY=true
    '';

    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    username = "lbischof";
    homeDirectory = "/home/lbischof";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "23.05"; # Please read the comment before changing.
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
