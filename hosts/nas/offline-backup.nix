{ config, pkgs, lib, ... }:

let
  disks = pkgs.writeText "disks" ''
    d343f78b-7372-438a-a28a-fae768f8956e
    51d18856-b396-4195-8a26-e43917fe5dad
  '';
  offline-backup = pkgs.writeShellApplication {
    name = "offline-backup";

    runtimeInputs = with pkgs; [ curl cryptsetup util-linux rsync ];

    text = ''
      echo 1 > /sys/class/leds/green:usb/brightness

      # The backup partition is mounted there
      MOUNTPOINT=/mnt/backup

      # This is the file that will later contain UUIDs of registered backup drives
      DISKS=${disks}

      mkdir -p "$MOUNTPOINT"

      devname=""
      while IFS= read -r uuid; do
          devname="$(blkid -U "$uuid" || true)"

          if [ -n "$devname" ]; then
              break
          fi
      done < "$DISKS"

      if [ -z "$devname" ]; then
              echo "No backup disk found, exiting"
              exit 0
      fi

      echo "Backing up to $devname"
      cryptsetup open "$devname" backup --key-file <(echo -n "$(cat ${config.age.secrets.offline-backup-password.path})")
      # Mount file system if not already done. This assumes that if something is already
      # mounted at $MOUNTPOINT, it is the backup drive. It won't find the drive if
      # it was mounted somewhere else.
      (mount | grep $MOUNTPOINT) || mount /dev/mapper/backup $MOUNTPOINT

      #
      # Create backups
      #
      rsync --archive --info=progress2 ${lib.concatStringsSep " " config.services.restic.backups.daily.paths} $MOUNTPOINT

      # Just to be completely paranoid
      sync

      echo
      echo
      df -h $MOUNTPOINT

      # Unmount
      umount $MOUNTPOINT

      cryptsetup close backup

      curl https://hc-ping.com/60e529b2-3f12-4834-9f4c-11320b8ed1a0
      echo 0 > /sys/class/leds/green:usb/brightness
    '';
  };

in
{
  environment.systemPackages = [ offline-backup ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_UUID}=="d343f78b-7372-438a-a28a-fae768f8956e|51d18856-b396-4195-8a26-e43917fe5dad", TAG+="systemd", ENV{SYSTEMD_WANTS}="offline-backup.service"
  '';

  systemd.services.offline-backup = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${offline-backup}/bin/offline-backup";
    };
  };
}
