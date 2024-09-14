{ config, pkgs, secrets, ... }:
let
  inherit (config.homelab) domain;
in
{
  services = {
    # https://nixos.org/manual/nixos/stable/#module-services-prometheus-exporters
    prometheus.exporters.node = {
      enable = true;
      # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/monitoring/prometheus/exporters.nix
      enabledCollectors = [ "systemd" ];
      # /nix/store/zgsw0yx18v10xa58psanfabmg95nl2bb-node_exporter-1.8.1/bin/node_exporter  --help
      extraFlags = [ "--collector.ethtool" "--collector.softirqs" "--collector.tcpstat" "--collector.wifi" ];
    };

    # https://wiki.nixos.org/wiki/Prometheus
    # https://nixos.org/manual/nixos/stable/#module-services-prometheus-exporters-configuration
    # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/monitoring/prometheus/default.nix
    prometheus = {
      enable = true;
      globalConfig.scrape_interval = "10s"; # "1m"
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [{
            targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
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
          access = "proxy";
          isDefault = true;
          editable = false;
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

    homepage-dashboard.services = [
      {
        Monitoring = [
          {
            "Grafana" = {
              href = "https://${config.services.grafana.settings.server.domain}";
            };
            "Prometheus" = {
              href = "https://prometheus.${domain}";
            };
          }
        ];
      }
    ];
  };
}
