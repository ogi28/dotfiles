--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]
-- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT

-- general
lvim.log.level = "warn"
lvim.format_on_save = false
-- lvim.colorscheme = "onedarker"
lvim.colorscheme = "nordfox"
lvim.line_wrap_cursor_movement = false -- fuck this who likes this
vim.opt.whichwrap = "" --Top command doesn't work
-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
-- unmap a default keymapping
-- vim.keymap.del("n", "<C-Up>")
-- override a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>" -- or vim.keymap.set("n", "<C-q>", ":q<cr>" )

-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
-- local _, actions = pcall(require, "telescope.actions")
-- lvim.builtin.telescope.defaults.mappings = {
--   -- for input mode
--   i = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--     ["<C-n>"] = actions.cycle_history_next,
--     ["<C-p>"] = actions.cycle_history_prev,
--   },
--   -- for normal mode
--   n = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--   },
-- }

-- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
-- lvim.builtin.which_key.mappings["t"] = {
--   name = "+Trouble",
--   r = { "<cmd>Trouble lsp_references<cr>", "References" },
--   f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
--   d = { "<cmd>Trouble document_diagnostics<cr>", "Diagnostics" },
--   q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
--   l = { "<cmd>Trouble loclist<cr>", "LocationList" },
--   w = { "<cmd>Trouble workspace_diagnostics<cr>", "Wordspace Diagnostics" },
-- }

lvim.builtin.which_key.mappings["z"] = {
  name = "+Zen",
  t = { "<cmd>Twilight<CR>", "Twilight" },
  z = { "<cmd>ZenMode<CR>", "Zen" },
}

-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
lvim.builtin.which_key.mappings["n"] = { "<cmd>set rnu!<CR>", "RelativeNumber" }
lvim.builtin.lualine.style           = "default"
lvim.builtin.lualine.sections        = {
  lualine_a = { 'hostname' },
  lualine_b = { 'branch', 'diff' },
  lualine_c = { 'filename', 'diagnostics' },
  lualine_x = { 'filetype' },
  lualine_y = { 'fileformat' },
  lualine_z = { 'location' }
}




-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "java",
  "yaml",
}

-- lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

-- generic LSP settings

-- -- make sure server will always be installed even if the server is in skipped_servers list
-- lvim.lsp.installer.setup.ensure_installed = {
--     "sumeko_lua",
--     "jsonls",
-- }
-- -- change UI setting of `LspInstallInfo`
-- -- see <https://github.com/williamboman/nvim-lsp-installer#default-configuration>
-- lvim.lsp.installer.setup.ui.check_outdated_servers_on_open = false
-- lvim.lsp.installer.setup.ui.border = "rounded"
-- lvim.lsp.installer.setup.ui.keymaps = {
--     uninstall_server = "d",
--     toggle_server_expand = "o",
-- }

-- ---@usage disable automatic installation of servers
-- lvim.lsp.automatic_servers_installation = false

-- ---configure a server manually. !!Requires `:LvimCacheReset` to take effect!!
-- ---see the full default list `:lua print(vim.inspect(lvim.lsp.automatic_configuration.skipped_servers))`
-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pyright", opts)

