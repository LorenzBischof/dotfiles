{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    libnotify
  ];
  services.dunst.enable = true;
  stylix.targets.dunst.enable = true;
}
