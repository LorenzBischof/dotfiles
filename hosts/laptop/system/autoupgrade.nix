{ config, pkgs, ... }:
{
  system.autoUpgrade = {
    enable = true;
    # Warning: if an unauthorized user has access to my account, they could escalate privileges.
    flake = "${config.users.users.lbischof.home}/git/github.com/lorenzbischof/dotfiles";
    flags = [
      "--update-input"
      "nixpkgs"
      # Disable for now, because Git cannot find author identity information
      #      "--commit-lock-file"
      "-L" # print build logs
    ];
    randomizedDelaySec = "45min";
  };
  systemd.services = {
    # This is required, because the Git identity is configured per directory
    nixos-upgrade = {
      environment = {
        GIT_AUTHOR_NAME = "Lorenz Bischof";
        GIT_COMMITTER_NAME = "Lorenz Bischof";
        GIT_AUTHOR_EMAIL = "1837725+LorenzBischof@users.noreply.github.com";
        GIT_COMMITTER_EMAIL = "1837725+LorenzBischof@users.noreply.github.com";
      };
      onSuccess = [ "notify-upgrade-success.service" ];
      onFailure = [ "notify-upgrade-failure.service" ];
    };
    "notify-upgrade-success" =
      {
        serviceConfig = {
          User = "lbischof";
        };
        environment = {
          # The variable %U does not seem to work
          DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
        };
        script = ''
          ${pkgs.libnotify}/bin/notify-send "Auto upgrade success";
        '';
      };
    "notify-upgrade-failure" =
      {
        serviceConfig = {
          User = "lbischof";
        };
        environment = {
          # The variable %U does not seem to work
          DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
        };
        script = ''
          ${pkgs.libnotify}/bin/notify-send --urgency=critical "Auto upgrade failure!";
        '';
      };
  };
}
