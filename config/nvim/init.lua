-- Adapted from: https://github.com/nvim-lua/kickstart.nvim

-----------------------------------------------------------------------
-- Options
-----------------------------------------------------------------------
-- See `:help vim.o`
-- For more options, you can see `:help option-list`

-- disable netrw (this will make downloading spell files fail)
-- vim.g.loaded_netrwPlugin = 1
-- vim.g.loaded_netrw = 1

-- Set <space> as the leader key
-- See `:help mapleader`
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Sync clipboard between OS and Neovim.
-- See `:help 'clipboard'`
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Save undo history
vim.o.undofile = true

-- Enable mouse mode
vim.o.mouse = 'nicr'

-- Decrease update time
vim.o.updatetime = 250

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- disable the magic "vim: .." lines in files
vim.o.modeline = false

-- don't reload a file when it's changed from the outside
vim.o.autoread = false

-- hide unsaved buffers
vim.o.hidden = true

-- if performing an operation that would fail due to unsaved changes
-- in the buffer (like `:q`), instead raise a dialog asking if you
-- wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- we like to keep all swap files in the same directory, but when you
-- open two files with the same name and then try to recover from a
-- power cord unplugged by mistake, big problems may arise, so let's
-- try to live without them
vim.o.swapfile = false

-- common mistakes
vim.cmd([[
  abbreviate lenght length
  abbreviate heigth height
  cabbrev rg Rg
  cabbrev Wq wq
  cabbrev Wa wa
  cabbrev Qa qa
  cabbrev W w
  cabbrev Q q
  cabbrev E e
  cabbrev R r
]])

-----------------------------------------------------------------------
-- Appearance
-----------------------------------------------------------------------

-- Minimal number of screen lines to keep above and below the cursor
vim.o.scrolloff = 3

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Show which line your cursor is on
vim.o.cursorline = true

-- show matching brackets
vim.o.showmatch = true

-- show border on floating windows
vim.o.winborder = 'rounded'

vim.o.background = 'dark'
vim.o.termguicolors = true
vim.o.joinspaces = false
vim.o.relativenumber = true
vim.o.number = true

-----------------------------------------------------------------------
-- White spaces
-----------------------------------------------------------------------

-- Sets how neovim will display certain white space characters
-- in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for
--  conveniently interacting with tables.
--
--  See `:help lua-options`
--  and `:help lua-options-guide`

vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.list = true

