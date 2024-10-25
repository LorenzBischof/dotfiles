{ pkgs, vimPluginFromGitHub, ... }:
{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
      nvim-treesitter-context
      nvim-treesitter-textobjects
    ];
    extraLuaConfig = # lua
      ''
        require('treesitter-context').setup{
            max_lines = 1,
        }
          require('nvim-treesitter.configs').setup {
              auto_install = false,

              highlight = {
                  enable = true,
              },
              indent = {
                  enable = true,
              },
          }
      '';
  };
}
