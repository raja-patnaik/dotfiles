-- Neovim options configuration
local opt = vim.opt

-- General settings
opt.autowrite = true          -- Enable auto write
-- Clipboard: OSC52 over SSH/tmux, system clipboard otherwise
if vim.env.SSH_TTY or vim.env.TMUX then
  vim.g.clipboard = "osc52"
elseif vim.fn.has("mac") == 1 then
  opt.clipboard = "unnamedplus"
elseif vim.fn.executable("wl-copy") == 1 and vim.fn.executable("wl-paste") == 1 then
  vim.g.clipboard = "wayclip"
elseif vim.fn.executable("xclip") == 1 or vim.fn.executable("xsel") == 1 then
  opt.clipboard = "unnamedplus"
end
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 3          -- Hide * markup for bold and italic
opt.confirm = true            -- Confirm to save changes before exiting modified buffer
opt.cursorline = true         -- Enable highlighting of the current line
opt.expandtab = true          -- Use spaces instead of tabs
opt.formatoptions = "jcroqlnt"
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true         -- Ignore case
opt.inccommand = "nosplit"    -- Preview incremental substitute
opt.laststatus = 3            -- Global statusline
opt.list = true               -- Show some invisible characters (tabs...
opt.mouse = "a"               -- Enable mouse mode
opt.number = true             -- Print line number
opt.pumblend = 10             -- Popup blend
opt.pumheight = 10            -- Maximum number of entries in a popup
opt.relativenumber = true     -- Relative line numbers
opt.scrolloff = 4             -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
opt.shiftround = true         -- Round indent
opt.shiftwidth = 2            -- Size of an indent
opt.shortmess:append({ W = true, I = true, c = true })
opt.showmode = false          -- Dont show mode since we have a statusline
opt.sidescrolloff = 8         -- Columns of context
opt.signcolumn = "yes"        -- Always show the signcolumn
opt.smartcase = true          -- Don't ignore case with capitals
opt.smartindent = true        -- Insert indents automatically
opt.spelllang = { "en" }
opt.splitbelow = true         -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true         -- Put new windows right of current
opt.tabstop = 2               -- Number of spaces tabs count for
opt.termguicolors = true      -- True color support
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200          -- Save swap file and trigger CursorHold
opt.wildmode = "longest:full,full"
opt.winminwidth = 5           -- Minimum window width
opt.wrap = false              -- Disable line wrap

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

-- Disable UI animations like smooth scrolling
vim.g.snacks_animate = false

-- Set fillchars
opt.fillchars = {
  foldopen = "▾",
  foldclose = "▸",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

-- Set list chars
opt.listchars = {
  tab = "→ ",
  trail = "·",
  nbsp = "␣",
  extends = "❯",
  precedes = "❮",
}

-- Folding
opt.foldlevel = 99
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"

-- Tree-sitter: compile parsers with system compiler (avoids glibc issues with npm tree-sitter-cli)
require("nvim-treesitter.install").compilers = { "gcc", "clang", "cc" }

-- Python provider
vim.g.python3_host_prog = vim.fn.exepath("python3")

-- Disable providers we don't use
vim.g.loaded_python_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- File type specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml", "yml" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})