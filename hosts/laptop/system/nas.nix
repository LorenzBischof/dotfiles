{ config, pkgs, ... }:
{
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.allowedBridges = [ "virbr0" "br0" ];
  home-manager.users.lbischof.programs.ssh.matchBlocks = {
    "nas" = {
      hostname = "192.168.0.124";
      user = "lbischof";
      identityFile = "~/.ssh/id_ed25519_sk_rk_homelab";
    };
    "nas-unlock" = {
      hostname = "192.168.0.124";
      user = "root";
      port = 2222;
      identityFile = "~/.ssh/id_ed25519_sk_rk_homelab";
    };
    "nas.local" = {
      hostname = "192.168.1.2";
      user = "lbischof";
      identityFile = "~/.ssh/id_ed25519_sk_rk_homelab";
    };
  };
  networking.bridges.br0.interfaces = [ ];
  networking.interfaces.br0.ipv4.addresses = [{
    address = "192.168.1.1";
    prefixLength = 24;
  }];
}
