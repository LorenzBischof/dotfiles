{ config, pkgs, lib, ... }:
let
  vimPluginFromGitHub = rev: ref: repo: pkgs.vimUtils.buildVimPlugin {
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
  _module.args.vimPluginFromGitHub = vimPluginFromGitHub;
  imports = [
    ./avante.nix
    ./treesitter.nix
    ./lualine.nix
  ];

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
      base16-nvim
      fzf-lua
      # LSP
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      luasnip
      lsp-zero-nvim
      conform-nvim
      #      (vimPluginFromGitHub "3a22cde57fc5bdf984d1df3464ab32691cb13f00" "v0.3.6" "frankroeder/parrot.nvim")
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
