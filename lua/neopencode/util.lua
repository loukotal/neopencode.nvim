-- lua/neopencode/util.lua

local M = {}

function M.get_media_type(filename)
  local extension = filename:match("^.+(%..+)$")
  if not extension then return "text/plain" end

  local media_types = {
    [".txt"] = "text/plain",
    [".lua"] = "text/x-lua",
    [".js"] = "application/javascript",
    [".json"] = "application/json",
    [".html"] = "text/html",
    [".css"] = "text/css",
    [".md"] = "text/markdown",
  }

  return media_types[extension] or "text/plain"
end

return M
