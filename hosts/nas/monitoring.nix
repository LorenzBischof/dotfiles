{ config, pkgs, secrets, ... }:
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
          # Listening Address
          http_addr = "127.0.0.1";
          domain = "grafana.${config.homelab.domain}";
        };
      };
    };
    nginx.virtualHosts."grafana.${config.homelab.domain}" = {
      forceSSL = true;
      useACMEHost = config.homelab.domain;
      locations."/" = {
        proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };
}
