-- lua/neopencode/api.lua

local server = require("neopencode.server")

local config = require("neopencode.config")

local M = {}

function M.list_sessions(callback)
  local pids = server.get_all_pids()
  if #pids == 0 then
    callback({})
    return
  end

  local all_sessions = {}
  local completed_requests = 0

  for _, pid in ipairs(pids) do
    local port = server.get_port(pid)
    if port then
      M._list_sessions_with_port(port, function(sessions)
        -- Add port info to each session
        for _, session in ipairs(sessions or {}) do
          session._port = port
          session._pid = pid
          table.insert(all_sessions, session)
        end

        completed_requests = completed_requests + 1
        if completed_requests == #pids then
          callback(all_sessions)
        end
      end)
    else
      completed_requests = completed_requests + 1
      if completed_requests == #pids then
        callback(all_sessions)
      end
    end
  end
end

function M._list_sessions_with_port(port, callback)
  local url = "http://localhost:" .. port .. "/session"
  local command = {
    "curl",
    "-s",
    "-X",
    "GET",
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
          vim.notify("JSON decode error: " .. sessions, vim.log.levels.ERROR)
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
        local error_message = "curl command failed with exit code: " ..
            code .. "\n\nStderr:\n" .. table.concat(stderr_lines, "\n")
        vim.notify(error_message, vim.log.levels.ERROR)
      end
    end,
  })
end

function M.send_chat(session_id, prompt)
  local session = require("neopencode.session").current_session

  if session and session._port then
    M._send_chat_with_port(session._port, session_id, prompt)
  else
    vim.notify("No session selected or session port unknown", vim.log.levels.ERROR)
  end
end

function M._send_chat_with_port(port, session_id, prompt)
  local url = "http://localhost:" .. port .. "/session/" .. session_id .. "/message"
  local message_id = vim.fn.system("uuidgen"):gsub("\n", "")
  local body = {
    messageID = message_id,
    providerID = config.get("provider_id"),
    modelID = config.get("model_id"),
    mode = "build",
    parts = {},
  }

  if prompt then
    body.parts[#body.parts + 1] = {
      type = "text",
      id = vim.fn.system("uuidgen"):gsub("\n", ""),
      sessionID = session_id,
      messageID = message_id,
      text = prompt
    }
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
          vim.notify("JSON decode error: " .. response, vim.log.levels.ERROR)
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
        local error_message = "curl command failed with exit code: " ..
            code .. "\n\nStderr:\n" .. table.concat(stderr_lines, "\n")
        vim.notify(error_message, vim.log.levels.ERROR)
      end
    end,
  })
end

return M
