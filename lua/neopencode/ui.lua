-- lua/neopencode/ui.lua

local M = {}

-- Store callbacks in the module so they can be accessed from keymaps
M._on_confirm_callback = nil
M._on_cancel_callback = nil

function M.input(opts, on_confirm)
  opts = opts or {}
  local prompt = opts.prompt or ""
  local default = opts.default or ""

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "buftype", "acwrite")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  local lines = vim.split(default, "\n")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = math.floor(vim.api.nvim_get_option("columns") * 0.8)
  local height = math.floor(vim.api.nvim_get_option("lines") * 0.3)
  
  local win_width = vim.api.nvim_get_option("columns")
  local win_height = vim.api.nvim_get_option("lines")

  local row = math.floor((win_height - height) / 2)
  local col = math.floor((win_width - width) / 2)

  local win_opts = {
    style = "minimal",
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    border = "rounded",
    title = prompt,
    noautocmd = true,
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)
  vim.api.nvim_win_set_option(win, "cursorline", true)

  local function close_win()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
    M._on_confirm_callback = nil
    M._on_cancel_callback = nil
  end

  M._on_confirm_callback = function()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local input_text = table.concat(lines, "\n")
    close_win()
    on_confirm(input_text)
  end

  M._on_cancel_callback = function()
    close_win()
    on_confirm(nil)
  end

  vim.api.nvim_buf_set_keymap(buf, "n", "q", '<cmd>lua require("neopencode.ui")._cancel()<CR>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", '<cmd>lua require("neopencode.ui")._confirm()<CR>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<C-c>", '<cmd>lua require("neopencode.ui")._cancel()<CR>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "i", "<C-c>", '<cmd>lua require("neopencode.ui")._cancel()<CR>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "i", "<C-s>", '<cmd>lua require("neopencode.ui")._confirm()<CR>', { noremap = true, silent = true })
end

function M._confirm()
  if M._on_confirm_callback then
    M._on_confirm_callback()
  end
end

function M._cancel()
  if M._on_cancel_callback then
    M._on_cancel_callback()
  end
end

return M
