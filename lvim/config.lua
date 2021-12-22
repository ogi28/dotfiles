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
lvim.colorscheme = "gruvbox-material"
lvim.line_wrap_cursor_movement = false
lvim.builtin.nvimtree.hide_dotfiles = 0



-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
-- unmap a default keymapping
-- lvim.keys.normal_mode["<C-Up>"] = ""
-- edit a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>"

-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- lvim.builtin.telescope.on_config_done = function()
--   local actions = require "telescope.actions"
--   -- for input mode
--   lvim.builtin.telescope.defaults.mappings.i["<C-j>"] = actions.move_selection_next
--   lvim.builtin.telescope.defaults.mappings.i["<C-k>"] = actions.move_selection_previous
--   lvim.builtin.telescope.defaults.mappings.i["<C-n>"] = actions.cycle_history_next
--   lvim.builtin.telescope.defaults.mappings.i["<C-p>"] = actions.cycle_history_prev
--   -- for normal mode
--   lvim.builtin.telescope.defaults.mappings.n["<C-j>"] = actions.move_selection_next
--   lvim.builtin.telescope.defaults.mappings.n["<C-k>"] = actions.move_selection_previous
-- end

-- Use which-key to add extra bindings with the leader-key prefix
lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
-- lvim.builtin.which_key.mappings["t"] = {
--   name = "+Trouble",
--   r = { "<cmd>Trouble lsp_references<cr>", "References" },
--   f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
--   d = { "<cmd>Trouble lsp_document_diagnostics<cr>", "Diagnostics" },
--   q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
--   l = { "<cmd>Trouble loclist<cr>", "LocationList" },
--   w = { "<cmd>Trouble lsp_workspace_diagnostics<cr>", "Diagnostics" },
-- }

lvim.builtin.which_key.mappings["z"] = {
  name = "+Zen",
  t = {"<cmd>Twilight<CR>", "Twilight"},
  z = {"<cmd>ZenMode<CR>", "Zen"},
}


-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.dashboard.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.show_icons.git = 0
lvim.builtin.autopairs.active = true

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = "maintained"
lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

-- generic LSP settings
-- you can set a custom on_attach function that will be used for all the language servers
-- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end
-- you can overwrite the null_ls setup table (useful for setting the root_dir function)
-- lvim.lsp.null_ls.setup = {
--   root_dir = require("lspconfig").util.root_pattern("Makefile", ".git", "node_modules"),
-- }
-- or if you need something more advanced
-- lvim.lsp.null_ls.setup.root_dir = function(fname)
--   if vim.bo.filetype == "javascript" then
--     return require("lspconfig/util").root_pattern("Makefile", ".git", "node_modules")(fname)
--       or require("lspconfig/util").path.dirname(fname)
--   elseif vim.bo.filetype == "php" then
--     return require("lspconfig/util").root_pattern("Makefile", ".git", "composer.json")(fname) or vim.fn.getcwd()
--   else
--     return require("lspconfig/util").root_pattern("Makefile", ".git")(fname) or require("lspconfig/util").path.dirname(fname)
--   end
-- end

-- set a formatter if you want to override the default lsp one (if it exists)
-- lvim.lang.python.formatters = {
--   {
--     exe = "black",
--   }
-- }
-- set an additional linter
-- lvim.lang.python.linters = {
--   {
--     exe = "flake8",
--   }
-- }

-- Additional Plugins
lvim.plugins = {
    --{"folke/tokyonight.nvim"},
    -- {
    --   "folke/trouble.nvim",
    --   cmd = "TroubleToggle",
    -- },
  {'yashguptaz/calvera-dark.nvim'},
  {'marko-cerovac/material.nvim'},
  {'andweeb/presence.nvim'},
  {'norcalli/nvim-colorizer.lua'},
  {'ray-x/lsp_signature.nvim'},
  {'folke/twilight.nvim'},
  {'folke/zen-mode.nvim'},
  {'sainnhe/gruvbox-material'},
  {'github/copilot.vim'}
}


