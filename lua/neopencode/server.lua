-- lua/neopencode/server.lua

local M = {}

function M.get_pid()
  local handle = io.popen("ps aux | grep 'opencode$' | grep -v grep | awk '{print $2}'")
  if not handle then
    return nil
  end
  local pid = handle:read("*a")
  handle:close()
  pid = pid:match("^%s*(.-)%s*$") -- trim whitespace
  if pid == "" then
    return nil
  end
  return tonumber(pid)
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
