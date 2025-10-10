-- Keymaps configuration
local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Insert mode: jj to escape
keymap.set("i", "jj", "<Esc>", opts)

-- Better window navigation
keymap.set("n", "<C-h>", "<C-w>h", opts)
keymap.set("n", "<C-j>", "<C-w>j", opts)
keymap.set("n", "<C-k>", "<C-w>k", opts)
keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Resize windows with arrows
keymap.set("n", "<C-Up>", ":resize +2<CR>", opts)
keymap.set("n", "<C-Down>", ":resize -2<CR>", opts)
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap.set("n", "<S-l>", ":bnext<CR>", opts)
keymap.set("n", "<S-h>", ":bprevious<CR>", opts)

-- Move text up and down
keymap.set("n", "<A-j>", ":m .+1<CR>==", opts)
keymap.set("n", "<A-k>", ":m .-2<CR>==", opts)

-- Visual mode: Stay in indent mode
keymap.set("v", "<", "<gv", opts)
keymap.set("v", ">", ">gv", opts)

-- Visual mode: Move text up and down
keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)
keymap.set("v", "p", '"_dP', opts)

-- Visual Block mode: Move text up and down
keymap.set("x", "J", ":m '>+1<CR>gv=gv", opts)
keymap.set("x", "K", ":m '<-2<CR>gv=gv", opts)
keymap.set("x", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap.set("x", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- Better paste
keymap.set("v", "p", '"_dP', opts)

-- Clear search highlighting
keymap.set("n", "<Esc>", ":nohlsearch<CR>", opts)

-- Save file
keymap.set("n", "<C-s>", ":w<CR>", opts)
keymap.set("i", "<C-s>", "<Esc>:w<CR>a", opts)

-- Quit
keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
keymap.set("n", "<leader>Q", ":qa<CR>", { desc = "Quit all" })

-- Split windows
keymap.set("n", "<leader>|", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>-", "<C-w>s", { desc = "Split window horizontally" })

-- Terminal
keymap.set("n", "<leader>t", ":terminal<CR>", { desc = "Open terminal" })
keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Toggle relative line numbers
keymap.set("n", "<leader>ln", ":set relativenumber!<CR>", { desc = "Toggle relative line numbers" })