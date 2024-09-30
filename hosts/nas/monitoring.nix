{ config, pkgs, secrets, ... }:
let
  inherit (config.homelab) domain;
in
{
  services = {
    prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [ "systemd" "processes" ];
    };

    prometheus = {
      enable = true;
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [{
            targets = [
              "localhost:${toString config.services.prometheus.exporters.node.port}"
            ];
          }];
        }
        {
          job_name = "restic";
          static_configs = [{
            targets = [
              "localhost:${toString config.services.prometheus.exporters.restic.port}"
            ];
          }];
        }
      ];
    };

    grafana = {
      enable = true;
      settings = {
        server = {
          domain = "grafana.${domain}";
        };
        auth.disable_login_form = true;
        "auth.anonymous" = {
          enabled = true;
          org_role = "Admin";
        };
      };
      provision = {
        enable = true;
        datasources.settings.datasources = [{
          name = "prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:${toString config.services.prometheus.port}";
          isDefault = true;
        }];
        dashboards.settings.providers = [{
          options.path = ./dashboards;
        }];
      };
    };

    nginx.virtualHosts."grafana.${domain}" = {
      forceSSL = true;
      useACMEHost = domain;
      enableAuthelia = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        enableAuthelia = true;
      };
    };

    nginx.virtualHosts."prometheus.${domain}" = {
      forceSSL = true;
      useACMEHost = domain;
      enableAuthelia = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.prometheus.port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        enableAuthelia = true;
      };
    };

  };
  homelab.dashboard.Monitoring = {
    Grafana = {
      href = "https://${config.services.grafana.settings.server.domain}";
    };
    Prometheus = {
      href = "https://prometheus.${domain}";
    };
  };
}
