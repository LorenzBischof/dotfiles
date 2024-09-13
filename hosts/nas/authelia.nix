{ config, pkgs, secrets, ... }:
let
  inherit (config.homelab) domain;
in
{
  services.authelia.instances.main = {
    enable = true;
    secrets = {
      jwtSecretFile = config.age.secrets.authelia-jwt-secret.path;
      storageEncryptionKeyFile = config.age.secrets.authelia-storage-encryption-key.path;
      sessionSecretFile = config.age.secrets.authelia-session-secret.path;
    };
    settings = {
      authentication_backend.file.path = config.age.secrets.authelia-users.path;
      access_control.default_policy = "one_factor";
      session.cookies = [
        {
          domain = domain;
          authelia_url = "https://auth.${domain}";
        }
      ];
      session.redis.host = config.services.redis.servers.authelia-main.unixSocket;
      storage.local.path = "/var/lib/authelia-main/db.sqlite3";
      notifier.filesystem.filename = "/var/lib/authelia-main/notification.txt";
    };
  };
  services.redis.servers.authelia-main = {
    enable = true;
    user = "authelia-main";
  };
  services.nginx.virtualHosts."auth.${domain}" = {
    forceSSL = true;
    useACMEHost = domain;
    locations."/" = {
      proxyPass = "http://127.0.0.1:9091";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