-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. !!Requires `:LvimCacheReset` to take effect!!
-- ---`:LvimInfo` lists which server(s) are skipped for the current filetype
-- vim.tbl_map(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

-- -- set a formatter, this will override the language server formatting capabilities (if it exists)
-- local formatters = require "lvim.lsp.null-ls.formatters"
-- formatters.setup {
--   { command = "black", filetypes = { "python" } },
--   { command = "isort", filetypes = { "python" } },
--   {
--     -- each formatter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
--     command = "prettier",
--     ---@usage arguments to pass to the formatter
--     -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
--     extra_args = { "--print-with", "100" },
--     ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
--     filetypes = { "typescript", "typescriptreact" },
--   },
-- }

-- -- set additional linters
-- local linters = require "lvim.lsp.null-ls.linters"
-- linters.setup {
--   { command = "flake8", filetypes = { "python" } },
--   {
--     -- each linter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
--     command = "shellcheck",
--     ---@usage arguments to pass to the formatter
--     -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
--     extra_args = { "--severity", "warning" },
--   },
--   {
--     command = "codespell",
--     ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
--     filetypes = { "javascript", "python" },
--   },
-- }

-- Additional Plugins
lvim.plugins = {
  --     {"folke/tokyonight.nvim"},
  --     {
  --       "folke/trouble.nvim",
  --       cmd = "TroubleToggle",
  --     },
  { 'andweeb/presence.nvim' },
  { 'ray-x/lsp_signature.nvim' },
  { 'folke/zen-mode.nvim' },
  { 'folke/twilight.nvim' },
  { 'github/copilot.vim' },
  { 'norcalli/nvim-colorizer.lua' },
  -- --These are themes
  -- {'marko-cerovac/material.nvim'},
  -- {'yashguptaz/calvera-dark.nvim'},
  -- {'tomasiser/vim-code-dark'}
  { 'EdenEast/nightfox.nvim' },
  { 'sainnhe/gruvbox-material' },
  -- { 'jinh0/eyeliner.nvim' },
  -- {'David-Kunz/jester'},
}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = { "*.json", "*.jsonc" },
--   -- enable wrap mode for json files only
--   command = "setlocal wrap",
-- })
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "zsh",
--   callback = function()
--     -- let treesitter use bash highlight for zsh files as well
--     require("nvim-treesitter.highlight").attach(0, "bash")
--   end,
-- })

-- XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX

-- lvim.builtin.dashboard.custom_header = "Hello"

