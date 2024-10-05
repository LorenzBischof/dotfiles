{ config, pkgs, lib, secrets, ... }:
{
  options = {
    homelab.domain = lib.mkOption {
      type = lib.types.str;
      example = "example.com";
      description = "The domain where services are reachable";
    };
  };
  config = {
    services.nginx = {
      enable = true;

      virtualHosts."_" = {
        default = true;
        locations."/".return = 444;
      };
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    security.acme = {
      acceptTerms = true;
      defaults.email = secrets.acme-email;
      certs."${config.homelab.domain}" = {
        dnsProvider = "cloudflare";
        environmentFile = config.age.secrets.cloudflare-token.path;
        extraDomainNames = [ "*.${config.homelab.domain}" ];
        group = "nginx";
        # For some reason the TXT challenge could not be resolved otherwise
        extraLegoFlags = [ "--dns.resolvers=1.1.1.1" ];
      };
    };
  };
}
