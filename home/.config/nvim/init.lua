-- options
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.autoread = true
vim.o.backup = false
vim.o.clipboard = "unnamedplus"
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.exrc = true
vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldmethod = "indent"
vim.o.hlsearch = true
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.mouse = "a"
vim.o.number = true
vim.o.numberwidth = 2
vim.o.scrolloff = 8
vim.o.secure = true
vim.o.shiftround = true
vim.o.shiftwidth = 2
vim.o.showmode = false
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.swapfile = false
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.undodir = os.getenv("HOME") .. "/.nvim/undodir"
vim.o.undofile = true
vim.o.updatetime = 1000
vim.o.wrap = false

vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

vim.diagnostic.config({
  severity_sort = true,
  float = { scope = "line", source = "if_many", border = "rounded" },
})

-- keymaps
local opts = { noremap = true, silent = true }

vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", opts)
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", opts)
vim.keymap.set("i", "<C-c>", "<Esc>", opts)

-- autocmd
vim.api.nvim_create_autocmd({ "TextYankPost" }, { callback = function() vim.highlight.on_yank() end })
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "FocusGained" }, {
  callback = function()
    if vim.bo.buftype == "" then vim.cmd("checktime") end
  end,
})

-- plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", lazyrepo, "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

---@type LazySpec
local plugins = {
  {
    "folke/tokyonight.nvim",
    opts = {
      dim_inactive = false,
      styles = { sidebars = "dark", floats = "dark" },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    version = "main",
    dependencies = { { "nvim-treesitter/nvim-treesitter-context", opts = { max_lines = 1 } } },
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local ts = require("nvim-treesitter")
          if vim.bo.buftype ~= "" then return end
          local lang = vim.treesitter.language.get_lang(args.match)
          if lang == nil then return end

          ts.install({ lang }):await(function()
            if pcall(vim.treesitter.start) then
              vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
              vim.wo.foldmethod = "expr"
              vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
          end)
        end,
      })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    lazy = false,
    opts = { current_line_blame_formatter = "\t• @<author>: <summary> (<author_time:%R>)" },
    keys = {
      { "]c", "<cmd>Gitsigns next_hunk<cr>", desc = "Next Change" },
      { "[c", "<cmd>Gitsigns prev_hunk<cr>", desc = "Prev Change" },
      { "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview Change" },
      { "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", desc = "Reset Change" },
      { "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle Blame" },
    },
  },
  {
    "NeogitOrg/neogit",
    dependencies = { "sindrets/diffview.nvim" },
    opts = { kind = "auto" },
    cmd = "Neogit",
    keys = { { "<leader>gg", "<cmd>Neogit<cr>", desc = "Git" } },
  },
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-mini/mini.icons", opts = {} },
    opts = { view_options = { show_hidden = true } },
    lazy = false,
    keys = {
      { "-", "<cmd>Oil<cr>", mode = { "n" }, desc = "Explore Files" },
    },
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-mini/mini.icons", opts = {} },
    opts = {
      keymap = {
        builtin = { true, ["<C-d>"] = "preview-page-down", ["<C-u>"] = "preview-page-up" },
        fzf = {
          true,
          ["ctrl-d"] = "preview-page-down",
          ["ctrl-u"] = "preview-page-up",
          ["ctrl-q"] = "select-all+accept",
        },
      },
    },
    keys = {
      { "<leader><leader>", "<cmd>FzfLua global<cr>", mode = { "n" }, desc = "Find" },
      { "<leader>ff", "<cmd>FzfLua live_grep_native<cr>", mode = { "n" }, desc = "Find in files" },
      { "<leader>ff", "<cmd>FzfLua grep_visual<cr>", mode = { "v" }, desc = "Find selection in files" },
      { "<leader>fw", "<cmd>FzfLua grep_cword<cr>", mode = { "n" }, desc = "Find word" },
      { "<leader>fu", "<cmd>FzfLua undotree<cr>", mode = { "n" }, desc = "Find in undotree" },
      { "<leader>fs", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", mode = { "n" }, desc = "Find workspace symbols" },
      { "<leader>fS", "<cmd>FzfLua lsp_document_symbols<cr>", mode = { "n" }, desc = "Find document symbols" },
      { "<c-p>", "<cmd>FzfLua keymaps<cr>", mode = { "n" }, desc = "Find keymaps" },
    },
  },
  {
    "mfussenegger/nvim-lint",
    config = function()
      local lint = require("lint")
      lint.linters_by_ft =
        vim.tbl_extend("force", lint.linters_by_ft, { go = { "golangcilint" }, sh = { "shellcheck" } })
      vim.api.nvim_create_autocmd(
        { "BufReadPost", "CursorHold", "BufWritePost" },
        { callback = function() lint.try_lint() end }
      )
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        go = { "golangci-lint" },
        nix = { "nixpkgs_fmt" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        sh = { "shfmt" },
        javascript = { "dprint", "prettierd", "prettier", stop_after_first = true },
        typescript = { "dprint", "prettierd", "prettier", stop_after_first = true },
      },
      format_on_save = function()
        if vim.g.disable_autoformat then return end
        return { timeout_ms = 500, lsp_format = "fallback" }
      end,
    },
  },
  { "mason-org/mason.nvim", opts = {} },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = { ensure_installed = { "gopls", "zls", "lua_ls", "rust_analyzer" } },
    dependencies = {
      {
        "neovim/nvim-lspconfig",
        dependencies = { { "b0o/schemastore.nvim" } },
        config = function()
          vim.lsp.config("*", { root_markers = { ".git" } })
          vim.lsp.config(
            "lua_ls",
            { root_markers = { ".git" }, settings = { Lua = { hint = { arrayIndex = "Disable" } } } }
          )
          vim.lsp.config("clangd", { init_options = { fallbackFlags = { "-I" .. vim.fn.getcwd() .. "/include" } } })
          vim.lsp.config("gopls", { settings = { gopls = { hints = { constantValues = true } } } })

          local schemastore = require("schemastore")
          vim.lsp.config(
            "jsonls",
            { settings = { json = { schemas = schemastore.json.schemas(), validate = { enable = true } } } }
          )
          vim.lsp.config(
            "yamlls",
            { settings = { yaml = { schemaStore = { enable = false }, schemas = schemastore.yaml.schemas() } } }
          )
        end,
      },
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    cmd = { "DapInstall", "DapUninstall" },
    opts = { automatic_installation = true },
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "leoluz/nvim-dap-go", opts = {} },
      { "igorlfs/nvim-dap-view", opts = { winbar = { controls = { enabled = true } } } },
      { "theHamsta/nvim-dap-virtual-text", opts = { virt_text_pos = "eol" } },
    },
    keys = function()
      local dap = require("dap")
      return {
        { "<leader>b", desc = "debug" },
        { "<leader>bb", dap.toggle_breakpoint, desc = "[b]reakpoint" },
        { "<leader>bc", dap.continue, desc = "[c]ontinue" },
        { "<leader>bR", dap.clear_breakpoints, desc = "[R]emove breakpoints" },
        { "<leader>bC", dap.run_to_cursor, desc = "Go to [C]ursor" },
        { "<leader>bk", dap.terminate, desc = "[k]ill session" },
      }
    end,
    config = function()
      local dap = require("dap")
      local ui = require("dap-view")
      dap.listeners.before.launch.ui = function() ui.open() end
      dap.listeners.after.event_terminated.ui = function() ui.show_view("repl") end
    end,
  },
  {
    "nvim-neotest/neotest",
    keys = function()
      local neotest = require("neotest")
      return {
        {
          "<leader>bt",
          function() neotest.run.run({ suite = false, strategy = "dap" }) end,
          desc = "debug nearest [t]est",
        },
        { "<leader>tt", function() neotest.run.run() end, desc = "nearest [t]est" },
        { "<leader>tl", function() neotest.run.run_last() end, desc = "[l]ast" },
        { "<leader>tK", function() neotest.run.stop() end, desc = "[k]ill" },
        { "<leader>ts", function() neotest.summary.toggle() end, desc = "[s]ummary" },
      }
    end,
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      {
        "fredrikaverpil/neotest-golang",
        ft = "go",
        version = "*",
        dependencies = { "leoluz/nvim-dap-go" },
        build = function() vim.system({ "go", "install", "gotest.tools/gotestsum@latest" }):wait() end,
        config = function()
          ---@diagnostic disable-next-line: missing-fields
          require("neotest").setup({ adapters = { require("neotest-golang")({}) } })
        end,
      },
    },
  },
  { "folke/lazydev.nvim", ft = { "lua" }, opts = {} },
  { "j-hui/fidget.nvim", opts = { notification = { override_vim_notify = true } } },
  {
    "Chaitanyabsprip/fastaction.nvim",
    opts = {
      register_ui_select = true,
      popup = { hide_cursor = true, highlight = { action = "NormalFloat" } },
      priority = {
        ---@diagnostic disable-next-line: missing-fields
        golang = { { pattern = "organize imports", key = "o" } },
      },
    },
  },
  {
    "stevearc/quicker.nvim",
    ft = { "qf" },
    opts = {},
    keys = { { "<leader>q", function() require("quicker").toggle() end, mode = { "n" }, desc = "QuickFix toggle" } },
  },
  { "folke/which-key.nvim", opts = { preset = "helix" } },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = { component_separators = { left = "", right = "" } },
      sections = { lualine_x = { { function() return require("dap").status() end } } },
    },
  },
  {
    "https://codeberg.org/andyg/leap.nvim.git",
    opts = {},
    keys = { { "s", "<Plug>(leap)", mode = { "n", "x", "o" } }, { "S", "<Plug>(leap-from-window)", mode = { "n" } } },
  },
  {
    "saghen/blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "rafamadriz/friendly-snippets" },
    version = "1.*",
    opts = {
      signature = { enabled = true },
      keymap = { preset = "default", ["<C-Tab>"] = { "show", "accept", "fallback" } },
      completion = { documentation = { auto_show = true } },
    },
    keys = { { "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", desc = "Go Definition" } },
  },
  { "Bekaboo/dropbar.nvim", opts = {} },
}

require("lazy").setup({
  spec = plugins,
  change_detection = { notify = false },
  checker = { enabled = true, notify = false },
  performance = {
    cache = { enabled = true },
    rtp = {
      disabled_plugins = {
        "gzip",
        "rplugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        -- "matchit",
        -- "matchparen",
        "netrwPlugin",
      },
    },
  },
})

vim.cmd("colorscheme tokyonight-night")

local lsp_inlay_hints_enabled = { gopls = true }
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client.root_dir then vim.cmd("lcd " .. client.root_dir) end

    client.server_capabilities.semanticTokensProvider = nil
    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(lsp_inlay_hints_enabled[client.name] or false, { bufnr = args.buf })
    end
  end,
})

vim.api.nvim_create_user_command("FormatToggle", function()
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  print("Conform: format on save " .. (vim.g.disable_autoformat and "disabled" or "enabled"))
end, { desc = "Toggle global autoformat-on-save" })