lvim.builtin.alpha.dashboard.section.header.val = {}
--                       :::!~!!!!!:.
--                   .xUHWH!! !!?M88WHX:.
--                 .X*#M@$!!  !X!M$$$$$$WWx:.
--                :!!!!!!?H! :!$!$$$$$$$$$$8X:
--               !!~  ~:~!! :~!$!#$$$$$$$$$$8X:
--              :!~::!H!<   ~.U$X!?R$$$$$$$$MM!
--              ~!~!!!!~~ .:XW$$$U!!?$$$$$$RMM!
--                !:~~~ .:!M"T#$$$$WX??#MRRMMM!
--                ~?WuxiW*`   `"#$$$$8!!!!??!!!
--              :X- M$$$$       `"T#$T~!8$WUXU~
--             :%`  ~#$$$m:        ~!~ ?$$$$$$
--           :!`.-   ~T$$$$8xx.  .xWW- ~""##*"
-- .....   -~~:<` !    ~?T#$$@@W@*?$$      /`
-- W$@@M!!! .!~~ !!     .:XUW$W!~ `"~:    :
-- #"~~`.:x%`!!  !H:   !WM$$$$Ti.: .!WUn+!`
-- :::~:!!`:X~ .: ?H.!u "$$$B$$$!W:U!T$$M~
-- .~~   :X@!.-~   ?@WTWo("*$$$W$TH$! `
-- Wi.~!X$?!-~    : ?$$$B$Wu("**$RM!
-- $R@i.~~ !     :   ~$$$$$B$$en:``
-- ?MXT@Wx.~    :     ~"##*$$$$M~

lvim.builtin.alpha.dashboard.section.header.val[1] = "                       :::!~!!!!!:."
lvim.builtin.alpha.dashboard.section.header.val[2] = "                   .xUHWH!! !!?M88WHX:."
lvim.builtin.alpha.dashboard.section.header.val[3] = "                 .X*#M@$!!  !X!M$$$$$$WWx:."
lvim.builtin.alpha.dashboard.section.header.val[4] = "                :!!!!!!?H! :!$!$$$$$$$$$$8X:"
lvim.builtin.alpha.dashboard.section.header.val[5] = "               !!~  ~:~!! :~!$!#$$$$$$$$$$8X:"
lvim.builtin.alpha.dashboard.section.header.val[6] = "              :!~::!H!<   ~.U$X!?R$$$$$$$$MM!"
lvim.builtin.alpha.dashboard.section.header.val[7] = "              ~!~!!!!~~ .:XW$$$U!!?$$$$$$RMM!"
lvim.builtin.alpha.dashboard.section.header.val[8] = "                !:~~~ .:!M\"T#$$$$WX??#MRRMMM!"
lvim.builtin.alpha.dashboard.section.header.val[9] = "                ~?WuxiW*`   `\"#$$$$8!!!!??!!!"
lvim.builtin.alpha.dashboard.section.header.val[10] = "              :X- M$$$$       `\"T#$T~!8$WUXU~"
lvim.builtin.alpha.dashboard.section.header.val[11] = "             :%`  ~#$$$m:        ~!~ ?$$$$$$"
lvim.builtin.alpha.dashboard.section.header.val[12] = "           :!`.-   ~T$$$$8xx.  .xWW- ~\"\"##*\""
lvim.builtin.alpha.dashboard.section.header.val[13] = ".....   -~~:<` !    ~?T#$$@@W@*?$$      /`"
lvim.builtin.alpha.dashboard.section.header.val[14] = " W$@@M!!! .!~~ !!     .:XUW$W!~ `\"~:    :"
lvim.builtin.alpha.dashboard.section.header.val[15] = " #\"~~`.:x%`!!  !H:   !WM$$$$Ti.: .!WUn+!`"
lvim.builtin.alpha.dashboard.section.header.val[16] = " :::~:!!`:X~ .: ?H.!u \"$$$B$$$!W:U!T$$M~"
lvim.builtin.alpha.dashboard.section.header.val[17] = " .~~   :X@!.-~   ?@WTWo(\"*$$$W$TH$! `"
lvim.builtin.alpha.dashboard.section.header.val[18] = " Wi.~!X$?!-~    : ?$$$B$Wu(\"**$RM!"
lvim.builtin.alpha.dashboard.section.header.val[19] = " $R@i.~~ !     :   ~$$$$$B$$en:``"
lvim.builtin.alpha.dashboard.section.header.val[20] = " ?MXT@Wx.~    :     ~\"##*$$$$M~"
lvim.builtin.alpha.dashboard.section.header.val[21] = ""
lvim.builtin.alpha.dashboard.section.header.val[22] = ""
-- lvim.builtin.alpha.dashboard.section.header.val[23] = ""
lvim.builtin.alpha.dashboard.section.header.val[23] = "Always code as if the guy who ends up maintaining your code"
lvim.builtin.alpha.dashboard.section.header.val[24] = "will be a violent psychopath who knows where you live!"

lvim.builtin.alpha.dashboard.section.footer.val = "Let the shenanigans begin"
-- lvim.builtin.alpha.dashboard.section.footer.val = "will be a violent psychopath who knows where you live!"
--- XXX keybinds
lvim.keys.normal_mode["<S-h>"] = ":bprevious<CR>"
lvim.keys.normal_mode["<S-l>"] = ":bnext<CR>"

-- XXX Gruvbox settings
vim.g.gruvbox_material_palette = "original"
vim.g.gruvbox_material_background = "hard"
vim.g.gruvbox_material_enable_bold = 1
-- vim.g.gruvbox_material_diagnostic_text_highlight = 1
-- vim.g.gruvbox_material_diagnostic_line_highlight = 1
vim.g.gruvbox_material_diagnostic_virtual_text = 'colored'

-- XXX Rich Presence Settings
require("presence"):setup({
  neovim_image_text = "Behold The Superior Text Editing Experience",
  -- neovim_image_text = "The CRUD Text Editor",
  -- main_image = "file",
  -- enable_line_number = true,
})

-- XXX ZenMode settings
require("zen-mode").setup {
  window = {
    height = 0.80,
    options = {
      number = true,
      relativenumber = true
    },
  },
}

-- XXX signature functions settings
require "lsp_signature".setup({
  bind = true,
  handler_opts = {
    border = "single"
  },
  hint_prefix = " ",
  -- hint_prefix = "B==D ",
})

-- XXX Colorizer settings
require 'colorizer'.setup()

-- XXX github copilot settings
vim.g.copilot_no_tab_map = true;
vim.g.copilot_assume_mapped = true;
vim.api.nvim_set_keymap("i", "<S-Right>", 'copilot#Accept("")', { expr = true, silent = true })

--- XXX nightfox settings

local options = {
  styles = {
    comments = "italic",
    conditionals = "italic",
    constants = "NONE",
    -- types = "strikethrough",
    functions = "italic",
    variables = "bold",
    keywords = "italic,bold"
  }
}
require('nightfox').setup({
  options = options,
  palettes = {
    nightfox = {
      bg0 = "#252626",
      -- bg0 = "#000000"
      bg1 = "#2a2b2b"
    },
    nordfox = {
      bg1 = "#2e3440"
      -- bg1= "#3b4252"
    }
  }
})

