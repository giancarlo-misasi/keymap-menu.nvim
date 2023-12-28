local M = {}

---@param opts KeymapMenuHealthConfig
---@return boolean
function M.check(opts)
  if not opts.enabled then
    return true
  end

  if vim.fn.has("nvim-0.8.0") ~= 1 then
    print("Warning: neovim >= 0.8 is required")
    return false
  end

  return true
end

return M
