local augroup = vim.api.nvim_create_augroup('vimrc', { clear = true })
local api = vim.api
local fn = vim.fn

-----------------------------------------------------------------------
-- Plugin manager
-----------------------------------------------------------------------

local ensure_packer = function()
  local packer_path = '/site/pack/packer/start/packer.nvim'
  local install_path = fn.stdpath('data') .. packer_path

  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({
      'git', 'clone', '--depth', '1',
      'https://github.com/wbthomason/packer.nvim',
      install_path
    })
    vim.cmd [[
      packadd packer.nvim
    ]]

    return true
  end

  return false
end

local packer_bootstrap = ensure_packer()
local packer = require('packer')

packer.startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'cvlmtg/vim-256noir'

  use 'michaeljsmith/vim-indent-object'
  use 'junegunn/vim-easy-align'
  use 'tpope/vim-commentary'
  use 'tpope/vim-surround'
  use 'wellle/targets.vim'
  use 'tpope/vim-repeat'
  use 'mbbill/undotree'

  use 'HerringtonDarkholme/yats.vim'
  use 'MaxMEllon/vim-jsx-pretty'
  use 'pangloss/vim-javascript'
  use 'groenewege/vim-less'
  use 'ap/vim-css-color'
  use 'dag/vim-fish'

  use {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end
  }

  -- LSP Support
  use {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'neovim/nvim-lspconfig',
  }

  -- Autocompletion
  use {'hrsh7th/nvim-cmp'}
  use {'hrsh7th/cmp-path'}
  use {'hrsh7th/cmp-buffer'}
  use {'hrsh7th/cmp-nvim-lsp'}
  use {'hrsh7th/cmp-nvim-lua'}

  -- Automatically set up your configuration after cloning
  -- packer.nvim. Put this at the end after all plugins
  if packer_bootstrap then
    packer.sync()
  end
end)

-----------------------------------------------------------------------
-- Configuration
-----------------------------------------------------------------------

vim.opt.sessionoptions = {'curdir', 'folds', 'tabpages'}
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}
vim.opt.clipboard:append('unnamedplus')
vim.opt.foldmethod = 'syntax'
vim.opt.modeline = false
vim.opt.swapfile = false
vim.opt.autoread = false
vim.opt.hidden = true
vim.opt.mouse = 'nicr'

vim.opt.undodir = fn.expand('~/.cache/vim_undo')
vim.opt.undofile = true

vim.opt.joinspaces = false
vim.opt.smartcase = true
vim.opt.expandtab = true
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.scrolljump = 5
vim.opt.scrolloff = 5

-- show tabs and trailing spaces
-- ctrl-k >> to insert »
-- ctrl-k .M to insert ·

vim.opt.listchars = {
  tab = '»·',
  trail = '·',
  nbsp = '·'
}
vim.opt.list = true

vim.opt.inccommand = 'nosplit'
vim.opt.signcolumn = 'yes'
vim.opt.showmatch = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.laststatus = 2
vim.cmd [[
  colorscheme 256_noir
]]

vim.cmd [[
  abbreviate lenght length
  abbreviate heigth height

  " common mistakes in command line
  cabbrev rg Rg
  cabbrev Wq wq
  cabbrev Wa wa
  cabbrev Qa qa
  cabbrev W w
  cabbrev Q q
  cabbrev E e
  cabbrev R r
]]

vim.g.mapleader = '<Space>'

-----------------------------------------------------------------------
-- LSP
-----------------------------------------------------------------------

local lsp = require('cmp_nvim_lsp')
local cmp = require('cmp')
local options = {
  behavior = cmp.SelectBehavior.Inserts
}

local has_words_before = function()
  local col = fn.col('.') - 1
  local empty = fn.getline('.'):sub(col, col):match('%s')

  return col ~= 0 and empty == nil
end

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<Up>'] = cmp.mapping.select_prev_item(options),
    ['<Down>'] = cmp.mapping.select_next_item(options),
    ['<C-p>'] = cmp.mapping.select_prev_item(options),
    ['<C-n>'] = cmp.mapping.select_next_item(options),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item(options)
      else
        fallback()
      end
    end, { 'i', 's' }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item(options)
      else
        if has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end
    end, { 'i', 's' }),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'buffer' , keyword_length = 3 },
  }),
  preselect = cmp.PreselectMode.None
})

-- Configure LSP

local capabilities = lsp.default_capabilities()
local masonlsp = require('mason-lspconfig')
local lspconfig = require('lspconfig')
local mason = require('mason')

mason.setup()
masonlsp.setup({
  ensure_installed = { 'tsserver', 'eslint' },
  automatic_installation = true
})

lspconfig['tsserver'].setup({
  capabilities = capabilities
})

lspconfig['eslint'].setup({
  capabilities = capabilities
})

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = false,
  float = false,
})

-----------------------------------------------------------------------
-- Plugins
-----------------------------------------------------------------------

local noremap = { noremap = true, silent = true }
local defaults = {}
local map = api.nvim_set_keymap

map('n', '<C-k>', '<cmd>lua vim.diagnostic.goto_prev()<CR>', noremap)
map('n', '<C-j>', '<cmd>lua vim.diagnostic.goto_next()<CR>', noremap)

-- Easy align

map('v', '<Enter>', '<Plug>(EasyAlign)', noremap)

-- Undotree

map('n', '<leader>u', ':UndotreeToggle<CR>', noremap)
vim.g.undotree_WindowLayout = 2

-----------------------------------------------------------------------
-- Remaps
-----------------------------------------------------------------------

-- switch splits
map('n', '<Tab>', '<C-W>w', noremap)
map('n', '<S-Tab>', '<C-W>W', noremap)

