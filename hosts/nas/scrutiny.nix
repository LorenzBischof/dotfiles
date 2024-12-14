{
  config,
  pkgs,
  lib,
  secrets,
  ...
}:
{
  services.scrutiny.enable = true;
  services.nginx.virtualHosts."scrutiny.${config.homelab.domain}" = {
    forceSSL = true;
    useACMEHost = config.homelab.domain;
    enableAuthelia = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.scrutiny.settings.web.listen.port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
      enableAuthelia = true;
    };
  };

  homelab.dashboard.Monitoring.Scrutiny.href = "https://scrutiny.${config.homelab.domain}";
}
