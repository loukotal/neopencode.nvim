-- lua/neopencode/main.lua

local M = {}

function M.setup(options)
  local config = require("neopencode.config")
  config.options = vim.tbl_deep_extend("force", config.options, options or {})

  vim.api.nvim_create_user_command("OpencodeFile", function()
    require("neopencode.actions").send_file()
  end, {
    nargs = 0,
    desc = "Send the current file to neopencode.ai",
  })

  vim.api.nvim_create_user_command("OpencodeSelect", function(opts)
    require("neopencode.actions").send_selection(opts.line1, opts.line2)
  end, {
    nargs = 0,
    range = true,
    desc = "Send the selected lines to neopencode.ai",
  })

  vim.api.nvim_create_user_command("OpencodeSelectSession", function()
    require("neopencode.session").select_session()
  end, {
    nargs = 0,
    desc = "Select an neopencode.ai session",
  })
end

return M
