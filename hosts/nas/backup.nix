{ config, pkgs, lib, secrets, ... }:
{
  services.restic.backups.daily = {
    initialize = true;
    environmentFile = config.age.secrets.restic-env.path;
    repositoryFile = lib.mkDefault config.age.secrets.restic-repo.path;
    passwordFile = config.age.secrets.restic-password.path;

    paths = [
      config.homelab.storage
    ];
  };
}
