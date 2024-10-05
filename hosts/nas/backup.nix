{ config, pkgs, lib, secrets, ... }:
{
  services.restic.backups.daily = {
    initialize = true;
    environmentFile = config.age.secrets.restic-env.path;
    repositoryFile = lib.mkDefault config.age.secrets.restic-repo.path;
    passwordFile = config.age.secrets.restic-password.path;

    timerConfig.OnCalendar = "10:00";
  };
  services.restic.backups.weekly = {
    environmentFile = config.age.secrets.restic-env.path;
    repositoryFile = lib.mkDefault config.age.secrets.restic-repo.path;
    passwordFile = config.age.secrets.restic-password.path;

    timerConfig.OnCalendar = "Mon 14:00";

    paths = null; # disable backup
    createWrapper = false;
    runCheck = true;
  };

  services.prometheus.exporters.restic = {
    enable = true;
    repository = secrets.restic-repository;
    passwordFile = config.age.secrets.restic-password.path;
    environmentFile = config.age.secrets.restic-env.path;
    refreshInterval = 3600;
  };
  systemd.services.prometheus-restic-exporter = {
    environment.NO_CHECK = "true";
    # https://github.com/NixOS/nixpkgs/issues/342243
    environment.RESTIC_CACHE_DIR = "/var/cache/restic-exporter";
    serviceConfig.CacheDirectory = "restic-exporter";
  };
}
