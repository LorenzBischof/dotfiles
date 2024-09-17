{ config, pkgs, lib, ... }:
let
  serviceOption = lib.types.submodule {
    options = {
      href = lib.mkOption {
        type = lib.types.str;
        description = "URL for the service";
      };
      # Add other service-specific options here
    };
  };
in
{
  options = {
    homelab.dashboard = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf serviceOption);
      default = { };
      description = "Dashboard services configuration";
    };
  };
  config = {
    services.homepage-dashboard = {
      enable = true;
    };
    services.homepage-dashboard.services = (lib.mapAttrsToList
      (group: services: {
        ${group} = lib.mapAttrsToList
          (name: value: {
            ${name} = value;
          })
          services;
      })
      config.homelab.dashboard);

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
  };
}