local function strip_whitespaces()
  -- preparation: save last search and cursor position.
  local last_search = vim.fn.getreg('/')
  local cur_line = vim.fn.line('.')
  local cur_col = vim.fn.col('.')

  vim.cmd([[ %s/\s\+$//e ]])

  -- restore previous search history and cursor position
  vim.fn.setreg('/', last_search)
  vim.fn.cursor(cur_line, cur_col)
end

vim.api.nvim_create_user_command('StripTrailingWhitespaces', strip_whitespaces, {})

-----------------------------------------------------------------------
-- Indenting
-----------------------------------------------------------------------

vim.o.breakindent = true

-- no real tabs please!
vim.o.shiftround = true
vim.o.expandtab = true

-- how many spaces should a tab be
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.tabstop = 2

-- indent / un-indent selected text
vim.keymap.set("x", "<S-Tab>", "<gv", { desc = 'Un-indent selected text' })
vim.keymap.set("x", "<Tab>", ">gv", { desc = 'Indent selected text' })

-----------------------------------------------------------------------
-- Auto commands
-----------------------------------------------------------------------
-- See `:help lua-guide-autocommands`

local vimrc = vim.api.nvim_create_augroup("vimrc", { clear = true })

-----------------------------------------------------------------------
-- Search / Movement
-----------------------------------------------------------------------

-- Preview substitutions live, as you type!
vim.o.inccommand = 'nosplit'

-- Case-insensitive searching UNLESS or one
-- or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- search visual selection
vim.keymap.set('x', 'n', '*', { remap = true })

-- like the original *, but don't jump to the next match
vim.keymap.set("n", "*", function()
  local word = "\\<" .. vim.fn.expand('<cword>') .. "\\>"
  vim.fn.histadd('/', word)
  vim.fn.setreg('/', word)
  -- http://stackoverflow.com/a/3766135
  return ":set hlsearch<CR>:normal wb<CR>"
end, { expr = true })

vim.keymap.set('n', '<C-k>', function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = 'Goto previous diagnostic' })

vim.keymap.set('n', '<C-j>', function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = 'Goto next diagnostic' })

-- since <C-i> is the same as <Tab>, use <C-p> to
-- move forward the jump list (it's near <C-o>)
vim.keymap.set("n", "<C-P>", "<C-i>", { desc = 'Move forward the jump list' })

-- save the jump if large enough
vim.keymap.set("n", "k", function()
  return (vim.v.count > 5 and "m'" .. vim.v.count or "") .. "k"
end, { expr = true })

vim.keymap.set("n", "j", function()
  return (vim.v.count > 5 and "m'" .. vim.v.count or "") .. "j"
end, { expr = true })

-- use virtual lines
vim.keymap.set("n", "<Down>", "gj")
vim.keymap.set("n", "<Up>", "gk")

-- easier help navigation
vim.api.nvim_create_autocmd("FileType", {
  pattern = "help",
  group = vimrc,
  callback = function()
    vim.keymap.set("n", "<CR>", "<C-]>", { buffer = true })
    vim.keymap.set("n", "<BS>", "<C-T>", { buffer = true })
  end,
})

-----------------------------------------------------------------------
-- Keymaps
-----------------------------------------------------------------------
-- See `:help vim.keymap.set()`

-- Exit terminal mode in the builtin terminal with a shortcut that is
-- a bit easier for people to discover. Otherwise, you normally need
-- to press <C-\><C-n>, which is not what someone will guess without
-- a bit more experience.
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- switch to last visited buffer
vim.keymap.set("n", "\\", ":b#<CR>", { desc = 'Switch to the last visisted buffer' })

-- even if {} are useful motions, I never use them
vim.keymap.set("n", "{", function()
  return vim.fn.tabpagenr("$") == 1 and ":bprevious<CR>" or ":tabp<CR>"
end, { expr = true, desc = 'Go to the previous buffer / tab page' })

vim.keymap.set("n", "}", function()
  return vim.fn.tabpagenr("$") == 1 and ":bnext<CR>" or ":tabn<CR>"
end, { expr = true, desc = 'Go to the next buffer / tab page' })

-- switch splits
vim.keymap.set("n", "<S-Tab>", "<C-W>W", { desc = "Goto previous split" })
vim.keymap.set("n", "<Tab>", "<C-W>w", { desc = "Goto next split" })

-- record a macro with "qq" and execute it with "Q"
vim.keymap.set("n", "Q", "@q", { desc = 'Execute the macro recorded on "q"' })

-- spellcheck, easier to remember
vim.keymap.set("n", "<leader>s", "z=", { desc = 'Spellcheck the current word' })

-- save files owned by root
vim.keymap.set("c", "w!!", function()
  return "%!sudo tee > /dev/null %"
end, { expr = true })

-- use ":e %%" to insert the current file path
vim.keymap.set("c", "%%", function()
  return vim.fn.getcmdtype() == ':' and vim.fn.expand('%:p:h') .. '/' or '%%'
end, { expr = true })

-- use ctrl-v to paste in the command line
vim.keymap.set("c", "<C-v>", function()
  return vim.fn.getcmdtype():match("[/?:]") and "<C-r>\"" or "<C-v>"
end, { expr = true })

-- visually select the text that was last edited/pasted
vim.keymap.set("n", "gV", function()
  return "`[" .. string.sub(vim.fn.getregtype(), 1, 1) .. "`]"
end, { expr = true })

vim.keymap.set("i", "<C-Right>", function()
  require('copilot.suggestion').accept_word()
end, { desc = 'Accept Copilot suggestion (Word)' })

vim.keymap.set("i", "<C-Down>", function()
  require('copilot.suggestion').accept()
end, { desc = 'Accept Copilot suggestion' })

-- yank to end of line
-- http://stackoverflow.com/questions/5010162
vim.api.nvim_create_autocmd("VimEnter", {
  group = vimrc,
  callback = function()
    vim.keymap.set("n", "Y", "y$")
  end,
})

-- vp doesn't replace paste buffer
local restore_reg = ""

local function restore_register()
  if vim.o.clipboard == "unnamed" then
    vim.fn.setreg("*", restore_reg)
  elseif vim.o.clipboard == "unnamedplus" then
    vim.fn.setreg("+", restore_reg)
  else
    vim.fn.setreg('"', restore_reg)
  end
  return ""
end

local function save_register()
  if vim.o.clipboard == "unnamed" then
    restore_reg = vim.fn.getreg("*")
  elseif vim.o.clipboard == "unnamedplus" then
    restore_reg = vim.fn.getreg("+")
  else
    restore_reg = vim.fn.getreg('"')
  end
  return "p@=v:lua.restore_register()<CR>"
end

-- expose restore_register globally so it can be called from <expr> mapping
_G.restore_register = restore_register

vim.keymap.set("x", "p", save_register, { expr = true, silent = true })

-----------------------------------------------------------------------
-- Folding
-----------------------------------------------------------------------

vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.foldnestmax = 8
vim.o.foldlevel = 99

local function smart_fold()
  if vim.fn.foldlevel('.') == 0 then
    return "\n"
  end

  -- the first line of current fold
  local foldline = vim.fn.foldclosed('.')

  -- close the current fold
  if foldline == -1 then
    return "zc"
  end

  local line = vim.fn.getline(foldline)

  -- open the current fold only for classes
  -- and tests, open recursively everything else

  if line:match("%s*class ") or line:match("%s*describe%(%=?") then
    return "zo"
  end

  if vim.fn.indent(foldline) == 0 then
    return "zO"
  end

  local nb = vim.fn.prevnonblank(foldline - 1)
  line = vim.fn.getline(nb)

  if line:match("%s*class ") or line:match("%s*describe%(%=?") then
    return "zo"
  else
    return "zO"
  end
end

vim.keymap.set("n", "<CR>", smart_fold, { expr = true, silent = true })

-----------------------------------------------------------------------
-- Status line
-----------------------------------------------------------------------
-- http://www.blaenkdenum.com/posts/a-simpler-vim-statusline/

function StatuslineColumn()
  local vc = vim.fn.virtcol('.')
  local ruler_width = math.max(
    string.len(tostring(vim.fn.line('$'))),
    vim.o.numberwidth - 1
  )
  local column_width = string.len(tostring(vc))
  local padding = ruler_width - column_width + 2

  return string.rep(" ", padding + 1) .. vc .. ' '
end

function ShortenPath(path)
  local parts = vim.split(path, '/')
  if #parts < 3 then return path end

  local short_parts = {}
  for i = 1, #parts - 2 do
    if #parts[i] > 0 then
      table.insert(short_parts, parts[i]:sub(1,1))
    end
  end
  table.insert(short_parts, parts[#parts - 1])
  table.insert(short_parts, parts[#parts])

  return table.concat(short_parts, '/')
end

function StatuslinePath()
  local width = vim.fn.winwidth(0) - 30
  local path = vim.fn.expand('%')
  local bufnum = vim.fn.bufnr('%')

  -- shorten file path if too long. available space depends on a
  -- lot of things, so to keep this function simple let's assume
  -- that 'a lot of things' is 30 characters long

  if #path > width then
    path = ShortenPath(path)
    if #path > width then
      path = vim.fn.pathshorten(path)
    end
  end

  path = path .. ' [' .. vim.bo.fileformat .. ']'

  if vim.fn.getbufvar(bufnum, '&modified') == 1 then
    path = path .. ' +'
  end

  if vim.fn.getbufvar(bufnum, '&readonly') == 1 then
    path = path .. ' ‼'
  end

  return path
end

function LinterStatus()
  local error = #vim.diagnostic.get(0, {
    severity = vim.diagnostic.severity.ERROR
  })
  local warn = #vim.diagnostic.get(0, {
    severity = {
      vim.diagnostic.severity.WARN,
      vim.diagnostic.severity.INFO,
      vim.diagnostic.severity.HINT,
    }
  })
  local msgs = {}

  if error > 0 then
    table.insert(msgs, '✖ ' .. error)
  end

  if warn > 0 then
    table.insert(msgs, '⚠ ' .. warn)
  end

  return table.concat(msgs, ' ')
end

vim.o.statusline = table.concat({
  "%#LineNr#",
  "%{v:lua.StatuslineColumn()}",
  "%*",
  " %{v:lua.StatuslinePath()}",
  "%( %{v:lua.LinterStatus()} %)",
  "%*"
})

-----------------------------------------------------------------------
-- Functions
-----------------------------------------------------------------------

local function js_find_file(name)
  if name:sub(1, 1) == "." then
    local base = vim.fn.simplify(vim.fn.expand("%:h") .. "/" .. name)
    local list = vim.fn.glob(base .. ".*", false, true)
    local file = list[1] or name

    if vim.fn.filereadable(file) == 1 then
      return file
    end

    return name
  end

  -- https://damien.pobel.fr/post/configure-neovim-vim-gf-javascript-import/
  local node_modules = "./node_modules/" .. name .. "/"
  local package_path = node_modules .. "package.json"

  if vim.fn.filereadable(package_path) == 1 then
    local json = vim.fn.json_decode(table.concat(vim.fn.readfile(package_path), "\n"))
    local main = json.main or "index.js"
    return node_modules .. main
  end

  return ""
end

local function js_goto_file(split, tab)
  local name = vim.fn.matchstr(vim.fn.getline("."), vim.o.include)
  local file = js_find_file(name)

  -- https://gist.github.com/romainl/2ecbf1aaf60b4c0e2c135569d516fbd8
  if #file > 1 then
    local cmds = {
      ["11"] = "silent tab vsplit ",
      ["10"] = "silent vsplit ",
      ["00"] = "silent edit ",
    }
    vim.cmd(cmds[tostring(split) .. tostring(tab)] .. file)
    return
  end

  vim.api.nvim_echo({ { "Can't find file " .. name, "WarningMsg" } }, false, {})
end

vim.api.nvim_create_autocmd("FileType", {
  group = vimrc,
  pattern = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  },
  callback = function()
    vim.opt_local.include = [[\(\<require\s*(\s*\|\<import\>\|\<export\>\)[^;"']*["']\zs[^"']*]]
    vim.keymap.set("n", "gf", function() js_goto_file(0, 0) end, { silent = true, buffer = true })
    vim.opt_local.suffixes = ".js,.jsx,.ts,.tsx"
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 0
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "it,en"
  end,
})

-----------------------------------------------------------------------
-- Session Management
-----------------------------------------------------------------------

vim.opt.sessionoptions = { "curdir", "folds", "tabpages" }

local function get_session_dir()
  return vim.fn.expand('~/.cache/vim_session') .. vim.fn.getcwd()
end

local function make_session()
  local sessiondir = get_session_dir()
  local filename = sessiondir .. "/session.vim"

  if vim.fn.filewritable(sessiondir) ~= 2 then
    vim.fn.mkdir(sessiondir, "p")
    vim.cmd("redraw!")
  end
  vim.cmd("mksession! " .. filename)
end

-- updates a session, BUT ONLY IF IT ALREADY EXISTS
-- and we actually loaded it (i.e. we edited a random
-- file launching vim from within a dir with a session)
local sessionloaded = 0

local function update_session()
  if sessionloaded == 1 then
    local sessiondir = get_session_dir()
    local filename = sessiondir .. "/session.vim"

    if vim.fn.filereadable(filename) == 1 then
      vim.cmd("mksession! " .. filename)
    end
  end
end

local function load_session()
  if vim.fn.argc() ~= 0 then
    sessionloaded = 0
    return
  end

  local sessiondir = get_session_dir()
  local filename = sessiondir .. "/session.vim"

  if vim.fn.filereadable(filename) == 1 then
    vim.cmd("source " .. filename)
    sessionloaded = 1
  else
    vim.cmd("echo 'No session loaded.'")
  end
end

vim.api.nvim_create_user_command('MakeSession', make_session, {})
vim.api.nvim_create_user_command('LoadSession', load_session, {})

-- use this once to create a session. it
-- is then loaded and updated automatically
vim.keymap.set("n", "<leader>m", make_session, { silent = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = vimrc,
  callback = load_session,
  nested = true,
})

vim.api.nvim_create_autocmd("VimLeave", {
  group = vimrc,
  callback = update_session,
})

-----------------------------------------------------------------------
-- Plugin Manager
-----------------------------------------------------------------------

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
local lazyrepo = 'https://github.com/folke/lazy.nvim.git'

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({

------------------------------------------------------------------------
--- Color scheme, etc...
------------------------------------------------------------------------

  {
    'alligator/accent.vim',
    priority = 1000,
    lazy = false,
    config = function()
      vim.g.accent_no_bg = 1
      vim.cmd.colorscheme('accent')
      vim.cmd([[
        highlight LineNr guifg=#666666 guibg=#000000
        highlight StatusLine guifg=#000000 gui=bold
        highlight Type guifg=#dfdfef gui=bold
      ]])
    end,
  },
  {
    'junegunn/vim-easy-align',
    keys = {
      { "<Enter>", '<Plug>(EasyAlign)', mode = 'v' },
    },
  },
  {
    'mbbill/undotree',
    keys = {
      { '<leader>u', '<cmd>UndotreeToggle<CR>' },
    },
    config = function()
      vim.g.undotree_WindowLayout = 2
    end
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    main = 'todo-comments',
    event = 'VimEnter',
    keys = {
      { '<leader>t', '<cmd>TodoTelescope keywords=TODO,FIXME<cr>', 'Show all TODO / FIXME comments' },
    },
    opts = {
      merge_keywords = false,
      keywords = {
        FIXME = { icon = 'F', color = 'error', },
        TODO = { icon = 'T', color = 'info' },
        XXX = { icon = 'X', color = 'warning' },
        NOTE = { icon = '!', color = 'hint', },
      },
      highlight = {
        pattern = [[(KEYWORDS)]],
        comments_only = true,
        max_line_len = 200,
        keyword = 'bg',
      },
      search = {
        pattern = [[\b(KEYWORDS)\b]],
      },
    },
  },
  {
    'kylechui/nvim-surround',
    version = '^3.0.0', -- Use for stability;
    event = 'VeryLazy',
    opts = {},
  },
  {
    'brenoprata10/nvim-highlight-colors',
    opts = {},
  },
  {
    'michaeljsmith/vim-indent-object',
  },

------------------------------------------------------------------------
--- Fuzzy Finder
------------------------------------------------------------------------

  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
    },
    config = function()
      local previewers = require('telescope.previewers')
      local builtin = require('telescope.builtin')
      local actions = require("telescope.actions")
      local telescope = require('telescope')

      -- show the current content of the buffer, even if unsaved
      local function buffer_previewer()
        return previewers.new_buffer_previewer({
          title = "Buffer Preview",
          define_preview = function(self, entry)
            -- if entry.bufnr isn't present, get bufnr from file name
            local bufnr = entry.bufnr or vim.fn.bufnr(entry.filename, false)
            local total = vim.api.nvim_buf_line_count(bufnr)
            local current = entry.lnum or 1
            local context = 5

            local start_line = math.max(current - context - 1, 0)
            local end_line = math.min(current + context, total)
            local cursor_line = current - start_line

            local lines = { 'Buffer not found' }

            if bufnr ~= -1 then
              lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)
            end

            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
            vim.api.nvim_buf_add_highlight(self.state.bufnr, -1, "Visual", cursor_line - 1, 0, -1)
          end,
        })
      end

      require('telescope').setup({
        defaults = {
          layout_strategy = "vertical",
          mappings = {
            i = {
              ["<Esc>"] = actions.close,
            },
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
        pickers = {
          diagnostics = {
            previewer = buffer_previewer()
          },
        },
      })

      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'ui-select')

      local function grep_word()
        return builtin.grep_string({ word_match = '-w' })
      end

      vim.keymap.set('n', '<leader>f', builtin.git_files, {
        desc = 'Search [F]iles'
      })
      vim.keymap.set('n', '<leader>a', grep_word, {
        desc = 'Search [A]ll occurences of the current word'
      })
      vim.keymap.set('n', '<leader>b', builtin.buffers, {
        desc = 'Search existing [B]uffers'
      })
      vim.keymap.set('n', '<leader>e', builtin.diagnostics, {
        desc = 'Search [E]rrors / Warnings'
      })
      vim.keymap.set('n', '<leader>g', builtin.live_grep, {
        desc = 'Live [G]rep'
      })
    end,
  },

------------------------------------------------------------------------
--- Copilot
------------------------------------------------------------------------

  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    build = ':Copilot auth',
    event = 'BufReadPost',
    opts = {
      suggestion = {
        enabled = not vim.g.ai_cmp,
        auto_trigger = true,
        hide_during_completion = vim.g.ai_cmp,
        keymap = {
          accept = false, -- handled by nvim-cmp / blink.cmp
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        typescriptreact = true,
        javascriptreact = true,
        typescript = true,
        javascript = true,
        markdown = true,
        json = true,
      },
    },
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'nvim-lua/plenary.nvim', branch = 'master' },
    },
    build = function ()
      if vim.fn.executable('make') == 0 then
        vim.notify('Warning: tiktoken not installed. Please install tiktoken manually.', vim.log.levels.WARN)
        return
      end
      vim.fn.execute('make tiktoken')
    end,
    keys = {
      { '<leader>c', '<cmd>CopilotChatToggle<CR>' },
    },
    opts = {
      model = 'claude-sonnet-4', -- AI model to use
      temperature = 0.1,         -- Lower = focused, higher = creative
      window = {
        layout = 'vertical',     -- 'vertical', 'horizontal', 'float'
        width = 0.5,
      },
      headers = {
        assistant = '🤖 Copilot ',
        tool = '🔧 Tool ',
        user = '👤 You ',
      },
      auto_insert_mode = false, -- Enter insert mode when opening
    },
  },

