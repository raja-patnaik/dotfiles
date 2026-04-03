return {
  "jpalardy/vim-slime",
  ft = { "python", "lua", "ruby", "javascript", "typescript", "sh" },
  init = function()
    vim.g.slime_target = "tmux"
    vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }
    vim.g.slime_dont_ask_default = 1
    vim.g.slime_bracketed_paste = 1
  end,
  keys = {
    { "<leader>js", "<Plug>SlimeMotionSend", desc = "Send motion to REPL" },
    { "<leader>jl", "<Plug>SlimeLineSend", desc = "Send line to REPL" },
    { "<leader>js", "<Plug>SlimeRegionSend", mode = "v", desc = "Send selection to REPL" },
    { "<leader>jc", "<Plug>SlimeConfig", desc = "Configure REPL target" },
  },
}
