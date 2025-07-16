-- lua/neopencode/server.lua

local M = {}

function M.get_all_pids()
  local handle = io.popen("ps aux | grep 'opencode$' | grep -v grep | awk '{print $2}'")
  if not handle then
    return {}
  end
  local output = handle:read("*a")
  handle:close()
  
  local pids = {}
  for pid_str in output:gmatch("[^\r\n]+") do
    local pid = tonumber(pid_str:match("^%s*(.-)%s*$"))
    if pid then
      table.insert(pids, pid)
    end
  end
  return pids
end

function M.get_pid()
  local pids = M.get_all_pids()
  return pids[1]
end

function M.select_opencode_instance(callback)
  local pids = M.get_all_pids()
  
  if #pids == 0 then
    vim.notify("opencode server not found", vim.log.levels.ERROR)
    return
  end
  
  if #pids == 1 then
    local port = M.get_port(pids[1])
    if port then
      callback(port)
    else
      vim.notify("Could not determine opencode server port", vim.log.levels.ERROR)
    end
    return
  end
  
  -- Multiple instances - show picker
  local options = {}
  local pid_map = {}
  
  for _, pid in ipairs(pids) do
    local port = M.get_port(pid)
    local display_text = "PID: " .. pid
    if port then
      display_text = display_text .. " (Port: " .. port .. ")"
    else
      display_text = display_text .. " (Port: unknown)"
    end
    table.insert(options, display_text)
    pid_map[display_text] = {pid = pid, port = port}
  end
  
  vim.ui.select(options, {
    prompt = "Select opencode instance:",
    format = function(item)
      return "  " .. item
    end,
  }, function(choice)
    if choice and pid_map[choice] then
      local selected = pid_map[choice]
      if selected.port then
        callback(selected.port)
      else
        vim.notify("Could not determine opencode server port for PID " .. selected.pid, vim.log.levels.ERROR)
      end
    end
  end)
end

function M.get_port_from_pid()
  local pid = M.get_pid()
  if not pid then
    vim.notify("opencode server not found", vim.log.levels.ERROR)
    return nil
  end
  local port = M.get_port(pid)
  if not port then
    vim.notify("Could not determine opencode server port", vim.log.levels.ERROR)
    return nil
  end
  return port
end

function M.get_port(pid)
  local command = "lsof -p " .. pid .. " | grep LISTEN | grep TCP | awk '{print $9}' | cut -d: -f2"
  local handle = io.popen(command)
  if not handle then
    return nil
  end
  local port = handle:read("*a")
  handle:close()
  port = port:match("^%s*(.-)%s*$") -- trim whitespace
  if port == "" then
    return nil
  end
  return tonumber(port)
end

return M
