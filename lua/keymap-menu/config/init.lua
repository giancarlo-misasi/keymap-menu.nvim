local M = {}

function M.defaults()
  ---@class KeymapMenuConfig
  local defaults = {
    api = {},
    health = {},
    ui = {},
  }
  return defaults
end

--- @type KeymapMenuConfig
M.options = {}

---@param options KeymapMenuConfig
function M.setup(options)
  options = options or {}
  M.options = vim.tbl_deep_extend("force", {}, M.defaults(), options)
end

return M
