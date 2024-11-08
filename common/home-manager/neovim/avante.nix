{
  config,
  lib,
  pkgs,
  vimPluginFromGitHub,
  ...
}:

with lib;

let
  cfg = config.my.programs.neovim.plugins.avante;
in
{
  options.my.programs.neovim.plugins.avante = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable avante-nvim configuration";
    };
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        avante-nvim
        plenary-nvim
        dressing-nvim
        nui-nvim
        nvim-web-devicons
        render-markdown-nvim
      ];
      extraLuaConfig = # lua
        ''
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
  };
}
