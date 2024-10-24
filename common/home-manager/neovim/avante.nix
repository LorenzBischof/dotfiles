{ pkgs, vimPluginFromGitHub, ... }:
{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      avante-nvim
      plenary-nvim
      dressing-nvim
      nui-nvim
      nvim-web-devicons
      render-markdown-nvim
    ];
    extraLuaConfig = /* lua */ ''
      require('avante_lib').load()
      require('avante').setup({
          claude = {
              api_key_name = {"cat", "/run/agenix/anthropic-api-key"},
          },
      })
      require('render-markdown').setup({
          opts = {
              file_types = { "markdown", "Avante" },
          },
          ft = { "markdown", "Avante" },
      })
    '';
  };
}
