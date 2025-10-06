return {
  {
    "Vigemus/iron.nvim",
    config = function()
      local iron = require("iron.core")

      iron.setup({
        config = {
          -- Define which REPL to use
          repl_definition = {
            command = { "uv", "run", "ipython", "--no-autoindent" },
          },
          -- Open the REPL on the right side like VS Code
          repl_open_cmd = "vsplit | wincmd l",
        },
        keymaps = {
          send_motion = "<leader>js", -- send motion or visual selection
          visual_send = "<leader>js",
          send_line = "<leader>jl",   -- send current line
          send_file = "<leader>jf",   -- send entire file
          cr = "<leader>jr",          -- send current line and move cursor down
          interrupt = "<leader>ji",   -- interrupt kernel
          exit = "<leader>jq",        -- quit REPL
          clear = "<leader>jc",       -- clear REPL
        },
        highlight = { italic = true },
      })

      -- Optional: automatically start REPL when opening a Python file
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function()
          vim.keymap.set("n", "<leader>ir", "<cmd>IronRepl<cr>", { desc = "Open REPL" })
        end,
      })
    end,
  },
}