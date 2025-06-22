-- lua/neopencode/session.lua

local api = require("neopencode.api")

local M = {}

-- This will hold the selected session ID for the current nvim session.
M.current_session_id = nil

function M.select_session()
  api.list_sessions(function(sessions)
    if not sessions or #sessions == 0 then
      vim.notify("No neopencode sessions found.", vim.log.levels.WARN)
      -- here you should ask the user if they want to create a new session
      local choice = vim.fn.confirm("No sessions found. Create a new one?", "&Yes\n&No", 2)
      if choice == 1 then
        M.create_session()
      end
      return
    end

    table.sort(sessions, function(a, b)
      local a_updated = a.time and a.time.updated
      local b_updated = b.time and b.time.updated
      if a_updated and b_updated then
        return a_updated > b_updated
      elseif a_updated then
        return true
      elseif b_updated then
        return false
      else
        return false
      end
    end)

    local session_options = { "New Session" }
    local session_map = { ["New Session"] = "new_session" }
    for _, session in ipairs(sessions) do
      local display_text = session.id
      if session.title and session.title ~= "" then
        display_text = session.title .. " (" .. session.id .. ")"
      elseif session.summary and session.summary ~= "" then
        display_text = session.summary .. " (" .. session.id .. ")"
      end
      table.insert(session_options, display_text)
      session_map[display_text] = session.id
    end

    vim.ui.select(session_options, {
      prompt = "Opencode.ai Sessions",
      format = function(item)
        return "  " .. item
      end,
    }, function(choice)
      if choice then
        if session_map[choice] == "new_session" then
          M.create_session()
          return
        end
        local session_id = session_map[choice]
        M.current_session_id = session_id
        vim.notify("Switched to neopencode session: " .. session_id)
      end
    end)
  end)
end

function M.create_session(callback)
  local port = require("neopencode.server").get_port_from_pid()
  if not port then
    return
  end

  local url = "http://localhost:" .. port .. "/session_create"
  local command = {
    "curl",
    "-s",
    "-v",
    "-X",
    "POST",
    "-H",
    "Content-Type: application/json",
    "-d",
    "{}",
    url,
  }

  local stderr_lines = {}
  vim.fn.jobstart(command, {
    on_stdout = function(_, data)
      if data and #data > 0 then
        local response_str = table.concat(data, "")
        if response_str == "" then return end
        local ok, session = pcall(vim.fn.json_decode, response_str)
        if ok then
          M.current_session_id = session.id
          vim.notify("Created and switched to new neopencode session: " .. session.id)
          if callback then
            callback(session.id)
          end
        else
          require("neopencode.actions").log_error("JSON decode error: " .. session .. "\n\nResponse:\n" .. response_str)
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