-- since <C-i> is the same as <Tab>, use <C-p> to
-- move forward the jump list (it's near <C-o>)
map('n', '<C-p>', '<C-i>', noremap)

-- switch to last visited buffer
map('n', '§', ':b#<CR>', noremap)
map('n', '\\', ':b#<CR>', noremap)

-- record a macro with "qq" and execute it with "Q"
map('n', 'Q', '@q', noremap)

-- easier to remember
map('n', '<leader>s', 'z=', noremap)

-- save files owned by root
map('c', 'w!!', '%!sudo tee > /dev/null %', defaults)

-- indend / unindent selected text
map('x', '<S-Tab>', '<gv', noremap)
map('x', '<Tab>', '>gv', noremap)

vim.cmd [[
  " even if {} are useful motions, I never use them with the
  " italian keyboard, so remap them on the american one.
  nnoremap <expr> { tabpagenr('$') == 1 ? ':bprevious<CR>' : ':tabp<CR>'
  nnoremap <expr> } tabpagenr('$') == 1 ? ':bnext<CR>' : ':tabn<CR>'

  " use ':e %%' to insert the current file path
  cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

  " use ctrl-v to paste in the command line
  cmap <expr> <C-v> getcmdtype() =~ '[/?:]' ? '<C-r>"' : '<C-v>'

  " visually select the text that was last edited/pasted
  nnoremap <expr> gV '`[' . strpart(getregtype(), 0, 1) . '`]'
]]

-----------------------------------------------------------------------
-- Status line
-----------------------------------------------------------------------

local status_line_column = function()
  local ln = string.len(fn.line('$'))
  local wd = vim.o.numberwidth - 1
  local vc = fn.virtcol('.')

  local ruler_width = math.max(ln, wd)
  local column_width = string.len(vc)
  local column = ''

  -- we assume signcolumn is set to 'yes'
  local padding = ruler_width - column_width + 1

  if padding > 0 then
    -- + 1 becuase for some reason vim eats one of the spaces
    column = column .. string.rep(' ', padding + 1) .. vc
  else
    column = column .. vc
  end

  return column .. ' '
end

local split_string = function(input, sep)
   local t = {}

   for str in string.gmatch(input, "([^" .. sep .. "]+)") do
      table.insert(t, str)
   end

   return t
end

local shorten_path = function(path)
  local parts = split_string(path, '/')
  local len   = #(parts) - 1

  if len < 3 then
    return path
  end

  for i = 1, len do
    parts[i] = string.sub(parts[i], 1, 1)
  end

  return table.concat(parts, '/')
end

local status_line_path = function()
  local width  = fn.winwidth(0) - 30
  local path   = fn.expand('%')
  local bufnum = fn.bufnr('%')

  -- shorten file path if too long. available space depends on a
  -- lot of things, so to keep this function simple let's assume
  -- that 'a lot of things' is 30 characters long

  if string.len(path) > width then
    path = shorten_path(path)

    if string.len(path) > width then
      path = fn.pathshorten(path)
    end
  end

  if vim.bo.modified == true then
    path = path .. ' +'
  end

  if vim.bo.readonly == true then
    path = path .. ' ‼'
  end

  return path
end

local status_line_diagnostic = function()
  local diag   = vim.diagnostic
  local errors = #(diag.get(0, { severity = diag.severity.ERROR }))
  local warns = #(diag.get(0, { severity = diag.severity.WARN }))
  local infos = #(diag.get(0, { severity = diag.severity.INFO }))
  local result = ''

  if errors > 0 then
    result = result .. ' ✘ ' .. errors
  end

  if warns > 0 then
    result = result .. ' ▲ ' .. (warns + infos)
  end

  return result
end

function status_line()
    return table.concat {
      '%#LineNr#',
      status_line_column(),
      '%* ',
      status_line_path(),
      '%( ',
      status_line_diagnostic(),
      ' %)',
      '%*'
    }
end

vim.o.statusline = "%!v:lua.status_line()"

-----------------------------------------------------------------------
-- Session Management
-----------------------------------------------------------------------

local get_session_dir = function()
  return fn.expand('~/.cache/vim_session') .. fn.getcwd()
end

local get_session_file = function()
  return get_session_dir() .. '/session.vim'
end

local session_loaded = 0

local make_session = function()
  local sessionfile = get_session_file()
  local sessiondir = get_session_dir()

  if fn.filewritable(sessiondir) ~= 2 then
    api.nvim_command('silent !mkdir -p ' .. sessiondir)
  end

  api.nvim_command('mksession! ' .. sessionfile)
end

-- updates a session, BUT ONLY IF IT ALREADY EXISTS
-- and we actually loaded it (i.e. we edited a random
-- file launching vim from within a dir with a session)
local update_session = function()
  if session_loaded == 1 then
    local sessionfile = get_session_file()

    if fn.filereadable(sessionfile) == 1 then
      api.nvim_command('mksession! ' .. sessionfile)
    end
  end
end

-- loads a session if it exists and we started without arguments
local load_session = function()
  if fn.argc() == 0 then
    local sessionfile = get_session_file()

    if fn.filereadable(sessionfile) == 1 then
      api.nvim_command('source ' .. sessionfile)
      session_loaded = 1
    end
  end
end

-- use this once to create a session. it
-- is then loaded and updated automatically
map('n', '<leader>m', '<cmd>lua make_session()<CR>', noremap)

api.nvim_create_autocmd('VimEnter', {
  callback = load_session,
  nested = true,
  group = vimrc,
  pattern = '*'
})

api.nvim_create_autocmd('VimLeave', {
  callback = update_session,
  group = vimrc,
  pattern = '*'
})