------------------------------------------------------------------------
--- Auto completion
------------------------------------------------------------------------

  {
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      'giuxtaposition/blink-cmp-copilot',
      'folke/lazydev.nvim',
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'none',
        ['<CR>'] = { 'accept', 'fallback' },
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
        list = {
          selection = { preselect = false },
        },
        menu = {
          draw = {
            columns = function(ctx)
              if ctx.mode ~= 'cmdline' then
                return { { "label", "label_description", "kind", gap = 1 } }
              else
                return { { "label", "label_description", gap = 1 } }
              end
            end,
            components = {
              kind = {
                text = function(ctx)
                  return '[' .. string.lower(ctx.kind) .. ']'
                end,
              },
              label_description = {
                width = { fill = true },
              },
            },
          },
        },
      },
      cmdline = {
        sources = { 'cmdline', 'buffer' },
        enabled = true,
        completion = {
          list = {
            selection = { preselect = false },
          },
        },
        keymap = {
          preset = 'inherit',
          ['<Tab>'] = { 'show_and_insert', 'select_next', 'fallback' },
          ['<Right>'] = {
            function(cmp)
              local item = cmp.get_selected_item()

              -- check if the item ends with a slash
              if item and string.sub(item.label, -1) == '/' then
                return cmp.accept()
              end

              return false
            end,
            'fallback'
          },
          ['<CR>'] = {},
        },
      },
      sources = {
        default = { 'lsp', 'path', 'lazydev', 'buffer', 'copilot' },
        providers = {
          path = {
            module = 'blink.cmp.sources.path',
            opts = {
              label_trailing_slash = true,
              trailing_slash = false,
            }
          },
          lazydev = {
            module = 'lazydev.integrations.blink',
            score_offset = 100
          },
          copilot = {
            name = 'copilot',
            module = 'blink-cmp-copilot',
            score_offset = 100,
            async = true,
          },
        },
      },
      fuzzy = {
        implementation = 'lua',
        sorts = {
          'exact',
          'score',
          'sort_text',
        }
      },
      signature = { enabled = true },
    },
  },

