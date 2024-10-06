{ config, pkgs, lib, secrets, ... }:
let
  photosDir = "/data/photos";
in
{
  users.groups.photos = { };

  systemd.tmpfiles.settings."10-photos" = {
    ${photosDir}.d = {
      group = "photos";
      mode = "0750";
    };
  };
  services.restic.backups.daily.paths = [ photosDir ];
}
