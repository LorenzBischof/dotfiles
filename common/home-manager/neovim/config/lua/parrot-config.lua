require("parrot").setup {
    providers = {
        anthropic = {
            api_key = os.getenv "ANTHROPIC_API_KEY"
        }
    },
    toggle_target = "split",
    -- Local chat buffer shortcuts
    chat_shortcut_respond = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g><C-g>" },
    chat_shortcut_delete = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>d" },
    chat_shortcut_stop = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>s" },
    chat_shortcut_new = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>c" },
    chat_confirm_delete = false,
}

local function keymapOptions(desc)
    return {
        noremap = true,
        silent = true,
        nowait = true,
        desc = "GPT prompt " .. desc,
    }
end

-- Chat commands
vim.keymap.set({ "n", "i" }, "<C-g>c", "<cmd>PrtChatNew split<cr>", keymapOptions("New Chat"))
vim.keymap.set({ "n", "i" }, "<C-g>t", "<cmd>PrtChatToggle<cr>", keymapOptions("Toggle Chat"))
vim.keymap.set({ "n", "i" }, "<C-g>f", "<cmd>PrtChatFinder<cr>", keymapOptions("Chat Finder"))
vim.keymap.set({ "n", "i" }, "<C-g>r", "<cmd>PrtRewrite<cr>", keymapOptions("Inline Rewrite"))
vim.keymap.set({ "n", "i" }, "<C-g>a", "<cmd>PrtAppend<cr>", keymapOptions("Append (after)"))
vim.keymap.set({ "n", "i" }, "<C-g>b", "<cmd>PrtPrepend<cr>", keymapOptions("Prepend (before)"))

vim.keymap.set("v", "<C-g>c", ":<C-u>'<,'>PrtChatNew<cr>", keymapOptions("Visual Chat New"))
vim.keymap.set("v", "<C-g>p", ":<C-u>'<,'>PrtChatPaste<cr>", keymapOptions("Visual Chat Paste"))
--vim.keymap.set("v", "<C-g>t", ":<C-u>'<,'>PrtChatToggle<cr>", keymapOptions("Visual Toggle Chat"))
vim.keymap.set("v", "<C-g>r", ":<C-u>'<,'>PrtRewrite<cr>", keymapOptions("Visual Rewrite"))
vim.keymap.set("v", "<C-g>a", ":<C-u>'<,'>PrtAppend<cr>", keymapOptions("Visual Append (after)"))
vim.keymap.set("v", "<C-g>b", ":<C-u>'<,'>PrtPrepend<cr>", keymapOptions("Visual Prepend (before)"))
vim.keymap.set("v", "<C-g>i", ":<C-u>'<,'>PrtImplement<cr>", keymapOptions("Implement selection"))

vim.keymap.set({ "n", "i" }, "<C-g>x", "<cmd>PrtContext<cr>", keymapOptions("Toggle Context"))

vim.keymap.set({ "n", "i", "v", "x" }, "<C-g>s", "<cmd>PrtStop<cr>", keymapOptions("Stop"))
