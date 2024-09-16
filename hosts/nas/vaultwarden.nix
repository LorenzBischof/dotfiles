{ config, pkgs, lib, secrets, ... }:
let
  backupDir = "/var/cache/vaultwarden-backup";
in
{
  services.vaultwarden = {
    enable = true;
    # TODO: this sets up a timer at 23:00, however it might make sense to run it before the backup service
    backupDir = backupDir;
    config = {
      DOMAIN = "https://bitwarden.${config.homelab.domain}";
      SIGNUPS_ALLOWED = false;
      ROCKET_PORT = 8222;
    };
  };
  services.nginx.virtualHosts."bitwarden.${config.homelab.domain}" = {
    forceSSL = true;
    useACMEHost = config.homelab.domain;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };

  services.restic.backups.daily.paths = [ backupDir ];

  services.homepage-dashboard.services = [
    {
      Services = [
        {
          Vaultwarden = {
            href = config.services.vaultwarden.config.DOMAIN;
          };
        }
      ];
    }
  ];

}
