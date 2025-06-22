-- lua/neopencode/actions.lua

local session = require("neopencode.session")
local api = require("neopencode.api")
local ui = require("neopencode.ui")

local M = {}


function M.send_file()
  if not session.current_session_id then
    M.log_error("No neopencode session selected. Please run :OpencodeSelectSession")
    return
  end

  local file_path = vim.fn.expand("%:p")
  if file_path == "" then
    M.log_error("No file name.")
    return
  end

  local default_text = "File: " .. vim.fn.expand("%")

  ui.input({
    prompt = "Prompt for " .. file_path,
    default = default_text,
  }, function(prompt)
    if not prompt or prompt == "" then
      return
    end
    -- The entire content of the window is the prompt.
    api.send_chat(session.current_session_id, prompt, nil, vim.fn.expand("%"))
  end)
end

function M.send_selection(start_line, end_line)
  if not session.current_session_id then
    M.log_error("No neopencode session selected. Please run :OpencodeSelectSession")
    return
  end

  local file_path = vim.fn.expand("%")
  if file_path == "" then
    M.log_error("No file name.")
    return
  end

  local selected_lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local selected_text = table.concat(selected_lines, "\n")

  local prompt_text = "Prompt for " .. file_path .. " L" .. start_line .. ":L" .. end_line
  local file_info = "File: " .. file_path .. " L" .. start_line .. ":L" .. end_line
  local default_text = file_info .. "\n" .. selected_text

  ui.input({
    prompt = prompt_text,
    default = default_text,
  }, function(prompt)
    if not prompt or prompt == "" then
      return
    end
    -- The entire content of the window is the prompt.
    api.send_chat(session.current_session_id, prompt, nil, file_path .. ":" .. start_line .. "-" .. end_line)
  end)
end

function M.log_error(message)
  local bufname = "neopencode.ai error"
  local bufnr = vim.fn.bufnr(bufname)

  -- If buffer doesn't exist, create it
  if bufnr == -1 then
    vim.cmd("new " .. bufname)
    vim.api.nvim_buf_set_option(0, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(0, "buftype", "nofile")
    vim.api.nvim_buf_set_option(0, "swapfile", false)
    bufnr = vim.api.nvim_get_current_buf()
  end

  -- Switch to the error buffer window if it's not open
  local winid = vim.fn.bufwinid(bufnr)
  if winid == -1 then
    vim.cmd("sbuffer " .. bufnr)
  else
    vim.api.nvim_set_current_win(winid)
  end

  -- Append the error message
  local lines = vim.fn.split(message, "\n")
  vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, lines)
  vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { "---" }) -- Separator
end

function M.display_response(response)
  -- Do nothing.
end

return M
