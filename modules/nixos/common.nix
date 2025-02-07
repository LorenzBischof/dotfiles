{ lib, ... }:
{
  # https://discourse.nixos.org/t/general-question-how-to-avoid-running-out-of-memory-or-freezing-when-building-nix-derivations/55351/2
  # I did not really have any problems and basically only implemented this, because I would like to activate auto upgrades in the future.
  nix = {
    daemonIOSchedClass = lib.mkDefault "idle";
    daemonCPUSchedPolicy = lib.mkDefault "idle";
  };
  # put the service in top-level slice
  # so that it's lower than system and user slice overall
  # instead of only being lower in system slice
  systemd.services.nix-daemon.serviceConfig.Slice = "-.slice";
  # always use the daemon, even executed  with root
  environment.variables.NIX_REMOTE = "daemon";
}
