local opt = vim.opt
local g = vim.g

-- global options --
opt.incsearch = true  -- Find the next match as we type the search
opt.hlsearch = true   -- Hilight searches by default
opt.ignorecase = true -- Ignore case when searching...
opt.smartcase = true  -- ...unless we type a capital
opt.autoindent = true
opt.smartindent = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.termguicolors = true
opt.background = "dark"
-- opt.cursorline = true
opt.relativenumber = true
opt.number = true
opt.signcolumn = "yes:1"
opt.mouse = ""
opt.wrap = false    -- Disable wrapping
opt.undofile = true -- enable persistent undo
opt.undolevels = 1000
opt.splitbelow = true
opt.splitright = true

-- Set leader key
g.mapleader = " "

-- set nospell
-- set updatetime=100

vim.cmd('colorscheme base16-eighties')

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*" },
    callback = function(ev)
        local save_cursor = vim.fn.getpos(".")
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.setpos(".", save_cursor)
    end,
})

-- Clear last search highlighting
vim.api.nvim_set_keymap('n', '<Space>', ':noh<cr>', { silent = true })

-- Make ctrl backspace delete the last word
vim.api.nvim_set_keymap('i', '<C-h>', '<C-w>', { noremap = true })
vim.api.nvim_set_keymap('i', '<C-BS>', '<C-w>', { noremap = true })
