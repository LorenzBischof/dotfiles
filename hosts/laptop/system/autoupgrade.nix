{ config, pkgs, ... }:
{
  # This is required, because the Git identity is configured per directory
  systemd.services.nixos-upgrade.environment.GIT_AUTHOR_NAME = "Lorenz Bischof";
  systemd.services.nixos-upgrade.environment.GIT_COMMITTER_NAME = "Lorenz Bischof";
  systemd.services.nixos-upgrade.environment.GIT_AUTHOR_EMAIL = "1837725+LorenzBischof@users.noreply.github.com";
  systemd.services.nixos-upgrade.environment.GIT_COMMITTER_EMAIL = "1837725+LorenzBischof@users.noreply.github.com";
  system.autoUpgrade = {
    enable = true;
    # Warning: if an unauthorized user has access to my account, they could escalate privileges.
    flake = "${config.users.users.lbischof.home}/git/github.com/lorenzbischof/dotfiles";
    flags = [
      "--update-input"
      "nixpkgs"
      "--commit-lock-file"
      "-L" # print build logs
    ];
    randomizedDelaySec = "45min";
  };
  systemd.services.nixos-upgrade.onSuccess = [ "notify-upgrade-success.service" ];
  systemd.services."notify-upgrade-success" =
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
  systemd.services.nixos-upgrade.onFailure = [ "notify-upgrade-failure.service" ];
  systemd.services."notify-upgrade-failure" =
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
}
