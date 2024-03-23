{ config, pkgs, lib, ... }:

{
  stylix.targets.foot.enable = true;
  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        font = lib.mkForce "monospace:size=18";
        dpi-aware = lib.mkForce "yes";
      };
    };
  };
}
