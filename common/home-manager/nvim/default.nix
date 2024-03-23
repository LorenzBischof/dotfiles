{ config, pkgs, lib, ... }:

{

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfig = ''
      :luafile ~/.config/nvim/lua/init.lua
    '';
    plugins = with pkgs.vimPlugins; [
      gitsigns-nvim
      nvim-lspconfig
      base16-nvim
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      luasnip
      lsp-zero-nvim
      fzf-lua
      #        nvim-tree
    ];
    extraPackages = with pkgs; [
      gopls
      #      nixd
      nil
      lua-language-server
      fzf
      ripgrep
    ];
  };
  xdg.configFile.nvim = {
    source = ./config;
    recursive = true;
  };
}
