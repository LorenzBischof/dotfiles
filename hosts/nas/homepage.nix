{ config, pkgs, lib, ... }:
{
  services.homepage-dashboard = {
    enable = true;
  };
  services.nginx.virtualHosts."homepage.${config.homelab.domain}" = {
    forceSSL = true;
    useACMEHost = config.homelab.domain;
    enableAuthelia = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.homepage-dashboard.listenPort}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
      enableAuthelia = true;
    };
  };
}
