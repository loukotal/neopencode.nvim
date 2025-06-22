-- lua/neopencode/config.lua

local M = {}

M.options = {
  provider_id = "google",
  model_id = "gemini-1.5-pro-preview-0514",
}

function M.get(key)
  return M.options[key]
end

return M
