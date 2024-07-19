{ config, pkgs, lib, ... }:
let
  fromGitHub = rev: ref: repo: pkgs.vimUtils.buildVimPlugin {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = ref;
    src = builtins.fetchGit {
      inherit rev;
      url = "https://github.com/${repo}.git";
      #      ref = ref;
    };
  };
in
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
      (fromGitHub "3a22cde57fc5bdf984d1df3464ab32691cb13f00" "v0.3.6" "frankroeder/parrot.nvim")
      #        nvim-tree
    ];
    extraPackages = with pkgs; [
      gopls
      #      nixd
      nil
      lua-language-server
      fzf
      ripgrep
      terraform-ls
      regols
    ];
  };
  xdg.configFile.nvim = {
    source = ./config;
    recursive = true;
  };
}
