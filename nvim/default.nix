{
  imports = [
    ./lsp.nix
    ./completion.nix
    ./telescope.nix
    ./avante.nix
  ];

  viAlias = true;
  vimAlias = true;

  colorschemes.base16 = {
    enable = true;
    colorscheme = "eighties";
  };
  keymaps = [
    {
      key = "<space>";
      action = ":noh<cr>";
      options.silent = true;
      mode = [ "n" ];
    }
    {
      key = "<C-h>";
      action = "<C-w>";
      mode = [ "i" ];
    }
    {
      key = "<C-BS>";
      action = "<C-w>";
      mode = [ "i" ];
    }
  ];
  globals = {
    mapleader = "ß";
  };
  opts = {
    incsearch = true; # Incremental search: show match for partly typed search command
    hlsearch = true; # Hilight searches by default
    ignorecase = true; # Ignore case when searching...
    smartcase = true; # ...unless we type a capital
    autoindent = true;
    smartindent = true;
    tabstop = 4;
    shiftwidth = 4;
    expandtab = true;
    termguicolors = true;
    background = "dark";
    # opt.cursorline = true;
    relativenumber = true;
    number = true;
    signcolumn = "yes:1";
    mouse = "";
    wrap = false; # Disable wrapping
    undofile = true; # enable persistent undo
    undolevels = 1000;
    splitbelow = true;
    splitright = true;
    laststatus = 3;
  };
  plugins = {
    gitsigns.enable = true;
    lualine.enable = true;
    treesitter = {
      enable = true;
      settings = {
        indent.enable = true;
        highlight.enable = true;
      };
    };
    trim.enable = true;
  };
  files."ftplugin/nix.lua" = {
    opts = {
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
    };
  };
}