------------------------------------------------------------------------
--- Syntax highlight
------------------------------------------------------------------------

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    opts = {
      ensure_installed = {
        'bash',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'vim',
        'vimdoc',
        "typescript",
        "tsx",
      },
      auto_install = true,
      highlight = {
        -- Some languages depend on vim's regex highlighting system
        -- (such as Ruby) for indent rules. If you are experiencing
        -- weird indenting issues, add the language to the list of
        -- additional_vim_regex_highlighting and disabled languages
        -- for indent.
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = {
        enable = true,
        disable = { 'ruby' }
      },
      fold = {
        enable = true,
      },
      textobjects = {
        select = {
          enable = true,

          -- Automatically jump forward to textobj, similar to
          -- targets.vim
          lookahead = true,

          keymaps = {
            ["af"] = { query = "@function.outer", desc = "Select outer part of a function" },
            ["if"] = { query = "@function.inner", desc = "Select inner part of a function" },
            ["ac"] = { query = "@class.outer", desc = "Select outer part of a class region" },
            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
            ["aa"] = { query = "@parameter.outer", desc = "Select outer part of a function argument" },
            ["ia"] = { query = "@parameter.inner", desc = "Select inner part of a function argument" },
            -- You can use captures from other query groups like `locals.scm`
            ["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
          },
          -- You can choose the select mode (default is charwise 'v')
          selection_modes = {
            ['@function.outer'] = 'V', -- linewise
            ['@function.inner'] = 'V',
            ['@class.outer'] = 'V',
            ['@class.inner'] = 'V',
          },
          include_surrounding_whitespace = true,
        },
        swap = {
          enable = true,
          swap_next = {
            ['gsn'] = "@parameter.inner",
          },
          swap_previous = {
            ['gsp'] = "@parameter.inner",
          },
        },
      },
    },
  },

------------------------------------------------------------------------
--- LSP
------------------------------------------------------------------------

  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'mason-org/mason-lspconfig.nvim',
      'saghen/blink.cmp',
    },
    config = function()
      local builtin = require('telescope.builtin')

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),

        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('<leader>d', vim.lsp.buf.hover, 'Show symbol type')

          -- Jump to the definition of the word under your cursor.
          -- This is where a variable was first declared, or where
          -- a function is defined, etc. To jump back, press <C-t>.
          map('<leader><Space>', builtin.lsp_definitions, 'Goto Definition')

          -- Find references for the word under your cursor.
          map('<leader>r', builtin.lsp_references, 'Goto [R]eferences')

          -- Rename the variable under your cursor.
          -- Most Language Servers support renaming across files, etc.
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on
          -- top of an error or a suggestion from your LSP for this
          -- to activate.
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

          -- Jump to the implementation of the word under your cursor.
          -- Useful when your language has ways of declaring types
          -- without an actual implementation.
          map('gri', builtin.lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor. Useful when
          -- you're not sure what type a variable is and you want to see
          -- the definition of its *type*, not where it was *defined*.
          map('grt', builtin.lsp_type_definitions, '[G]oto [T]ype Definition')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          -- For example, in C this would take you to the header.
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Fuzzy find all the symbols in your current document.
          -- Symbols are things like variables, functions, types, etc.
          map('gO', builtin.lsp_document_symbols, 'Open Document Symbols')

          -- Fuzzy find all the symbols in your current workspace.
          -- Similar to document symbols, except searches over your
          -- entire project.
          map('gW', builtin.lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')

          -- Resolve a difference between neovim 0.11 and 0.10
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- The following two autocommands are used to highlight
          -- references of the word under your cursor when your cursor
          -- rests there for a little while. See `:help CursorHold`
          -- for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared
          -- (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
              end,
            })
          end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      ---@class LspServersConfig
      local servers = {
        ts_ls = {},
        eslint = {},
        jsonls = {},
        cssls = {},
        tailwindcss = {},
        html = {},
        fish_lsp = {},
        lua_ls = {},
      }

      -- Ensure the servers and tools above are installed
      --
      -- To check the current status of installed tools and/or
      -- manually install other tools, you can run
      --    :Mason
      --
      -- You can press `g?` for help in this menu.
      --
      local ensure_installed = vim.tbl_keys(servers or {})

      vim.list_extend(ensure_installed, {
        'stylua',
      })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        automatic_enable = true,
        ensure_installed = {},
      }

      for server, config in pairs(servers) do
        vim.lsp.config(server, config)
      end
    end,
  },
})
