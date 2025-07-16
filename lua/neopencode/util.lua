-- lua/neopencode/util.lua

local M = {}

function M.get_media_type(filename)
  local extension = filename:match("^.+(%..+)$")
  if not extension then return "text/plain" end

  local media_types = {
    [".txt"] = "text/plain",
    [".lua"] = "text/plain",
    [".js"] = "text/plain",
    [".json"] = "application/json",
    [".html"] = "text/html",
    [".css"] = "text/css",
    [".md"] = "text/plain",
    [".py"] = "text/plain",
    [".ts"] = "text/plain",
    [".tsx"] = "text/plain",
    [".jsx"] = "text/plain",
    [".go"] = "text/plain",
    [".rs"] = "text/plain",
    [".c"] = "text/plain",
    [".cpp"] = "text/plain",
    [".h"] = "text/plain",
    [".hpp"] = "text/plain",
  }

  return media_types[extension] or "text/plain"
end

return M
