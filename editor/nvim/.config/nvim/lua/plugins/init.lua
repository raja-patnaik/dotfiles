-- Custom plugins configuration
return {
  -- Override default LazyVim plugins
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      transparent = false,
      styles = {
        sidebars = "dark",
        floats = "dark",
      },
    },
  },

  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
    },
  },

  -- Better terminal integration
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = true,
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Toggle float terminal" },
      { "<leader>th", "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc = "Toggle horizontal terminal" },
      { "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "Toggle vertical terminal" },
    },
  },

  -- File explorer enhancements
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    },
  },

  -- Improved surround
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = true,
  },

  -- Session management
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
      options = { "buffers", "curdir", "tabpages", "winsize" },
    },
    keys = {
      { "<leader>ps", function() require("persistence").load() end, desc = "Restore session" },
      { "<leader>pl", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>pd", function() require("persistence").stop() end, desc = "Stop persistence" },
    },
  },

  -- Better quickfix
  {
    "folke/trouble.nvim",
    opts = {
      use_diagnostic_signs = true,
    },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle<cr>", desc = "Toggle trouble" },
      { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace diagnostics" },
      { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document diagnostics" },
      { "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix" },
      { "<leader>xl", "<cmd>TroubleToggle loclist<cr>", desc = "Location list" },
    },
  },

  -- Copilot (using copilot.lua for LSP support needed by Sidekick)
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-J>",
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        ["*"] = true,
        ["TelescopePrompt"] = false,
      },
    },
  },

  -- Copilot completion source for nvim-cmp
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" },
    },
  },

  -- Debugging
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
    },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Step Into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
    },
  },

  -- tmux integration
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },

  -- Snacks.nvim - Utility collection by folke (required for Sidekick)
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
  },

  -- Tree-sitter textobjects for better code navigation
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "VeryLazy",
  },

  -- Configure treesitter with textobjects
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "bash", "c", "cpp", "css", "dockerfile", "go", "html",
          "javascript", "json", "lua", "markdown", "markdown_inline",
          "python", "query", "regex", "rust", "tsx", "typescript", "vim", "yaml",
        })
      end

      opts.textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = "@class.outer",
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
          },
        },
      }
      return opts
    end,
  },

  -- Sidekick.nvim - AI assistant with Next Edit Suggestions and CLI terminal
  -- {
  --   "folke/sidekick.nvim",
  --   dependencies = {
  --     "zbirenbaum/copilot.lua",
  --     "folke/snacks.nvim",
  --     "nvim-treesitter/nvim-treesitter-textobjects",
  --   },
  --   event = "VeryLazy",
  --   opts = {
  --     -- Next Edit Suggestions configuration
  --     nes = {
  --       enabled = true,
  --       auto_trigger = true,
  --     },
  --     -- AI CLI terminal configuration
  --     cli = {
  --       enabled = true,
  --       tools = {
  --         claude = {
  --           cmd = { "claude" },
  --           prompt = "You are a helpful AI assistant.",
  --         },
  --       },
  --     },
  --   },
  --   keys = {
  --     { "<leader>sa", "<cmd>lua require('sidekick').toggle()<cr>", desc = "Toggle Sidekick suggestions" },
  --     { "<leader>st", "<cmd>lua require('sidekick').terminal()<cr>", desc = "Open Sidekick AI terminal" },
  --     { "<leader>sc", "<cmd>lua require('sidekick').clear()<cr>", desc = "Clear Sidekick suggestions" },
  --     { "]s", "<cmd>lua require('sidekick').next_hunk()<cr>", desc = "Next suggestion hunk" },
  --     { "[s", "<cmd>lua require('sidekick').prev_hunk()<cr>", desc = "Previous suggestion hunk" },
  --     { "<leader>sy", "<cmd>lua require('sidekick').accept()<cr>", desc = "Accept Sidekick suggestion" },
  --     { "<leader>sn", "<cmd>lua require('sidekick').reject()<cr>", desc = "Reject Sidekick suggestion" },
  --   },
  -- },
  
  {
    "folke/sidekick.nvim",
    opts = {
      -- add any options here
      cli = {
        mux = {
          -- backend = "zellij",
          enabled = false,
        },
      },
    },
    -- stylua: ignore
    keys = {
      {
        "<tab>",
        function()
          -- if there is a next edit, jump to it, otherwise apply it if any
          if not require("sidekick").nes_jump_or_apply() then
            return "<Tab>" -- fallback to normal tab
          end
        end,
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<leader>aa",
        function() require("sidekick.cli").toggle() end,
        desc = "Sidekick Toggle CLI",
      },
      {
        "<leader>as",
        function() require("sidekick.cli").select() end,
        -- Or to select only installed tools:
        -- require("sidekick.cli").select({ filter = { installed = true } })
        desc = "Select CLI",
      },
      {
        "<leader>at",
        function() require("sidekick.cli").send({ msg = "{this}" }) end,
        mode = { "x", "n" },
        desc = "Send This",
      },
      {
        "<leader>av",
        function() require("sidekick.cli").send({ msg = "{selection}" }) end,
        mode = { "x" },
        desc = "Send Visual Selection",
      },
      {
        "<leader>ap",
        function() require("sidekick.cli").prompt() end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
      {
        "<c-.>",
        function() require("sidekick.cli").focus() end,
        mode = { "n", "x", "i", "t" },
        desc = "Sidekick Switch Focus",
      },
      -- Example of a keybinding to open Claude directly
      {
        "<leader>ac",
        function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end,
        desc = "Sidekick Toggle Claude",
      },
    },
  }
}