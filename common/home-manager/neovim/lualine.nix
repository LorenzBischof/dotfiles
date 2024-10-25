{ pkgs, vimPluginFromGitHub, ... }:
{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      lualine-nvim
    ];
    extraLuaConfig = # lua
      ''
        require('lualine').setup()
      '';
  };
}
