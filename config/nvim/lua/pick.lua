-- Custom picker module built on mini.pick + mini.extra.
-- Provides wrappers for pickers that need extra logic beyond a direct API call.
-- Called from the mini.pick plugin config in init.lua via require("pick").setup().

local M = {}

-- Files in the current project.
-- Uses fd/rg which respects .gitignore (tracked + untracked non-ignored files).
-- Works both inside and outside git repos, no fallback needed.
local function find_project_files()
  require("mini.pick").builtin.files()
end

-- Grep current word with word-boundary matching (mirrors grep_string word_match="-w").
local function grep_word()
  local word = vim.fn.expand("<cword>")
  if word == "" then return end
  -- Escape ripgrep regex special characters in the literal word before wrapping in \b...\b
  local escaped = word:gsub("[%(%)%.%%%+%-%*%?%[%^%$]", "\\%1")
  require("mini.pick").builtin.grep({ pattern = "\\b" .. escaped .. "\\b" })
end

-- Buffers sorted by most recently used (mirrors builtin.buffers({ sort_mru = true })).
local function buffers_mru()
  local bufinfo = vim.fn.getbufinfo({ buflisted = 1 })
  table.sort(bufinfo, function(a, b) return a.lastused > b.lastused end)

  local items = {}
  for _, buf in ipairs(bufinfo) do
    local name = vim.fn.fnamemodify(buf.name, ":~:."):gsub("\\", "/")
    if name ~= "" then
      table.insert(items, { text = name, bufnr = buf.bufnr })
    end
  end

  local orig_win = vim.api.nvim_get_current_win()

  require("mini.pick").start({
    source = {
      name = "Buffers (MRU)",
      items = items,
      choose = function(item)
        vim.api.nvim_win_set_buf(orig_win, item.bufnr)
        vim.api.nvim_set_current_win(orig_win)
      end,
    },
  })
end

-- Diagnostics with a live in-memory buffer previewer.
-- Uses vim.diagnostic.get() directly so the preview always reflects the current
-- buffer content (not the file on disk), matching the original buffer_previewer().
local function diagnostics()
  local sev_icons = { "✖", "⚠", "ℹ", "●" }
  local raw = vim.diagnostic.get(nil) -- nil = all buffers
  local items = {}

  for _, diag in ipairs(raw) do
    local bufnr = diag.bufnr
    if vim.api.nvim_buf_is_valid(bufnr) then
      local fname = vim.api.nvim_buf_get_name(bufnr)
      if fname ~= "" then
        local rel = vim.fn.fnamemodify(fname, ":~:."):gsub("\\", "/")
        local sev = diag.severity or 4
        local lnum = diag.lnum + 1 -- convert 0-indexed to 1-indexed
        table.insert(items, {
          text = (sev_icons[sev] or "●") .. " " .. rel .. ":" .. lnum .. ": " .. (diag.message:gsub("\n", " ")),
          bufnr = bufnr,
          lnum = lnum,
          severity = sev,
        })
      end
    end
  end

  -- Sort by severity (lower = more severe) then by display text
  table.sort(items, function(a, b)
    if a.severity ~= b.severity then return a.severity < b.severity end
    return a.text < b.text
  end)

  local orig_win = vim.api.nvim_get_current_win()

  require("mini.pick").start({
    source = {
      name = "Diagnostics",
      items = items,
      choose = function(item)
        vim.api.nvim_win_set_buf(orig_win, item.bufnr)
        vim.api.nvim_set_current_win(orig_win)
        vim.fn.cursor(item.lnum, 1)
      end,
      preview = function(buf_id, item)
        local item_bufnr = item.bufnr
        if not item_bufnr or not vim.api.nvim_buf_is_valid(item_bufnr) then
          vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, { "(buffer not available)" })
          return
        end

        local lnum = item.lnum
        local context = 5
        local total = vim.api.nvim_buf_line_count(item_bufnr)
        local start_line = math.max(lnum - context - 1, 0)
        local end_line = math.min(lnum + context, total)
        local cursor_line = lnum - start_line

        local lines = vim.api.nvim_buf_get_lines(item_bufnr, start_line, end_line, false)
        vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)

        local hl_line = math.max(cursor_line - 1, 0)
        if #lines > 0 then
          vim.hl.range(buf_id, 1, "Visual", { hl_line, 0 }, { hl_line, -1 })
        end
      end,
    },
  })
end

-- TODO / FIXME picker (mirrors <cmd>TodoTelescope keywords=TODO,FIXME).
local function todo_pick()
  require("mini.pick").builtin.grep({ pattern = "\\b(TODO|FIXME)\\b" })
end

-- Go to definition: jump directly when there is exactly one result,
-- open a picker when there are multiple.
local function goto_definition_smart()
  local win = vim.api.nvim_get_current_win()
  -- Collect offset encodings per client so jump_to_location uses the right one.
  local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_win_get_buf(win) })
  local encoding_by_client = {}
  for _, client in ipairs(clients) do
    encoding_by_client[client.id] = client.offset_encoding or "utf-8"
  end

  local params = vim.lsp.util.make_position_params(win, "utf-8")
  vim.lsp.buf_request_all(0, "textDocument/definition", params, function(results)
    local locations = {}
    local first_encoding = "utf-8"
    for client_id, res in pairs(results) do
      if res.result then
        local enc = encoding_by_client[client_id] or "utf-8"
        if vim.islist(res.result) then
          for _, loc in ipairs(res.result) do
            table.insert(locations, { location = loc, encoding = enc })
          end
        else
          table.insert(locations, { location = res.result, encoding = enc })
        end
        first_encoding = enc
      end
    end

    if #locations == 0 then
      vim.notify("No definition found", vim.log.levels.INFO)
    elseif #locations == 1 then
      vim.lsp.util.jump_to_location(locations[1].location, locations[1].encoding)
    else
      require("mini.extra").pickers.lsp({ scope = "definition" })
    end
  end)
end

function M.setup()
  require("mini.pick").setup({
    mappings = {
      -- Close picker with <Esc> (mirrors telescope's i-mode <Esc> = actions.close)
      stop = "<Esc>",
    },
    window = {
      -- Match the position and width of the current window when the picker opens.
      -- Subtract 2 from width to account for left + right border characters.
      config = function()
        local win = vim.api.nvim_get_current_win()
        local col = vim.api.nvim_win_get_position(win)[2]
        local width = vim.api.nvim_win_get_width(win) - 2
        return { col = col, width = width }
      end,
    },
  })


  -- Replace vim.ui.select (used by LSP code actions, etc.)
  -- Mirrors the telescope-ui-select extension
  vim.ui.select = require("mini.pick").ui_select

  vim.keymap.set("n", "<leader>b", buffers_mru, { desc = "Search existing [B]uffers" })
  vim.keymap.set("n", "<leader>f", find_project_files, { desc = "Search [F]iles" })
  vim.keymap.set("n", "<leader>a", grep_word, { desc = "Search [A]ll occurrences of the current word" })
  vim.keymap.set("n", "<leader>e", diagnostics, { desc = "Search [E]rrors / Warnings" })
  vim.keymap.set("n", "<leader>g", function()
    require("mini.extra").pickers.git_files({ scope = "modified" })
  end, { desc = "[G]it modified files (staged/unstaged)" })
end

M.todo_pick = todo_pick
M.goto_definition_smart = goto_definition_smart

return M
