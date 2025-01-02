{
  self,
  config,
  pkgs,
  lib,
  ...
}:
{
  home.packages = [ self.packages.${pkgs.system}.nvim ];
  home.sessionVariables.EDITOR = "nvim";
}
