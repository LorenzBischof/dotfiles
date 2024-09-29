{ config, pkgs, lib, secrets, ... }:
{
  users.groups.media = { };

  systemd.tmpfiles.settings."10-media" = {
    "/data/audiobooks".d = {
      group = "media";
      mode = "0770";
    };
    "/data/movies".d = {
      group = "media";
      mode = "0770";
    };
  };

  services.jellyfin = {
    enable = true;
    group = "media";
  };

  services.nginx.virtualHosts."jellyfin.${config.homelab.domain}" = {
    forceSSL = true;
    useACMEHost = config.homelab.domain;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8096";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };

  homelab.dashboard.Services.Jellyfin.href = "https://jellyfin.${config.homelab.domain}";
}