-- Autocommands (https://neovim.io/doc/user/autocmd.html)
lvim.autocommands.custom_groups = {
--   { "BufWinEnter", "*.lua", "setlocal ts=8 sw=8" },
  { "BufWinEnter", "*", ":PackerLoad nvim-autopairs" },
}



--MY CONFIGS
--STARTS HERE
--ABANDON ALL HOPE
--YE WHO ENTER HERE


--Gruvbox settings
vim.g.gruvbox_material_palette = "original"
vim.g.gruvbox_material_background = "hard"
vim.g.gruvbox_material_enable_bold = 1
-- vim.g.gruvbox_material_diagnostic_text_highlight = 1
-- vim.g.gruvbox_material_diagnostic_line_highlight = 1
vim.g.gruvbox_material_diagnostic_virtual_text = 'colored'

--Rich Presence Settings
require("presence"):setup({
  neovim_image_text = "Behold The Superior Text Editing Experience",
  main_image = "file",
  -- enable_line_number = true,
})

-- Twilight settings
-- require("twilight").setup{}

-- ZenMode settings
require("zen-mode").setup{
  window = {
    height = 0.80,
    options = {
      number = true,
      relativenumber = true
    },
  },
}


--signature functions settings
require "lsp_signature".setup({
  bind = true,
  handler_opts ={
    border = "single"
  },
  hint_prefix = " ",
   -- hint_prefix = "B==D ",
})


--Colorizer settings
require'colorizer'.setup()

--github copilot settings
vim.g.copilot_no_tab_map = true;
vim.g.copilot_assume_mapped = true;
vim.api.nvim_set_keymap("i", "<Right>", 'copilot#Accept("")', {expr = true, silent = true})



-- Material settings
-- vim.g.material_style = "darker"
-- vim.g.material_style = "palenight"
-- vim.g.material_style = "deep ocean"

-- local myYellow ="#fff263"
-- local myGold = "#FCF9C2";
-- local myBlue = "#82AAFF"
-- local myPurple ="#C792EA"
-- local myRed = "#F07178"
-- -- local myPaleBlue = "#B0C9FF"

-- require('material').setup({

--   borders = true,
--   italics ={
--     comments = true,
--     keywords = true,
--   },
--   text_contrast = {
--     darker = true
--   },
--   material_borders = true,
--   custom_colors = {
--    paleblue = myYellow,
--    purple = myBlue,
--    blue = myPurple,
--    yellow = myRed,
--   -- cyan = myPaleBlue,
--    -- gray = "myRed",
--    variable = myGold
--   },
--  })
-- 	-- Common colors

-- -- 	white    =		'#EEFFFF',
-- -- 	gray     =      '#717CB4',
-- -- 	black    = 		'#000000',
-- -- 	red      =   	'#F07178',
-- -- 	green    = 		'#C3E88D',
-- -- 	yellow   =		'#FFCB6B',
-- -- 	blue     =  	'#82AAFF',
-- -- 	paleblue =		'#B0C9FF',
-- -- 	cyan     =  	'#89DDFF',
-- -- 	purple   =		'#C792EA',
-- -- 	orange   =		'#F78C6C',
-- -- 	pink     =  	'#FF9CAC',

-- -- 	-- Dark colors
-- -- 	darkred =		'#dc6068',
-- -- 	darkgreen =		'#abcf76',
-- -- 	darkyellow =	'#e6b455',
-- -- 	darkblue =		'#6e98eb',
-- -- 	darkcyan =		'#71c6e7',
-- -- 	darkpurple =	'#b480d6',
-- -- 	darkorange =	'#e2795b',

-- -- 	error    =		'#FF5370',
-- -- 	link     =		'#80CBC4',
-- -- 	cursor   =		'#FFCC00',
-- -- 	variable =		'#717CB4',

-- -- 	none     =      'NONE'




