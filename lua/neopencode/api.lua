-- lua/neopencode/api.lua

local server = require("neopencode.server")
local util = require("neopencode.util")

local config = require("neopencode.config")

local M = {}

function M.list_sessions(callback)
  local port = server.get_port_from_pid()
  if not port then
    return
  end

  local url = "http://localhost:" .. port .. "/session_list"
  local command = {
    "curl",
    "-s",
    "-X",
    "POST",
    "-H",
    "Content-Type: application/json",
    url,
  }

  local stderr_lines = {}
  vim.fn.jobstart(command, {
    on_stdout = function(_, data)
      if data and #data > 0 then
        local response_str = table.concat(data, "")
        if response_str == "" then return end
        local ok, sessions = pcall(vim.fn.json_decode, response_str)
        if ok then
          callback(sessions)
        else
          require("neopencode.actions").log_error("JSON decode error: " .. sessions .. "\n\nResponse:\n" .. response_str)
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          table.insert(stderr_lines, line)
        end
      end
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        local error_message = "curl command failed with exit code: " .. code .. "\n\nStderr:\n" .. table.concat(stderr_lines, "\n")
        require("neopencode.actions").log_error(error_message)
      end
    end,
  })
end

function M.send_chat(session_id, prompt, content, file_path)
  local port = server.get_port_from_pid()
  if not port then
    return
  end

  local url = "http://localhost:" .. port .. "/session_chat"
  local body = {
    sessionID = session_id,
    providerID = config.get("provider_id"),
    modelID = config.get("model_id"),
    parts = {
      { type = "text", text = prompt },
    },
  }

  if file_path then
    body.parts[#body.parts + 1] = {
      type = "file",
      mediaType = util.get_media_type(file_path),
      url = "file://" .. file_path,
    }
  end

  if content then
    body.parts[#body.parts + 1] = { type = "text", text = content }
  end

  local command = {
    "curl",
    "-s",
    "-X",
    "POST",
    "-H",
    "Content-Type: application/json",
    "-d",
    vim.fn.json_encode(body),
    url,
  }

  local stderr_lines = {}
  vim.fn.jobstart(command, {
    on_stdout = function(_, data)
      if data and #data > 0 then
        local response_str = table.concat(data, "")
        if response_str == "" then return end
        local ok, response = pcall(vim.fn.json_decode, response_str)
        if ok then
          local message_content = ""
          if response and response.parts then
            for _, part in ipairs(response.parts) do
              if part.type == "text" then
                message_content = message_content .. part.text
              end
            end
          end
          require("neopencode.actions").display_response(message_content)
        else
          require("neopencode.actions").log_error("JSON decode error: " .. response .. "\n\nResponse:\n" .. response_str)
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          table.insert(stderr_lines, line)
        end
      end
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        local error_message = "curl command failed with exit code: " .. code .. "\n\nStderr:\n" .. table.concat(stderr_lines, "\n")
        require("neopencode.actions").log_error(error_message)
      end
    end,
  })
end

return M
